-- Base title of the current file, captured before this script overwrites
-- force-media-title (reading media-title afterwards would return our own).
local base_title = nil

-- Runs before ytdl_hook (priority 10): drop the previous file's forced title
-- so it cannot leak into a URL whose title ytdl_hook sets file-locally.
mp.add_hook("on_load", 5, function()
	base_title = nil
	mp.set_property("force-media-title", "")
end)

local function get_base_title()
	if base_title == nil then
		-- For URLs "filename" is just the last path segment (often a numeric
		-- ID), so use the title ytdl_hook resolved instead.
		if (mp.get_property("path") or ""):find("://") then
			base_title = mp.get_property_osd("media-title")
		else
			base_title = mp.get_property_osd("filename")
		end
	end
	return base_title
end

function set_osd_title()
	local name = get_base_title()
	local percent_pos = ""
	local chapter = ""
	local playlist_num = ""
	local frames_dropped = ""

	if mp.get_property_osd("playlist-count") ~= "1" then
		playlist_num = "["
			.. mp.get_property_osd("playlist-pos-1")
			.. "/"
			.. mp.get_property_osd("playlist-count")
			.. "] "
	end
	-- Multi-part streams (e.g. SOOP VODs) name each chapter after its raw
	-- stream URL, which only buries the title, so skip those.
	local chapter_osd = mp.get_property_osd("chapter")
	if chapter_osd ~= "" and not chapter_osd:find("://") then
		chapter = chapter_osd .. " | "
	end

	if mp.get_property_osd("percent-pos") ~= "" then
		if mp.get_property_osd("percent-pos") ~= "100" then
			percent_pos = " [ " .. mp.get_property_osd("percent-pos") .. "% completed ]"
			mp.set_property("force-media-title", playlist_num .. chapter .. name .. percent_pos)
		else
			mp.set_property("force-media-title", playlist_num .. chapter .. name)
		end
	end
end

mp.observe_property("percent-pos", "number", set_osd_title)
mp.observe_property("chapter", "string", set_osd_title)
