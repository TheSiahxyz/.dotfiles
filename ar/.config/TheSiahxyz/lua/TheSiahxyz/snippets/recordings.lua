local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node

local fmt = require("luasnip.extras.fmt").fmta

local recordings_snippet = s(
	"recordings",
	fmt(
		[[---
title: <title>
date: <date>
---

<story>
]],
		{
			title = i(1, "My Journal"),
			date = f(function()
				return os.date("%Y-%m-%d")
			end, {}),
			story = i(3),
		}
	)
)

ls.add_snippets("markdown", { recordings_snippet })
ls.add_snippets("quarto", { recordings_snippet })
