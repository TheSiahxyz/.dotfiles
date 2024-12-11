return {
	{ "nvim-lua/plenary.nvim" },
	{
		"alexghergh/nvim-tmux-navigation",
		config = function()
			local nvim_tmux_nav = require("nvim-tmux-navigation")

			vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft, { desc = "Tmux navigator left" })
			vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown, { desc = "Tmux navigator down" })
			vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp, { desc = "Tmux navigator up" })
			vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight, { desc = "Tmux navigator right" })
			vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive, { desc = "Tmux navigator prev" })
			vim.keymap.set("n", "<A-n>", nvim_tmux_nav.NvimTmuxNavigateNext, { desc = "Tmux navigator next" })
		end,
	},
}
