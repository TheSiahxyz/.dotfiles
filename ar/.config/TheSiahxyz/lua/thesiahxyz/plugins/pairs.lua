return {
	"echasnovski/mini.pairs",
	version = "*",
	event = "VeryLazy",
	config = function()
		require("mini.pairs").setup()
		vim.keymap.set("n", "<leader>up", function()
			vim.g.minipairs_disable = not vim.g.minipairs_disable
		end, { desc = "Toggle Auto Pairs" })
	end,
}
