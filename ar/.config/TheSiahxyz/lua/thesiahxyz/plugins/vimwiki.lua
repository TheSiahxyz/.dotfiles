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
				{ "<leader>v", group = "Vimwiki" },
			})
		end,
		keys = {
			{
				"<leader>v|",
				":VimwikiSplitLink<CR>",
				desc = "Horizontal split",
			},
			{ "<leader>v-", ":VimwikiVSplitLink<CR>", desc = "Vertical split" },
			{
				"<leader>va",
				":VimwikiAll2HTML<CR>",
				desc = "All vimwiki to html",
			},
			{
				"<leader>vc",
				":VimwikiColorize<CR>",
				desc = "Colorize line or selection",
			},
			{
				"<leader>vd",
				":VimwikiDeleteFile<CR>",
				desc = "Delete wiki page",
			},
			{ "<leader>vh", ":Vimwiki2HTML<CR>", desc = "Vimwiki to html" },
			{
				"<leader>vH",
				":Vimwiki2HTMLBrowse<CR>",
				desc = "Convert current wiki to html",
			},
			{ "<leader>vw", ":VimwikiIndex<CR>", desc = "Vimwiki index" },
			{
				"<leader>vn",
				":VimwikiGoto<CR>",
				desc = "Goto or create new wiki page",
			},
			{
				"<leader>vr",
				":VimwikiRenameFile<CR>",
				desc = "Rename wiki page",
			},
			{ "<leader>vu", ":VimwikiDiaryGenerateLinks<CR>", desc = "Update diary" },
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
