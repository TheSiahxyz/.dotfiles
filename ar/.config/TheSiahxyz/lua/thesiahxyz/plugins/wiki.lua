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
			{ "<leader>wu", ":VimwikiUISelect<CR>", desc = "Vimwiki UI" },
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
	{
		"renerocksai/telekasten.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-telekasten/calendar-vim",
		},
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n" },
				{ "<leader>n", group = "Notes" },
			})
		end,
		config = function()
			require("telekasten").setup({
				home = vim.fn.expand("~/.local/share/vimwiki"), -- Put the name of your notes directory here
			})
		end,
		keys = {
			{
				"<leader>fn",
				function()
					require("telekasten").find_notes()
				end,
				desc = "Find notes",
			},
			{
				"<leader>np",
				function()
					require("telekasten").panel()
				end,
				desc = "Open note panel",
			},
			{
				"<leader>sn",
				function()
					require("telekasten").search_notes()
				end,
				desc = "Search notes",
			},
			{
				"<leader>nt",
				function()
					require("telekasten").goto_today()
				end,
				desc = "Goto today notes",
			},
			{
				"<leader>nl",
				function()
					require("telekasten").follow_link()
				end,
				desc = "Follow link",
			},
			{
				"<leader>nn",
				function()
					require("telekasten").new_note()
				end,
				desc = "Open new note",
			},
			{
				"<leader>tc",
				function()
					require("telekasten").show_calendar()
				end,
				desc = "Show calendar",
			},
			{
				"<leader>nb",
				function()
					require("telekasten").show_backlinks()
				end,
				desc = "Show backlinks",
			},
			{
				"<leader>ii",
				function()
					require("telekasten").insert_img_link()
				end,
				desc = "Insert image link",
			},
			{
				mode = "i",
				"]]",
				function()
					require("telekasten").insert_link()
				end,
				desc = "Insert link",
			},
		},
	},
}
