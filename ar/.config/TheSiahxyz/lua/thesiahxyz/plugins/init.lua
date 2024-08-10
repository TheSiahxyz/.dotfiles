return {
	{ "nvim-lua/plenary.nvim" },
	{
		"christoomey/vim-tmux-navigator",
		keys = {
			{ "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Tmux navigator left" },
			{ "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Tmux navigator down" },
			{ "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Tmux navigator up" },
			{ "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Tmux navigator right" },
			{ "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Tmux navigator previous" },
		},
	},
}
