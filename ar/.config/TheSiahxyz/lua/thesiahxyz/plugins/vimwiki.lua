return {
	{
		"vimwiki/vimwiki",
		cmd = {
			"VimwikiIndex",
			"VimwikiDeleteFile",
			"Vimwiki2HTML",
			"VimwikiAll2HTML",
			"Vimwiki2HTMLBrowse",
			"VimwikiGoto",
			"VimwikiRenameFile",
			"VimwikiSplitLink",
			"VimwikiVSplitLink",
			"VimwikiColorize",
			"VimwikiDiaryGenerateLinks",
		},
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n" },
				{ "<leader>w", group = "Vimwiki" },
				{ "<leader>w<leader>", group = "Diary" },
			})
		end,
		config = function()
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
		cmd = { "TaskWikiInfo", "TaskWikiSummary", "TaskWikiStart", "TaskWikiMod" },
		dependencies = {
			"vimwiki/vimwiki",
			"powerman/vim-plugin-AnsiEsc",
			"majutsushi/tagbar",
			"farseer90718/vim-taskwarrior",
		},
		config = function()
			require("taskwiki").setup()
			vim.keymap.set("n", "<leader>tvi", ":TaskWikiInfo<CR>", { desc = "Task wiki info" })
			vim.keymap.set("n", "<leader>tvS", ":TaskWikiSummary<CR>", { desc = "Task wiki summary" })
			vim.keymap.set("n", "<leader>tvm", ":TaskWikiMod<CR>", { desc = "Task wiki modify" })
			vim.keymap.set("n", "<leader>tvs", ":TaskWikiMod<CR>", { desc = "Task wiki modify" })
		end,
	},
}
