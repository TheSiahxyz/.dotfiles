local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local t = ls.text_node

local fmt = require("luasnip.extras.fmt").fmta

local function bgm_list()
	local handle = io.popen("ssh root@thesiah.xyz 'ls /var/www/thesiah/bgm/' 2>/dev/null")
	if not handle then
		return nil
	end

	local result = handle:read("*a")
	handle:close()

	if not result or result == "" then
		return nil
	end

	local choices = {}
	for filename in result:gmatch("[^\r\n]+") do
		table.insert(choices, t(filename))
	end

	if #choices == 0 then
		return nil
	end

	return choices
end

local bgm_choices = bgm_list()
local bgm_node = bgm_choices and c(2, bgm_choices) or i(2, "bgm")

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
			bgm = bgm_node,
			story = i(3),
		}
	)
)

ls.add_snippets("markdown", { diary_snippet })
ls.add_snippets("quarto", { diary_snippet })
