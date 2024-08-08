local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local neetcode_snippet = s(
	"neetcode",
	fmt(
		[[
"""
Question

{1}
"""


class Solution:
    def {2}(self, {3}) -> {4}:



case1 = {5}
case2 = {6}
case3 = {7}

solution = Solution()
print(f" {fn} case1: {{solution.{fn}(case1, {args})}}")
print(f" {fn} case2: {{solution.{fn}(case2, {args})}}")
print(f" {fn} case3: {{solution.{fn}(case3, {args})}}")


"""
Solution

url: {8}
video: {9}
code: {10}


"""
]],
		{
			i(1, "Describe the question here"),
			i(2, "function name"), -- Primary insert node for method name
			fn = rep(2), -- Repeat the method name
			i(3, "parameters"),
			args = rep(3),
			i(4, "return type"),
			i(5, "case1"),
			i(6, "case2"),
			i(7, "case3"),
			i(8, "url"),
			i(9, "video"),
			i(10, "code"),
		}
	)
)

-- Add the snippets for multiple filetypes
ls.add_snippets("python", { neetcode_snippet })
