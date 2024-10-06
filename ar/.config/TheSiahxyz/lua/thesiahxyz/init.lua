-- Core
require("thesiahxyz.core.autocmds")
require("thesiahxyz.core.keymaps")
require("thesiahxyz.core.options")
require("thesiahxyz.core.lazy")

-- Plenary
function R(name)
	require("plenary.reload").reload_module(name)
end

-- Source shortcuts from bm-files and bm-folders
local shortcuts_file = vim.fn.expand("~/.config/nvim/shortcuts.lua")
local file = io.open(shortcuts_file, "r")
if file then
	file:close()
	vim.cmd("silent! source " .. shortcuts_file)
end
