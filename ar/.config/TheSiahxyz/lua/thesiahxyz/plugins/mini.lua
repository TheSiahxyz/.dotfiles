return {
	{
		"echasnovski/mini.files",
		version = false,
		config = function()
			require("mini.files").setup()
		end,
		keys = {
			{
				"<leader>E",
				"<cmd>lua MiniFiles.open()<cr>",
				desc = "Open mini files",
			},
		},
	},
	{
		"echasnovski/mini.pairs",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("mini.pairs").setup()
		end,
		keys = {
			{
				"<leader>tp",
				function()
					vim.g.minipairs_disable = not vim.g.minipairs_disable
				end,
				desc = "Toggle auto pairs",
			},
		},
	},
}
