local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local t = ls.text_node
local d = ls.dynamic_node
local sn = ls.snippet_node

local fmt = require("luasnip.extras.fmt").fmta

local function bgm_node_generator()
	return function()
		local handle = io.popen("ssh root@thesiah.xyz 'ls /var/www/thesiah/bgm/' 2>/dev/null")
		if not handle then
			return sn(nil, { i(1, "bgm") })
		end

		local result = handle:read("*a")
		handle:close()

		if not result or result == "" then
			return sn(nil, { i(1, "bgm") })
		end

		local choices = {}
		for filename in result:gmatch("[^\r\n]+") do
			table.insert(choices, t(filename))
		end

		if #choices == 0 then
			return sn(nil, { i(1, "bgm") })
		end

		return sn(nil, { c(1, choices) })
	end
end

local diary_snippet = s(
	"diary",
	fmt(
		[[---
title: <title>
date: <date>
bgm: <bgm>
---

<story>
]],
		{
			title = i(1, "My Journal"),
			date = f(function()
				return os.date("%Y-%m-%d")
			end, {}),
			bgm = d(2, bgm_node_generator(), {}),
			story = i(3),
		}
	)
)

ls.add_snippets("markdown", { diary_snippet })
ls.add_snippets("quarto", { diary_snippet })
