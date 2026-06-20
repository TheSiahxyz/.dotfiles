-- integrity-check.lua
-- Background-checks whether the playing video is corrupt (truncated) when a file loads.
-- Shows a badge in the top-right ONLY when corrupt; healthy files show nothing.
--
-- Behaviour:
--   * Checking starts on the "scan" key (script-message integrity-scan), or
--     automatically on file open if scan_on_load=yes. ffmpeg demux runs in the
--     background, so playback continues.
--   * Abort on the first error with -xerror -> corrupt files are judged quickly.
--   * Results are cached by path + mtime -> the same file shows instantly next time.
--   * Corrupt file paths are recorded in corrupted.log.
--   * If a playlist exists (scan_playlist), after the current file is checked,
--     the following entries are pre-checked in parallel in the background
--     (scan_concurrency workers). Background checks are read-rate throttled
--     (bg_read_rate x realtime) and run at low CPU priority so they don't
--     starve playback I/O. The current file is always checked at full speed.
--     (The badge is only for the current file; pre-checks update cache/log only.)
--   * When the playlist pre-check finishes, an OSD summary is shown (notify_done).
--     script-message integrity-status shows the current progress at any time.
--
-- Limitation: based on -c copy (no decoding), so it catches container/truncation/cutoff
--             problems, but not cases where the container is fine and only the picture is
--             slightly broken. For that, set deep_scan=yes (much slower).

local mp = require("mp")
local utils = require("mp.utils")
local msg = require("mp.msg")

----------------------------------------------------------------------
-- Options (override via script-opts/integrity-check.conf)
----------------------------------------------------------------------
local opts = {
	enabled = true, -- feature on/off
	scan_on_load = false, -- auto-check on file open; if false, trigger with the "scan" key
	scan_playlist = true, -- after the current file, also background-check following playlist entries
	scan_concurrency = 0, -- how many playlist entries to check in parallel (0 = entire playlist at once)
	notify_done = true, -- show an OSD summary when the playlist background check finishes
	show_scanning = false, -- show a "scanning" badge (default: off)
	deep_scan = false, -- if true, decode while checking (precise but slow)
	use_cache = true, -- use the result cache
	ffmpeg = "ffmpeg",
	-- Throttle background playlist checks to N x realtime so they don't flood
	-- the disk/cache and stutter playback (ionice is ignored by the `none`
	-- scheduler, so rate-limiting is what actually protects playback).
	-- 0 = unlimited. The current file is always checked at full speed.
	bg_read_rate = 8,
	bg_read_burst = 30, -- seconds to read at full speed first (headers/early errors)
	-- Low-priority wrapper (helps userspace CPU; ionice is a no-op on `none`).
	-- Set to "" to disable. (Linux: coreutils `nice`, util-linux `ionice`.)
	priority_cmd = "nice -n 19 ionice -c 3",
	status_font = 20, -- base OSD font for the status list; shrinks automatically so all lines fit
	font_size = 22,
}
require("mp.options").read_options(opts, "integrity-check")

----------------------------------------------------------------------
-- Paths
----------------------------------------------------------------------
local HOME = os.getenv("HOME") or ""
local CONFIG_DIR = HOME .. "/.config/mpv"
local CACHE_FILE = CONFIG_DIR .. "/integrity_cache.tsv"
local LOG_FILE = CONFIG_DIR .. "/corrupted.log"

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------
local cache = {} -- path -> {mtime=, size=, status=, errors=}
local overlay = mp.create_osd_overlay("ass-events")
local status_overlay = mp.create_osd_overlay("ass-events")
local status_timer = nil
local current_path = nil
local scan_token = 0 -- to ignore stale callbacks
local bg_token = 0 -- to invalidate the playlist background scan
local current_scanning = false -- true while the current file is being checked
local scanning = {} -- path -> {prog=, dur=} for every in-flight check (current + playlist)

----------------------------------------------------------------------
-- Cache I/O
----------------------------------------------------------------------
local function load_cache()
	local f = io.open(CACHE_FILE, "r")
	if not f then
		return
	end
	for line in f:lines() do
		local mtime, size, status, errors, path = line:match("^(%d+)\t(%d+)\t(%S+)\t(%d+)\t(.+)$")
		if path then
			cache[path] = {
				mtime = tonumber(mtime),
				size = tonumber(size),
				status = status,
				errors = tonumber(errors),
			}
		end
	end
	f:close()
end

