return {
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
	keys = {
		{ "<leader>v-", ":VimwikiVSplitLink<CR>", { silent = true, desc = "Vertical split" } },
		{
			"<leader>v|",
			":VimwikiSplitLink<CR>",
			{ silent = true, desc = "Horizontal split" },
		},
		{
			"<leader>va",
			":VimwikiAll2HTML<CR>",
			{ silent = true, desc = "All vimwiki to html" },
		},
		{
			"<leader>vc",
			":VimwikiColorize<CR>",
			{ silent = true, desc = "Colorize line or selection" },
		},
		{
			"<leader>vd",
			":VimwikiDeleteFile<CR>",
			{ silent = true, desc = "Delete wiki page" },
		},
		{ "<leader>vh", ":Vimwiki2HTML<CR>", { silent = true, desc = "Vimwiki to html" } },
		{
			"<leader>vH",
			":Vimwiki2HTMLBrowse<CR>",
			{ silent = true, desc = "Convert current wiki to html" },
		},
		{ "<leader>vw", ":VimwikiIndex<CR>", { silent = true, desc = "Vimwiki index" } },
		{
			"<leader>vn",
			":VimwikiGoto<CR>",
			{ silent = true, desc = "Goto or create new wiki page" },
		},
		{
			"<leader>vr",
			":VimwikiRenameFile<CR>",
			{ silent = true, desc = "Rename wiki page" },
		},
		{ "<leader>vu", ":VimwikiDiaryGenerateLinks<CR>", { silent = true, desc = "Update diary" } },
	},
}
