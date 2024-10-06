-- Core
require("thesiahxyz.core.autocmds")
require("thesiahxyz.core.keymaps")
require("thesiahxyz.core.options")
require("thesiahxyz.core.lazy")

-- Plenary
function R(name)
	require("plenary.reload").reload_module(name)
end
