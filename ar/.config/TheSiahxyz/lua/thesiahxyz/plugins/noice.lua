return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- add any options here
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		"rcarriga/nvim-notify",
	},
	config = function()
		require("noice").setup({
			cmdline = {
				view = "cmdline",
			},
			messages = {
				-- NOTE: If you enable messages, then the cmdline is enabled automatically.
				-- This is a current Neovim limitation.
				enabled = true, -- enables the Noice messages UI
				view = false, -- default view for messages
				view_error = "notify", -- view for errors
				view_warn = "notify", -- view for warnings
				view_history = "messages", -- view for :messages
				view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
			},
		})
	end,
	keys = {
		{ "<leader>fn", "<cmd>Noice telescope<cr>", desc = "Find noice" },
		{ "<leader>nc", "<cmd>Noice<cr>", desc = "Noice" },
		{ "<leader>nd", "<cmd>Noice dismiss<cr>", desc = "Noice dismiss" },
		{ "<leader>ne", "<cmd>Noice errors<cr>", desc = "Noice error" },
		{ "<leader>nl", "<cmd>Noice last<cr>", desc = "Noice last" },
		{ "<leader>ns", "<cmd>Noice stats<cr>", desc = "Noice stats" },
	},
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n", "v" },
			{ "<leader>n", group = "Noice" },
		})
	end,
}
