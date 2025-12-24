return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	config = function()
		require("nvim-treesitter").setup({
			install_dir = vim.fn.stdpath("data") .. "/treesitter",
		})
	end,
	keys = {
		{ "<leader>TU", ":TSUpdate<cr>", desc = "Update treesitter" },
		{
			"<leader>TI",
			function()
				require("nvim-treesitter").install({
					"bash",
					"c",
					"cpp",
					"dockerfile",
					"html",
					"java",
					"javascript",
					"json5",
					"latex",
					"lua",
					"markdown",
					"markdown_inline",
					"python",
					"sql",
					"vim",
					"vimdoc",
				})
			end,
			desc = "Update treesitter",
		},
	},
}
