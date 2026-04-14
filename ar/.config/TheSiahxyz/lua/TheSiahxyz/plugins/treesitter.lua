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
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n" },
			{ "<leader>T", group = "Treesitter" },
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
					"css",
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
					"rust",
					"sql",
					"tsx",
					"typescript",
					"vim",
					"vimdoc",
				})
			end,
			desc = "Install treesitter",
		},
	},
}
