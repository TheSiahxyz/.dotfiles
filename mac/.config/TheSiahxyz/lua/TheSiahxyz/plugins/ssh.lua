return {
	"amitds1997/remote-nvim.nvim",
	version = "*", -- Pin to GitHub releases
	dependencies = {
		"nvim-lua/plenary.nvim", -- For standard functions
		"MunifTanjim/nui.nvim", -- To build the plugin UI
		"nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
	},
	config = true,
	init = function()
		local wk = require("which-key")
		wk.add({
			{ "<localleader>r", group = "SSH Remote" },
		})
	end,
	keys = {
		{
			"<localleader>rs",
			"<cmd>RemoteStart<CR>",
			desc = "Start/Connect",
			mode = "n",
			silent = true,
		},
		{
			"<localleader>rx",
			"<cmd>RemoteStop<CR>",
			desc = "Stop/Close",
			mode = "n",
			silent = true,
		},
		{
			"<localleader>ri",
			"<cmd>RemoteInfo<CR>",
			desc = "Info/Progress Viewer",
			mode = "n",
			silent = true,
		},
		{
			"<localleader>rc",
			"<cmd>RemoteCleanup<CR>",
			desc = "Cleanup workspace/setup",
			mode = "n",
			silent = true,
		},
		{
			"<localleader>rd",
			"<cmd>RemoteConfigDel<CR>",
			desc = "Delete saved config",
			mode = "n",
			silent = true,
		},
		{
			"<localleader>rl",
			"<cmd>RemoteLog<CR>",
			desc = "Open log",
			mode = "n",
			silent = true,
		},
	},
}
