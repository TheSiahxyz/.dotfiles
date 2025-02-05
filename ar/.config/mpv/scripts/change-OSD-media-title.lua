function set_osd_title()
	local name = mp.get_property_osd("filename")
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
	if mp.get_property_osd("chapter") ~= "" then
		chapter = mp.get_property_osd("chapter") .. " | "
	end

	if mp.get_property_osd("percent-pos") ~= "" then
		if mp.get_property_osd("percent-pos") ~= "100" then
			percent_pos = mp.get_property_osd("percent-pos") .. "% completed | "
			mp.set_property("force-media-title", playlist_num .. chapter .. percent_pos .. name)
		else
			mp.set_property("force-media-title", playlist_num .. chapter .. name)
		end
	end
end

mp.observe_property("percent-pos", "number", set_osd_title)
mp.observe_property("chapter", "string", set_osd_title)
