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
  <happened>
- How did I feel?
  <feeling>
- Memorable moments
  <moments>

## Journal (Learning & Reflections)

- What I learned today
  <learned>
- Challenges faced
  <challenges>
- Ideas & inspirations
  <ideas>

## Plans for Tomorrow

- <plans>

## Gratitude

1. <gratitude1>
2. <gratitude2>
3. <gratitude3>
4. <gratitude4>
5. <gratitude5>
6. <gratitude6>
7. <gratitude7>
8. <gratitude8>
9. <gratitude9>
10. <gratitude10>
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
			happened = i(3),
			feeling = i(4),
			moments = i(5),
			learned = i(6),
			challenges = i(7),
			ideas = i(8),
			plans = i(9),
			gratitude1 = i(10),
			gratitude2 = i(11),
			gratitude3 = i(12),
			gratitude4 = i(13),
			gratitude5 = i(14),
			gratitude6 = i(15),
			gratitude7 = i(16),
			gratitude8 = i(17),
			gratitude9 = i(18),
			gratitude10 = i(19),
		}
	)
)

ls.add_snippets("markdown", { journal_snippet })
ls.add_snippets("quarto", { journal_snippet })
