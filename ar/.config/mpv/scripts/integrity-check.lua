-- integrity-check.lua
-- 재생 중인 동영상이 손상(끊김)되었는지 파일 로드 시 백그라운드로 검사한다.
-- 손상일 때만 화면 우상단에 표시등을 띄우고, 정상 파일은 아무 표시도 하지 않는다.
--
-- 동작:
--   * file-loaded 시 ffmpeg 으로 demux 검사를 백그라운드 실행(재생은 그대로).
--   * 손상 구간을 만나면 -xerror 로 즉시 중단 → 손상 파일은 빠르게 판정.
--   * 결과는 경로+수정시각으로 캐시 → 다음에 같은 파일은 즉시 표시.
--   * 손상 파일 경로는 corrupted.log 에 기록.
--   * 재생목록이 있으면(scan_playlist) 현재 파일 검사가 끝난 뒤,
--     뒤따르는 항목들을 한 번에 하나씩 백그라운드로 미리 검사한다.
--     (배지는 현재 재생 파일에만 표시하고, 미리 검사는 캐시·로그만 갱신)
--   * 재생목록 미리 검사가 끝나면 OSD 로 요약 알림(notify_done).
--     script-message integrity-status 로 진행 현황을 즉시 확인할 수 있다.
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
    scan_playlist = true,   -- 현재 파일 검사 후 뒤따르는 재생목록 항목도 백그라운드 검사
    notify_done   = true,   -- 재생목록 백그라운드 검사가 끝나면 OSD 로 요약 표시
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
local bg_token     = 0      -- 재생목록 백그라운드 검사 무효화용

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

-- subprocess 결과를 손상 여부로 환산
local function determine_corrupt(result)
    local stderr = result.stderr or ""
    local status = result.status or 0
    return (stderr:gsub("%s+", "") ~= "") or (status ~= 0)
end

-- 캐시가 현재 파일 상태(수정시각·크기)와 일치하면 그 항목을 반환
local function cached_fresh(path)
    if not (opts.use_cache and cache[path]) then return nil end
    local mtime, size = file_sig(path)
    local e = cache[path]
    if mtime and e.mtime == mtime and e.size == size then
        return e
    end
    return nil
end

local function start_scan(path, on_done)
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
        apply_result(path, determine_corrupt(result), false)
        if on_done then on_done() end
    end)
end

----------------------------------------------------------------------
-- 재생목록 백그라운드 검사 (현재 파일 검사 완료 후 뒤따르는 항목들)
----------------------------------------------------------------------
-- 진행 중인 재생목록 검사를 무효화(파일 전환·토글 시)
local function cancel_bg()
    bg_token = bg_token + 1
end

-- 재생목록 항목의 filename 을 실제 검사 가능한 경로로 변환
local function resolve_playlist_path(filename)
    if not filename then return nil end
    if filename:find("^%a[%w%+%-%.]*://") then return filename end -- URL 은 그대로
    if filename:find("^/") then return filename end               -- 절대경로
    local wd = mp.get_property("working-directory")
    if wd then return utils.join_path(wd, filename) end
    return filename
end

-- 배지 없이 캐시·로그만 갱신 (백그라운드 항목용)
local function record_result_quiet(path, corrupt)
    local mtime, size = file_sig(path)
    cache[path] = {
        mtime  = mtime or 0,
        size   = size or 0,
        status = corrupt and "corrupt" or "ok",
        errors = 0,
    }
    if corrupt then
        log_corrupted(path)
        msg.warn("손상됨(재생목록): " .. path)
    end
    append_cache(path, cache[path])
end

-- 재생목록 전체의 검사 현황을 캐시 기준으로 집계
local function playlist_stats()
    local count = mp.get_property_number("playlist-count", 0)
    local s = { total = 0, ok = 0, corrupt = 0, pending = 0 }
    for i = 0, count - 1 do
        local path = resolve_playlist_path(
            mp.get_property("playlist/" .. i .. "/filename"))
        if scannable(path) then
            s.total = s.total + 1
            local e = cached_fresh(path)
            if not e then            s.pending = s.pending + 1
            elseif e.status == "corrupt" then s.corrupt = s.corrupt + 1
            else                     s.ok = s.ok + 1 end
        end
    end
    return s
end

