local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function clipboard()
	return vim.fn.getreg("+")
end

-- #####################################################################
--                            Markdown
-- #####################################################################

-- Helper function to create code block snippets
local function create_code_block_snippet(lang)
	return s(lang, {
		t({ "```" .. lang, "" }),
		i(1),
		t({ "", "```" }),
	})
end

-- Define languages for code blocks
local languages = {
	"txt",
	"lua",
	"sql",
	"go",
	"regex",
	"bash",
	"markdown",
	"markdown_inline",
	"yaml",
	"json",
	"jsonc",
	"cpp",
	"csv",
	"java",
	"javascript",
	"python",
	"dockerfile",
	"html",
	"css",
	"templ",
	"php",
}

-- Generate snippets for all languages
local snippets = {}

for _, lang in ipairs(languages) do
	table.insert(snippets, create_code_block_snippet(lang))
end

table.insert(
	snippets,
	s({
		trig = "chirpy",
		name = "Disable markdownlint and prettier for chirpy",
	}, {
		t({
			" ",
			"<!-- markdownlint-disable -->",
			"<!-- prettier-ignore-start -->",
			" ",
			"<!-- tip=green, info=blue, warning=yellow, danger=red -->",
			" ",
			"> ",
		}),
		i(1),
		t({
			"",
			"{: .prompt-",
		}),
		-- In case you want to add a default value "tip" here, but I'm having
		-- issues with autosave
		-- i(2, "tip"),
		i(2),
		t({
			" }",
			" ",
			"<!-- prettier-ignore-end -->",
			"<!-- markdownlint-restore -->",
		}),
	})
)

table.insert(
	snippets,
	s({
		trig = "markdownlint",
		name = "Add markdownlint disable and restore headings",
	}, {
		t({
			" ",
			"<!-- markdownlint-disable -->",
			" ",
			"> ",
		}),
		i(1),
		t({
			" ",
			" ",
			"<!-- markdownlint-restore -->",
		}),
	})
)

table.insert(
	snippets,
	s({
		trig = "prettierignore",
		name = "Add prettier ignore start and end headings",
	}, {
		t({
			" ",
			"<!-- prettier-ignore-start -->",
			" ",
			"> ",
		}),
		i(1),
		t({
			" ",
			" ",
			"<!-- prettier-ignore-end -->",
		}),
	})
)

table.insert(
	snippets,
	s({
		trig = "link",
		name = "Add this -> []()",
	}, {
		t("["),
		i(1),
		t("]("),
		i(2),
		t(")"),
	})
)

table.insert(
	snippets,
	s({
		trig = "linkt",
		name = 'Add this -> [](){:target="_blank"}',
	}, {
		t("["),
		i(1),
		t("]("),
		i(2),
		t('){:target="_blank"}'),
	})
)

table.insert(
	snippets,
	s({
		trig = "todo",
		name = "Add TODO: item",
	}, {
		t("<!-- TODO: "),
		i(1),
		t(" -->"),
	})
)

-- Paste clipboard contents in link section, move cursor to ()
table.insert(
	snippets,
	s({
		trig = "linkclip",
		name = "Paste clipboard as .md link",
	}, {
		t("["),
		i(1),
		t("]("),
		f(clipboard, {}),
		t(")"),
	})
)

ls.add_snippets("markdown", snippets)
