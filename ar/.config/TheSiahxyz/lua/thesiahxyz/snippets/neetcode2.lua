local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local f = ls.function_node -- Import function_node for dynamic content

-- Function to get the filename without the path
local function get_filename()
	local filepath = vim.api.nvim_buf_get_name(0)
	local filename = vim.fn.fnamemodify(filepath, ":t:r") -- Get filename without path and extension
	return filename:gsub("_", " ") -- Replace underscores with spaces
end

local neetcode_snippet = s(
	"neetcode",
	fmt(
		[[
"""
Question

{1}
"""


from typing import Dict

class Solution:
    """
    A class to solve {file_name} from {2}
    """
    def {3}(self, {4}) -> {5}:
        """
        {file_name} from the input {parameters_type} using a {func_name} approach.

        Args:
            {parameters_type}: {6}

        Returns:
            {return_type}: {7}
        """
        return {8}

    def print(self, examples: Dict[str, {parameters_type}]) -> None:
        for name, (param1, param2) in examples.items():
            result = self.{3}(param1, param2)
            print(f"{{name}}: {{result}}")

    def main(self):
        cases = {{
            "case1" : ({9}),
            "case2" : ({10}),
            "case3" : ({11}),
        }}

        self.print(cases)



solution = Solution()
solution.main()

"""
Solution

url: {12}
video: {13}

1. {func_name}
time: {14}
space: {15}
code:
```python
{16}
```
"""
]],
		{
			i(1, '"Describe the question here"'),
			file_name = f(get_filename), -- Insert the filename dynamicall
			i(2, '"Describe the class here"'),
			i(3, '"Function name"'), -- Primary insert node for method name
			func_name = rep(3), -- Repeat the method name
			i(4, '"parameters"'),
			parameters_type = rep(4),
			i(5, '"return_type"'),
			return_type = rep(5),
			i(6, '"parameters_desc"'),
			i(7, '"return_type_desc"'),
			i(8, '"return"'),
			i(9, '"case1"'),
			i(10, '"case2"'),
			i(11, '"case3"'),
			i(12, '"url"'),
			i(13, '"video"'),
			i(14, '"time_complexity"'),
			i(15, '"space_complexity"'),
			i(16, '"code"'),
		}
	)
)

-- Add the snippets for multiple filetypes
ls.add_snippets("python", { neetcode_snippet })