-- Append a single entry. So that concurrent mpv instances writing the cache
-- don't overwrite each other's results. On load, the last line for a path wins.
local function append_cache(path, e)
	if not opts.use_cache then
		return
	end
	local f = io.open(CACHE_FILE, "a")
	if not f then
		return
	end
	f:write(string.format("%d\t%d\t%s\t%d\t%s\n", e.mtime or 0, e.size or 0, e.status, e.errors or 0, path))
	f:close()
end

-- On startup, compact duplicate lines (keep only the latest, rewrite).
-- During a session only append is used.
local function compact_cache()
	if not opts.use_cache then
		return
	end
	local f = io.open(CACHE_FILE, "w")
	if not f then
		return
	end
	for path, e in pairs(cache) do
		f:write(string.format("%d\t%d\t%s\t%d\t%s\n", e.mtime or 0, e.size or 0, e.status, e.errors or 0, path))
	end
	f:close()
end

local function log_corrupted(path)
	local f = io.open(LOG_FILE, "a")
	if not f then
		return
	end
	f:write(string.format("%s\t%s\n", os.date("%Y-%m-%d %H:%M:%S"), path))
	f:close()
end

----------------------------------------------------------------------
-- Badge (indicator) - shown only when corrupt
----------------------------------------------------------------------
local function hide_badge()
	overlay:remove()
end

local function show_corrupt()
	overlay.res_x = 1280
	overlay.res_y = 720
	overlay.data = string.format(
		"{\\an9\\pos(1268,10)\\fs%d\\bord2\\shad1\\1c&H0000E0&\\3c&H000000&}%s",
		opts.font_size,
		"■ Corrupt"
	)
	overlay:update()
end

local function show_scanning()
	if not opts.show_scanning then
		hide_badge()
		return
	end
	overlay.res_x = 1280
	overlay.res_y = 720
	overlay.data = string.format(
		"{\\an9\\pos(1268,10)\\fs%d\\bord2\\shad1\\1c&H00D7FF&\\3c&H000000&}%s",
		opts.font_size,
		"● Checking..."
	)
	overlay:update()
end

----------------------------------------------------------------------
-- Utils
----------------------------------------------------------------------
local function scannable(path)
	if not path then
		return false
	end
	if path:find("^%a[%w%+%-%.]*://") then
		return false
	end -- exclude network/stream
	return true
end

local function file_sig(path)
	local info = utils.file_info(path)
	if not info or not info.is_file then
		return nil
	end
	return math.floor(info.mtime), info.size
end

