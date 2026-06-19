-- integrity-check.lua
-- 재생 중인 동영상이 손상(끊김)되었는지 파일 로드 시 백그라운드로 검사한다.
-- 손상일 때만 화면 우상단에 표시등을 띄우고, 정상 파일은 아무 표시도 하지 않는다.
--
-- 동작:
--   * file-loaded 시 ffmpeg 으로 demux 검사를 백그라운드 실행(재생은 그대로).
--   * 손상 구간을 만나면 -xerror 로 즉시 중단 → 손상 파일은 빠르게 판정.
--   * 결과는 경로+수정시각으로 캐시 → 다음에 같은 파일은 즉시 표시.
--   * 손상 파일 경로는 corrupted.log 에 기록.
--
-- 한계: -c copy(디코딩 안 함) 기반이라 컨테이너/끊김/잘림은 잡지만,
--       컨테이너는 멀쩡하고 화면만 미세하게 깨지는 결함은 못 잡는다.
--       그런 정밀 검사는 deep_scan=yes 로 바꾸면 되지만 훨씬 느리다.

local mp    = require 'mp'
local utils = require 'mp.utils'
local msg   = require 'mp.msg'

----------------------------------------------------------------------
-- 옵션 (script-opts/integrity-check.conf 로 덮어쓰기 가능)
----------------------------------------------------------------------
local opts = {
    enabled       = true,   -- 기능 on/off
    scan_on_load  = true,   -- 파일 열 때 자동 검사
    show_scanning = false,  -- 검사 중 표시 여부 (기본: 표시 안 함)
    deep_scan     = false,  -- true 면 디코딩까지 검사(정밀하지만 느림)
    use_cache     = true,   -- 검사 결과 캐시 사용
    ffmpeg        = "ffmpeg",
    font_size     = 22,
}
require('mp.options').read_options(opts, "integrity-check")

----------------------------------------------------------------------
-- 경로
----------------------------------------------------------------------
local HOME       = os.getenv("HOME") or ""
local CONFIG_DIR = HOME .. "/.config/mpv"
local CACHE_FILE = CONFIG_DIR .. "/integrity_cache.tsv"
local LOG_FILE   = CONFIG_DIR .. "/corrupted.log"

----------------------------------------------------------------------
-- 상태
----------------------------------------------------------------------
local cache        = {}     -- path -> {mtime=, size=, status=, errors=}
local overlay      = mp.create_osd_overlay("ass-events")
local current_path = nil
local scan_token   = 0      -- 오래된(stale) 콜백 무시용

----------------------------------------------------------------------
-- 캐시 입출력
----------------------------------------------------------------------
local function load_cache()
    local f = io.open(CACHE_FILE, "r")
    if not f then return end
    for line in f:lines() do
        local mtime, size, status, errors, path =
            line:match("^(%d+)\t(%d+)\t(%S+)\t(%d+)\t(.+)$")
        if path then
            cache[path] = {
                mtime  = tonumber(mtime),
                size   = tonumber(size),
                status = status,
                errors = tonumber(errors),
            }
        end
    end
    f:close()
end

-- 한 항목만 덧붙인다(append). 여러 mpv 인스턴스가 동시에 캐시를 써도
-- 서로의 결과를 덮어쓰지 않게 하기 위함. load 시 같은 경로는 마지막 줄이 이긴다.
local function append_cache(path, e)
    if not opts.use_cache then return end
    local f = io.open(CACHE_FILE, "a")
    if not f then return end
    f:write(string.format("%d\t%d\t%s\t%d\t%s\n",
        e.mtime or 0, e.size or 0, e.status, e.errors or 0, path))
    f:close()
end

-- 시작 시 중복 줄을 정리(최신 상태만 남기고 재작성). 세션 중에는 append만 사용.
local function compact_cache()
    if not opts.use_cache then return end
    local f = io.open(CACHE_FILE, "w")
    if not f then return end
    for path, e in pairs(cache) do
        f:write(string.format("%d\t%d\t%s\t%d\t%s\n",
            e.mtime or 0, e.size or 0, e.status, e.errors or 0, path))
    end
    f:close()
end

local function log_corrupted(path)
    local f = io.open(LOG_FILE, "a")
    if not f then return end
    f:write(string.format("%s\t%s\n", os.date("%Y-%m-%d %H:%M:%S"), path))
    f:close()
end

----------------------------------------------------------------------
-- 배지(표시등) — 손상일 때만 표시
----------------------------------------------------------------------
local function hide_badge()
    overlay:remove()
end

