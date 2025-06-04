return {
	{
		"vimwiki/vimwiki",
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n" },
				{ "<leader>w", group = "Vimwiki/Which-key" },
				{ "<leader>w<leader>", group = "Diary" },
			})

			-- Ensure files are read with the desired filetype
			vim.g.vimwiki_ext2syntax = {
				[".Rmd"] = "markdown",
				[".rmd"] = "markdown",
				[".md"] = "markdown",
				[".markdown"] = "markdown",
				[".mdown"] = "markdown",
			}

			-- Set up Vimwiki list
			vim.g.vimwiki_list = {
				{
					path = vim.fn.expand("~/.local/share/vimwiki"),
					syntax = "markdown",
					ext = ".md",
				},
			}
		end,
		keys = {
			{ "<leader>ww", ":VimwikiIndex<CR>", desc = "Vimwiki index" },
		},
	},
	{
		"tools-life/taskwiki",
		ft = "vimwiki",
		event = "VeryLazy",
		dependencies = {
			"vimwiki/vimwiki",
			"powerman/vim-plugin-AnsiEsc",
			"majutsushi/tagbar",
			"farseer90718/vim-taskwarrior",
		},
		config = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n" },
				{ "<leader>tb", group = "Burndown" },
				{ "<leader>tc", group = "Choose" },
				{ "<leader>tG", group = "Ghistory" },
				{ "<leader>th", group = "History" },
			})

			vim.g.taskwiki_markup_syntax = "markdown"
			vim.g.taskwiki_data_location = "~/.local/share/task"
		end,
	},
}
