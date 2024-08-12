local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
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
        return {5}



case1 = {6}
case2 = {7}
case3 = {8}

solution = Solution()
print(f" {fn} case1: {{solution.{fn}(case1)}}")
print(f" {fn} case2: {{solution.{fn}(case2)}}")
print(f" {fn} case3: {{solution.{fn}(case3)}}")


"""
Solution

url: {9}
video: {10}
code:
    {11}
"""
]],
		{
			i(1, "Describe the question here"),
			i(2, "fn_name"), -- Primary insert node for method name
			fn = rep(2), -- Repeat the method name
			i(3, "parameters"),
			i(4, "return_type"),
			i(5, "return"),
			i(6, "case1"),
			i(7, "case2"),
			i(8, "case3"),
			i(9, "url"),
			i(10, "video"),
			i(11, "code"),
		}
	)
)

-- Add the snippets for multiple filetypes
ls.add_snippets("python", { neetcode_snippet })