local function show_corrupt()
    overlay.res_x = 1280
    overlay.res_y = 720
    overlay.data = string.format(
        "{\\an9\\pos(1268,10)\\fs%d\\bord2\\shad1\\1c&H0000E0&\\3c&H000000&}%s",
        opts.font_size, "■ 손상됨")
    overlay:update()
end

local function show_scanning()
    if not opts.show_scanning then hide_badge(); return end
    overlay.res_x = 1280
    overlay.res_y = 720
    overlay.data = string.format(
        "{\\an9\\pos(1268,10)\\fs%d\\bord2\\shad1\\1c&H00D7FF&\\3c&H000000&}%s",
        opts.font_size, "● 무결성 검사 중…")
    overlay:update()
end

----------------------------------------------------------------------
-- 유틸
----------------------------------------------------------------------
local function scannable(path)
    if not path then return false end
    if path:find("^%a[%w%+%-%.]*://") then return false end -- 네트워크/스트림 제외
    return true
end

local function file_sig(path)
    local info = utils.file_info(path)
    if not info or not info.is_file then return nil end
    return math.floor(info.mtime), info.size
end

----------------------------------------------------------------------
-- 검사
----------------------------------------------------------------------
local function build_args(path)
    if opts.deep_scan then
        -- 디코딩까지: 정밀하지만 느림
        return { opts.ffmpeg, "-hide_banner", "-v", "error", "-xerror",
                 "-i", path, "-map", "0", "-f", "null", "-" }
    end
    -- demux 만: 빠름. 컨테이너/끊김/잘림 검출
    return { opts.ffmpeg, "-hide_banner", "-v", "error", "-xerror",
             "-i", path, "-c", "copy", "-map", "0", "-f", "null", "-" }
end

local function apply_result(path, corrupt, from_cache)
    local mtime, size = file_sig(path)
    cache[path] = {
        mtime  = mtime or 0,
        size   = size or 0,
        status = corrupt and "corrupt" or "ok",
        errors = 0,
    }
    if corrupt then
        show_corrupt()
        if not from_cache then
            log_corrupted(path)
            msg.warn("손상됨: " .. path)
        end
    else
        -- 정상 파일은 아무 표시도 하지 않는다
        hide_badge()
    end
    if not from_cache then append_cache(path, cache[path]) end
end

local function start_scan(path)
    scan_token = scan_token + 1
    local token = scan_token
    show_scanning()
    mp.command_native_async({
        name           = "subprocess",
        args           = build_args(path),
        playback_only  = false,
        capture_stdout = true,
        capture_stderr = true,
    }, function(success, result, err)
        if token ~= scan_token then return end       -- 다른 파일로 넘어감 → 무시
        if not result then hide_badge(); return end
        if result.killed_by_us then return end
        if result.error_string == "init" then
            msg.error("ffmpeg 실행 실패 — PATH 확인 필요")
            hide_badge()
            return
        end
        local stderr = result.stderr or ""
        local status = result.status or 0
        local corrupt = (stderr:gsub("%s+", "") ~= "") or (status ~= 0)
        apply_result(path, corrupt, false)
    end)
end

----------------------------------------------------------------------
-- 이벤트
----------------------------------------------------------------------
local function on_file_loaded()
    hide_badge()
    current_path = mp.get_property("path")
    if not opts.enabled or not opts.scan_on_load then return end
    if not scannable(current_path) then return end

    -- 캐시 적중(수정시각·크기 동일)이면 즉시 표시
    if opts.use_cache and cache[current_path] then
        local mtime, size = file_sig(current_path)
        local e = cache[current_path]
        if mtime and e.mtime == mtime and e.size == size then
            apply_result(current_path, e.status == "corrupt", true)
            return
        end
    end
    start_scan(current_path)
end

----------------------------------------------------------------------
-- 키 바인딩 / 메시지
----------------------------------------------------------------------
local function rescan()
    if current_path and scannable(current_path) then
        cache[current_path] = nil
        start_scan(current_path)
        mp.osd_message("무결성: 다시 검사 중…")
    else
        mp.osd_message("무결성: 검사할 수 없는 파일")
    end
end

local function toggle()
    opts.enabled = not opts.enabled
    if not opts.enabled then
        hide_badge()
    else
        on_file_loaded()
    end
    mp.osd_message("무결성 검사: " .. (opts.enabled and "켜짐" or "꺼짐"))
end

mp.add_key_binding(nil, "rescan", rescan)
mp.add_key_binding(nil, "toggle", toggle)
mp.register_script_message("integrity-rescan", rescan)
mp.register_script_message("integrity-toggle", toggle)

----------------------------------------------------------------------
-- 초기화
----------------------------------------------------------------------
load_cache()
compact_cache()
mp.register_event("file-loaded", on_file_loaded)
