-- slicing.lua — lossless video trimming via ffmpeg stream copy
--
-- Press the "set start" key once to mark A, then the "set end" key to mark B.
-- The marked [A, B] range is cut losslessly (-c copy) into a new file next to
-- the source, named "<name>_cut_<start>-<end>.<ext>". No re-encoding, so the
-- cut snaps to the nearest preceding keyframe (fast, but not frame-exact).
--
-- Default bindings (set in input.conf):
--   o   script-binding slicing/set-start
--   O   script-binding slicing/set-end

local mp = require "mp"
local msg = require "mp.msg"
local utils = require "mp.utils"

local start_time = nil

local function osd(text, dur)
    mp.osd_message(text, dur or 3)
    msg.info(text)
end

-- 12.345 -> "00:00:12.345" for filenames / logging
local function fmt(t)
    local h = math.floor(t / 3600)
    local m = math.floor((t % 3600) / 60)
    local s = t % 60
    return string.format("%02d:%02d:%06.3f", h, m, s)
end

-- whole-seconds token for filenames: 12.345 -> "12"
local function fmt_tag(t)
    return string.format("%d", math.floor(t + 0.5))
end

local function set_start()
    start_time = mp.get_property_number("time-pos")
    if not start_time then return end
    osd(("Cut start: %s"):format(fmt(start_time)))
end

local function do_cut(end_time)
    if not end_time then return end

    if not start_time then
        osd("Set the start point first (o)")
        return
    end
    if end_time <= start_time then
        osd("End point must be after the start point")
        return
    end

    local path = mp.get_property("path")
    if not path then
        osd("No file is playing")
        return
    end
    -- only local files can be stream-copied this way
    if path:find("^%a[%w+.-]*://") then
        osd("Cannot cut a stream (local files only)")
        return
    end

    local dir, name = utils.split_path(path)
    local stem, ext = name:match("^(.*)%.([^.]+)$")
    if not stem then
        stem, ext = name, "mkv"
    end

    local out = utils.join_path(dir, string.format(
        "%s_cut_%s-%s.%s", stem, fmt_tag(start_time), fmt_tag(end_time), ext))

    local duration = end_time - start_time

    local args = {
        "ffmpeg", "-y",
        "-ss", string.format("%.3f", start_time),
        "-i", path,
        "-t", string.format("%.3f", duration),
        "-map", "0",
        "-c", "copy",
        "-avoid_negative_ts", "make_zero",
        out,
    }

    osd(("Cutting… %s → %s"):format(fmt(start_time), fmt(end_time)))
    msg.info("ffmpeg: " .. table.concat(args, " "))

    mp.command_native_async({
        name = "subprocess",
        args = args,
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
    }, function(success, res, err)
        if success and res and res.status == 0 then
            local _, fname = utils.split_path(out)
            osd(("Saved: %s"):format(fname))
            start_time = nil
        else
            local detail = (res and res.stderr) or err or "unknown error"
            osd("Cut failed (check console log)")
            msg.error("ffmpeg failed: " .. tostring(detail))
        end
    end)
end

-- mark end at the current playback position
local function set_end()
    do_cut(mp.get_property_number("time-pos"))
end

-- mark end at the very end of the file, regardless of playback position,
-- so you don't have to catch the last frame before playback ends
local function set_end_eof()
    do_cut(mp.get_property_number("duration"))
end

mp.add_key_binding(nil, "set-start", set_start)
mp.add_key_binding(nil, "set-end", set_end)
mp.add_key_binding(nil, "set-end-eof", set_end_eof)
