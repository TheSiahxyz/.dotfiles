-- keep-window-size.lua
-- Preserves window size when playlist advances to the next file.

local saved_w = nil
local restoring = false

mp.observe_property("osd-width", "number", function(_, w)
    if w and w > 0 and not restoring then
        saved_w = w
    end
end)

mp.register_event("video-reconfig", function()
    if not saved_w then return end
    local dw = mp.get_property_number("dwidth")
    if dw and dw > 0 then
        restoring = true
        mp.set_property_number("window-scale", saved_w / dw)
        mp.add_timeout(0.3, function()
            restoring = false
        end)
    end
end)