----------------------------------------------------------------------
-- Check
----------------------------------------------------------------------
-- read_rate: nil/0 = full speed; >0 = throttle reading to that many x realtime
-- (input option, must precede -i) so background checks don't starve playback.
local function build_args(path, read_rate, progfile)
	local args = {}
	-- Prepend the low-priority wrapper (nice helps userspace CPU).
	if opts.priority_cmd and opts.priority_cmd ~= "" then
		for word in opts.priority_cmd:gmatch("%S+") do
			args[#args + 1] = word
		end
	end
	local function add(...)
		for _, v in ipairs({ ... }) do
			args[#args + 1] = v
		end
	end
	add(opts.ffmpeg, "-hide_banner", "-v", "error", "-xerror")
	if read_rate and read_rate > 0 then
		add("-readrate", tostring(read_rate), "-readrate_initial_burst", tostring(opts.bg_read_burst or 30))
	end
	add("-i", path)
	if not opts.deep_scan then -- demux only (fast); deep_scan decodes (slow)
		add("-c", "copy")
	end
	add("-map", "0")
	if progfile then
		add("-progress", progfile)
	end -- machine-readable progress
	add("-f", "null", "-")
	return args
end

local function apply_result(path, corrupt, from_cache)
	local mtime, size = file_sig(path)
	cache[path] = {
		mtime = mtime or 0,
		size = size or 0,
		status = corrupt and "corrupt" or "ok",
		errors = 0,
	}
	if corrupt then
		show_corrupt()
		if not from_cache then
			log_corrupted(path)
			msg.warn("Corrupt: " .. path)
		end
	else
		-- healthy files show nothing
		hide_badge()
	end
	if not from_cache then
		append_cache(path, cache[path])
	end
end

-- Convert the subprocess result into a corrupt/ok verdict
local function determine_corrupt(result)
	local stderr = result.stderr or ""
	local status = result.status or 0
	return (stderr:gsub("%s+", "") ~= "") or (status ~= 0)
end

-- Return the cache entry if it matches the file's current mtime/size
local function cached_fresh(path)
	if not (opts.use_cache and cache[path]) then
		return nil
	end
	local mtime, size = file_sig(path)
	local e = cache[path]
	if mtime and e.mtime == mtime and e.size == size then
		return e
	end
	return nil
end

-- In-flight scan tracking (for the status display: filename + % progress)
local function basename(p)
	return (p:gsub("^.*/", ""))
end

-- Register a path as being scanned; returns the -progress temp file to use.
local function begin_scanning(path, dur)
	local prog = os.tmpname()
	scanning[path] = { prog = prog, dur = dur }
	return prog
end

local function clear_scanning(path)
	local rec = scanning[path]
	if rec and rec.prog then
		os.remove(rec.prog)
	end
	scanning[path] = nil
end

-- Probe a file's duration in the background so progress can be shown as %.
local function probe_duration(path)
	mp.command_native_async({
		name = "subprocess",
		args = {
			"ffprobe",
			"-v",
			"error",
			"-show_entries",
			"format=duration",
			"-of",
			"default=nokey=1:noprint_wrappers=1",
			path,
		},
		playback_only = false,
		capture_stdout = true,
	}, function(success, result, err)
		local rec = scanning[path]
		if not rec or not result or not result.stdout then
			return
		end
		local d = tonumber((result.stdout:gsub("%s+", "")))
		if d and d > 0 then
			rec.dur = d
		end
	end)
end

-- Latest progress (%) for an in-flight scan, read from its -progress file.
local function scan_progress(rec)
	if not (rec and rec.prog and rec.dur and rec.dur > 0) then
		return nil
	end
	local f = io.open(rec.prog, "r")
	if not f then
		return nil
	end
	local data = f:read("*a") or ""
	f:close()
	local last
	for v in data:gmatch("out_time_us=(%d+)") do
		last = v
	end
	if not last then
		return nil
	end
	local pct = math.floor(tonumber(last) / 1e6 / rec.dur * 100 + 0.5)
	if pct < 0 then
		pct = 0
	elseif pct > 100 then
		pct = 100
	end
	return pct
end

local function start_scan(path, on_done)
	scan_token = scan_token + 1
	local token = scan_token
	current_scanning = true
	local dur = (path == current_path) and mp.get_property_number("duration") or nil
	local prog = begin_scanning(path, dur)
	if not dur then
		probe_duration(path)
	end
	show_scanning()
	mp.command_native_async({
		name = "subprocess",
		args = build_args(path, nil, prog),
		playback_only = false,
		capture_stdout = true,
		capture_stderr = true,
	}, function(success, result, err)
		clear_scanning(path)
		if token ~= scan_token then
			return
		end -- moved to another file -> ignore
		current_scanning = false
		if not result then
			hide_badge()
			return
		end
		if result.killed_by_us then
			return
		end
		if result.error_string == "init" then
			msg.error("ffmpeg failed to run - check PATH")
			hide_badge()
			return
		end
		apply_result(path, determine_corrupt(result), false)
		if on_done then
			on_done()
		end
	end)
end

----------------------------------------------------------------------
-- Playlist background check (entries after the current file, once it's checked)
----------------------------------------------------------------------
-- Invalidate an in-progress playlist scan (on file change / toggle)
local function cancel_bg()
	bg_token = bg_token + 1
end

-- Convert a playlist entry's filename into a checkable path
local function resolve_playlist_path(filename)
	if not filename then
		return nil
	end
	if filename:find("^%a[%w%+%-%.]*://") then
		return filename
	end -- keep URLs as-is
	if filename:find("^/") then
		return filename
	end -- absolute path
	local wd = mp.get_property("working-directory")
	if wd then
		return utils.join_path(wd, filename)
	end
	return filename
end

-- Update cache/log only, no badge (for background entries)
local function record_result_quiet(path, corrupt)
	local mtime, size = file_sig(path)
	cache[path] = {
		mtime = mtime or 0,
		size = size or 0,
		status = corrupt and "corrupt" or "ok",
		errors = 0,
	}
	if corrupt then
		log_corrupted(path)
		msg.warn("Corrupt (playlist): " .. path)
	end
	append_cache(path, cache[path])
end

-- Aggregate the playlist's check status from the cache
local function playlist_stats()
	local count = mp.get_property_number("playlist-count", 0)
	local s = { total = 0, ok = 0, corrupt = 0, pending = 0 }
	for i = 0, count - 1 do
		local path = resolve_playlist_path(mp.get_property("playlist/" .. i .. "/filename"))
		if scannable(path) then
			s.total = s.total + 1
			local e = cached_fresh(path)
			if not e then
				s.pending = s.pending + 1
			elseif e.status == "corrupt" then
				s.corrupt = s.corrupt + 1
			else
				s.ok = s.ok + 1
			end
		end
	end
	return s
end

-- Scan playlist entries from start_index to the end, up to scan_concurrency at
-- a time (parallel). Each check is a low-priority external ffmpeg process, so
-- playback is never blocked even with several running at once.
local function scan_playlist_from(start_index)
	cancel_bg()
	local token = bg_token
	local count = mp.get_property_number("playlist-count", 0)
	-- 0 = fully dynamic: run the whole remaining playlist in parallel
	local workers = opts.scan_concurrency or 1
	if workers <= 0 then
		workers = math.max(1, count)
	end
	local next_i = start_index
	local active = 0
	local did_scan = false -- whether this run actually checked any new entry
	local notified = false

	-- Summary notification once all workers drain (only if something new was
	-- scanned - avoids duplicate notifications during autoplay)
	local function finish()
		if notified then
			return
		end
		notified = true
		if not (opts.notify_done and did_scan) then
			return
		end
		local s = playlist_stats()
		local txt = (s.corrupt > 0) and string.format("Playlist check done | %d corrupt (total %d)", s.corrupt, s.total)
			or string.format("Playlist check done | no issues (total %d)", s.total)
		mp.osd_message(txt, 4)
		msg.info(txt)
	end

	local pump -- forward declaration

	local function on_done(path, result)
		active = active - 1
		clear_scanning(path)
		-- Keep any finished result even if this sweep was superseded (file
		-- switched): the ffmpeg work is already done, so persist it to cache.
		if result and not result.killed_by_us and result.error_string ~= "init" then
			record_result_quiet(path, determine_corrupt(result))
		end
		if token ~= bg_token then
			return
		end -- superseded -> don't dispatch more
		pump()
	end

	-- Fill free worker slots with the next eligible entries.
	pump = function()
		if token ~= bg_token then
			return
		end
		while active < workers do
			local path
			while next_i < count do
				local p = resolve_playlist_path(mp.get_property("playlist/" .. next_i .. "/filename"))
				next_i = next_i + 1
				if scannable(p) and p ~= current_path and not cached_fresh(p) then
					path = p
					break
				end
			end
			if not path then -- nothing left to dispatch
				if active == 0 then
					finish()
				end
				return
			end
			active = active + 1
			did_scan = true
			local prog = begin_scanning(path, nil)
			probe_duration(path)
			mp.command_native_async({
				name = "subprocess",
				args = build_args(path, opts.bg_read_rate, prog),
				playback_only = false,
				capture_stdout = true,
				capture_stderr = true,
			}, function(success, result, err)
				on_done(path, result)
			end)
		end
	end

	pump()
end

-- If a playlist exists, start the background scan from the entry after the current position
local function maybe_scan_playlist()
	if not (opts.enabled and opts.scan_playlist) then
		return
	end
	local count = mp.get_property_number("playlist-count", 0)
	if count <= 1 then
		return
	end -- no playlist
	local pos = mp.get_property_number("playlist-pos", 0)
	scan_playlist_from(pos + 1)
end

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------
-- Check the current file, then (if any) sweep the rest of the playlist.
local function check_current_and_playlist()
	if not opts.enabled then
		return
	end
	if not scannable(current_path) then
		maybe_scan_playlist() -- even if current is a stream, still scan the list
		return
	end
	-- On a cache hit (same mtime/size), show immediately
	local e = cached_fresh(current_path)
	if e then
		apply_result(current_path, e.status == "corrupt", true)
		maybe_scan_playlist()
		return
	end
	start_scan(current_path, maybe_scan_playlist) -- after the current check, scan the list
end

local function on_file_loaded()
	hide_badge()
	cancel_bg() -- stop the previous playlist scan
	scan_token = scan_token + 1 -- invalidate any in-flight current-file scan
	current_scanning = false
	current_path = mp.get_property("path")
	if not opts.enabled then
		return
	end
	if opts.scan_on_load then
		check_current_and_playlist()
	end
end

----------------------------------------------------------------------
-- Key bindings / messages
----------------------------------------------------------------------
-- Manually start a check: current file, then the rest of the playlist.
-- This is the trigger to use when scan_on_load = false.
local function scan_now()
	if not opts.enabled then
		mp.osd_message("Integrity check: off")
		return
	end
	current_path = mp.get_property("path")
	if not current_path then
		mp.osd_message("Integrity: no file")
		return
	end
	mp.osd_message("Integrity: scanning...")
	check_current_and_playlist()
end

local function rescan()
	if current_path and scannable(current_path) then
		cache[current_path] = nil
		start_scan(current_path, maybe_scan_playlist)
		mp.osd_message("Integrity: re-checking...")
	else
		mp.osd_message("Integrity: file cannot be checked")
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
	mp.osd_message("Integrity check: " .. (opts.enabled and "on" or "off"))
end

-- Current file's status, independent of the use_cache option (checks freshness)
local function current_status_text()
	if not current_path then
		return "Integrity: no file"
	end
	if not scannable(current_path) then
		return "Integrity: not checkable (stream)"
	end
	local e = cache[current_path]
	local mtime, size = file_sig(current_path)
	if e and mtime and e.mtime == mtime and e.size == size then
		return (e.status == "corrupt") and "Integrity: corrupt" or "Integrity: OK"
	end
	if current_scanning then
		return "Integrity: checking..."
	end
	return "Integrity: not checked"
end

-- Names (+ % progress) of files currently being checked.
local function scanning_list()
	local out = {}
	for p, rec in pairs(scanning) do
		out[#out + 1] = { name = basename(p), pct = scan_progress(rec) }
	end
	-- nearly-finished first (highest %), then by name
	table.sort(out, function(a, b)
		local pa, pb = a.pct or -1, b.pct or -1
		if pa ~= pb then
			return pa > pb
		end
		return a.name < b.name
	end)
	local res = {}
	for _, e in ipairs(out) do
		res[#res + 1] = e.pct and string.format("%s (%d%%)", e.name, e.pct) or e.name
	end
	return res
end

-- Render status lines via an ASS overlay, shrinking the font so every line fits.
local function hide_status()
	status_overlay:remove()
	if status_timer then
		status_timer:kill()
		status_timer = nil
	end
end

local function show_status(lines)
	local n = #lines
	local resy = 720
	status_overlay.res_x = 1280
	status_overlay.res_y = resy
	-- line height ~ fs * 1.25; keep within ~94% of the height
	local base = opts.status_font or 20
	local fs = math.min(base, math.floor(resy * 0.94 / (n * 1.25)))
	if fs < 6 then
		fs = 6
	end
	local body = {}
	for i, l in ipairs(lines) do
		body[i] = l:gsub("\\", "/"):gsub("{", "("):gsub("}", ")")
	end
	status_overlay.data = string.format(
		"{\\an7\\pos(12,8)\\fs%d\\bord2\\shad1\\1c&HFFFFFF&\\3c&H000000&}%s",
		fs,
		table.concat(body, "\\N")
	)
	status_overlay:update()
	if status_timer then
		status_timer:kill()
	end
	status_timer = mp.add_timeout(5, hide_status)
end

-- Show the check status immediately (single file, or whole playlist)
local function status()
	local count = mp.get_property_number("playlist-count", 0)
	local lines = {}
	if count <= 1 then
		lines[#lines + 1] = current_status_text()
	else
		local s = playlist_stats()
		local state = (s.pending == 0) and "done" or ("scanning (" .. s.pending .. " left)")
		lines[#lines + 1] = string.format(
			"Integrity %s | ok %d | corrupt %d | pending %d (total %d)",
			state,
			s.ok,
			s.corrupt,
			s.pending,
			s.total
		)
	end
	local checking = scanning_list()
	if #checking > 0 then
		lines[#lines + 1] = string.format("Checking (%d):", #checking)
		for _, name in ipairs(checking) do
			lines[#lines + 1] = "  " .. name -- one file per line
		end
	end
	show_status(lines)
end

mp.add_key_binding(nil, "scan", scan_now)
mp.add_key_binding(nil, "rescan", rescan)
mp.add_key_binding(nil, "toggle", toggle)
mp.add_key_binding(nil, "status", status)
mp.register_script_message("integrity-scan", scan_now)
mp.register_script_message("integrity-rescan", rescan)
mp.register_script_message("integrity-toggle", toggle)
mp.register_script_message("integrity-status", status)

----------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------
load_cache()
compact_cache()
mp.register_event("file-loaded", on_file_loaded)
