-- Core
require("TheSiahxyz.core.options")
require("TheSiahxyz.core.keymaps")
require("TheSiahxyz.core.autocmds")
require("TheSiahxyz.core.lazy")

-- Custom
for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/TheSiahxyz/utils", [[v:val =~ '\.lua$']])) do
	require("TheSiahxyz.utils." .. file:gsub("%.lua$", ""))
end

-- Plenary
function R(name)
	require("plenary.reload").reload_module(name)
end
