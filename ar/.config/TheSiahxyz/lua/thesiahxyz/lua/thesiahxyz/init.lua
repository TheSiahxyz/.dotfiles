-- Core
require("thesiahxyz.core.autocmds")
require("thesiahxyz.core.keymaps")
require("thesiahxyz.core.options")
require("thesiahxyz.core.lazy")

-- Custom
for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/thesiahxyz/utils", [[v:val =~ '\.lua$']])) do
	require("thesiahxyz.utils." .. file:gsub("%.lua$", ""))
end

-- Plenary
function R(name)
	require("plenary.reload").reload_module(name)
end
