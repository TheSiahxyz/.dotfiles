local ls = require("luasnip")

-- Using parse_snippet instead of fmt to avoid curly brace issues
local whichkey_snippet = ls.parser.parse_snippet(
	"whichkey",
	[[
init = function()
    local wk = require("which-key")
    wk.add({
        mode = { "n" },
        { "${1:Key}", group = "${2:Name}" },
    })
end,
]]
)

-- Add the snippets for the Lua filetype
ls.add_snippets("lua", { whichkey_snippet })
