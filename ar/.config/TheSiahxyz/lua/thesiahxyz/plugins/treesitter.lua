return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	config = function()
		require("nvim-treesitter.configs").setup({
			-- A list of parser names, or "all"
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"dockerfile",
				"html",
				"java",
				"json5",
				"latex",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"sql",
				"vim",
				"vimdoc",
			},

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = true,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
			auto_install = true,

			-- List of parsers to ignore installing (or "all")
			ignore_install = {},

			highlight = {
				-- `false` will disable the whole extension
				enable = true,
				disable = { "csv" },
				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = { "markdown" },
			},
		})

		local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
		treesitter_parser_config.templ = {
			install_info = {
				url = "https://github.com/vrischmann/tree-sitter-templ.git",
				files = { "src/parser.c", "src/scanner.c" },
				branch = "master",
			},
		}

		vim.treesitter.language.register("templ", "templ")
	end,
	keys = {
		{ "<leader>T", ":TSUpdate<cr>", desc = "Update treesitter" },
	},
}
