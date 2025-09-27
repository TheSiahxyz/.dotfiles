local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local f = ls.function_node

local fmt = require("luasnip.extras.fmt").fmta

-- get weather from wttr.in
local function get_weather()
	local q = os.getenv("JOURNAL_WEATHER_QUERY")
	local url = q and ("wttr.in/" .. q .. "?format=1") or "wttr.in/?format=1"
	local handle = io.popen(("curl -m 2 -s '%s'"):format(url))
	if not handle then
		return ""
	end
	local result = handle:read("*a") or ""
	handle:close()
	return (result:gsub("[\r\n]", ""))
end

local journal_snippet = s(
	"journal",
	fmt(
		[[---
title: <title>
date: <date>
tags: [diary, journal]
mood: <mood>
weather: <weather>
---

# Daily Journal

## Diary (Personal Events & Feelings)
- What happened today?
- How did I feel?
- Memorable moments

## Journal (Learning & Reflections)
- What I learned today
- Challenges faced
- Ideas & inspirations

## Plans for Tomorrow
- <plans>

## Gratitude
- <gratitude>
]],
		{
			title = i(1, "My Journal"),
			date = f(function()
				return os.date("%Y-%m-%d")
			end, {}),
			mood = c(2, {
				i(nil, ""), -- default: manual input
				t("😊 happy"),
				t("😢 sad"),
				t("😴 tired"),
				t("😤 stressed"),
				t("😌 relaxed"),
				t("🤩 excited"),
				t("😟 anxious"),
				t("🎯 focused"),
				t("😐 neutral"),
				t("🙏 grateful"),
				t("🤒 sick"),
				t("😡 angry"),
				t("🌊 calm"),
				t("😵 overwhelmed"),
				t("💪 motivated"),
				t("🥱 bored"),
			}),
			weather = f(get_weather, {}),
			plans = i(3),
			gratitude = i(4),
		}
	)
)

ls.add_snippets("markdown", { journal_snippet })
ls.add_snippets("quarto", { journal_snippet })
