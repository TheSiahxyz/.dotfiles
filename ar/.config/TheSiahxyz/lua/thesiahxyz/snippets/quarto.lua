local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
-- local d = ls.dynamic_node
local c = ls.choice_node
-- local f = ls.function_node
-- local r = ls.restore_node
local fmt = require("luasnip.extras.fmt").fmta
-- local h = require("thesiahxyz.utils.snippet")

local code_cell_snippet = s(
	"`",
	fmt(
		[[```<lang>
<last>
``]],
		{
			lang = c(1, { t("python"), t("") }),
			last = i(0), -- Place cursor here after expanding the snippet
		}
	)
)

-- Add the snippets for multiple filetypes
ls.add_snippets("markdown", { code_cell_snippet })
ls.add_snippets("quarto", { code_cell_snippet })