-- start_index 부터 재생목록 끝까지 한 번에 하나씩 순차 검사
local function scan_playlist_from(start_index)
    cancel_bg()
    local token    = bg_token
    local count    = mp.get_property_number("playlist-count", 0)
    local did_scan = false   -- 이번 검사에서 실제로 새로 검사한 항목이 있었는지

    -- 끝까지 도달했을 때 요약 알림(새로 검사한 게 있을 때만 — 자동재생 중복 방지)
    local function finish()
        if not (opts.notify_done and did_scan) then return end
        local s = playlist_stats()
        local txt = (s.corrupt > 0)
            and string.format("재생목록 검사 완료 · 손상 %d개 (총 %d)", s.corrupt, s.total)
            or  string.format("재생목록 검사 완료 · 이상 없음 (총 %d)", s.total)
        mp.osd_message(txt, 4)
        msg.info(txt)
    end

    local function step(i)
        if token ~= bg_token then return end          -- 파일 전환/토글 → 중단
        if i >= count then finish(); return end
        local path = resolve_playlist_path(
            mp.get_property("playlist/" .. i .. "/filename"))
        if not scannable(path) then return step(i + 1) end
        if path == current_path then return step(i + 1) end  -- 현재 파일은 이미 검사됨
        if cached_fresh(path) then return step(i + 1) end     -- 이미 검사된 파일은 건너뜀

        did_scan = true
        mp.command_native_async({
            name           = "subprocess",
            args           = build_args(path),
            playback_only  = false,
            capture_stdout = true,
            capture_stderr = true,
        }, function(success, result, err)
            if token ~= bg_token then return end      -- 중간에 무효화됨 → 무시
            if result and not result.killed_by_us
               and result.error_string ~= "init" then
                record_result_quiet(path, determine_corrupt(result))
            end
            step(i + 1)
        end)
    end

    step(start_index)
end

-- 재생목록이 있으면 현재 위치 다음 항목부터 백그라운드 검사 시작
local function maybe_scan_playlist()
    if not (opts.enabled and opts.scan_playlist) then return end
    local count = mp.get_property_number("playlist-count", 0)
    if count <= 1 then return end                     -- 재생목록 없음
    local pos = mp.get_property_number("playlist-pos", 0)
    scan_playlist_from(pos + 1)
end

----------------------------------------------------------------------
-- 이벤트
----------------------------------------------------------------------
local function on_file_loaded()
    hide_badge()
    cancel_bg()                                        -- 이전 재생목록 검사 중단
    current_path = mp.get_property("path")
    if not opts.enabled or not opts.scan_on_load then return end
    if not scannable(current_path) then
        maybe_scan_playlist()                          -- 현재가 스트림이어도 목록은 검사
        return
    end

    -- 캐시 적중(수정시각·크기 동일)이면 즉시 표시
    local e = cached_fresh(current_path)
    if e then
        apply_result(current_path, e.status == "corrupt", true)
        maybe_scan_playlist()
        return
    end
    start_scan(current_path, maybe_scan_playlist)      -- 현재 검사 완료 후 목록 검사
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
        cancel_bg()
        hide_badge()
    else
        on_file_loaded()
    end
    mp.osd_message("무결성 검사: " .. (opts.enabled and "켜짐" or "꺼짐"))
end

-- 재생목록 검사 현황을 즉시 표시 (끝났는지 / 얼마나 남았는지 확인용)
local function status()
    local count = mp.get_property_number("playlist-count", 0)
    if count <= 1 then
        mp.osd_message("무결성: 재생목록 없음")
        return
    end
    local s = playlist_stats()
    local state = (s.pending == 0) and "검사 완료" or ("검사 중(남음 " .. s.pending .. ")")
    mp.osd_message(string.format(
        "무결성 %s · 정상 %d · 손상 %d · 미검사 %d (총 %d)",
        state, s.ok, s.corrupt, s.pending, s.total), 4)
end

mp.add_key_binding(nil, "rescan", rescan)
mp.add_key_binding(nil, "toggle", toggle)
mp.add_key_binding(nil, "status", status)
mp.register_script_message("integrity-rescan", rescan)
mp.register_script_message("integrity-toggle", toggle)
mp.register_script_message("integrity-status", status)

----------------------------------------------------------------------
-- 초기화
----------------------------------------------------------------------
load_cache()
compact_cache()
mp.register_event("file-loaded", on_file_loaded)
