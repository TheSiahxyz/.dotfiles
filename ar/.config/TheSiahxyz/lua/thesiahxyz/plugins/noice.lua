return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = "MunifTanjim/nui.nvim",
	opts = {
		cmdline = {
			enabled = true, -- enables the Noice cmdline UI
			view = "cmdline",
		},
		messages = {
			enabled = true,
			view = "mini", -- default view for messages
			view_error = "messages", -- view for errors
			view_warn = "notify", -- view for warnings
			view_history = "messages", -- view for :messages
			view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
		},
		lsp = {
			progress = { enabled = false },
			message = { enabled = false },
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					any = {
						{ find = "%d+L, %d+B" },
						{ find = "; after #%d+" },
						{ find = "; before #%d+" },
						{ find = "%d fewer lines" },
						{ find = "%d more lines" },
					},
				},
				opts = { skip = true },
			},
			{
				filter = { event = "lsp", kind = "progress" },
				opts = { skip = true },
			},
		},
	},
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n", "v" },
			{ "<leader>n", group = "Noice" },
		})
	end,
	keys = {
		{
			"<leader>nd",
			function()
				require("noice").cmd("dismiss")
			end,
			desc = "Dismiss",
		},
		{
			"<leader>ne",
			function()
				require("noice").cmd("errors")
			end,
			desc = "Errors",
		},
		{
			"<leader>nh",
			function()
				require("noice").cmd("history")
			end,
			desc = "History",
		},
		{
			"<leader>nl",
			function()
				require("noice").cmd("last")
			end,
			desc = "Last",
		},
		{
			"<leader>nm",
			function()
				require("noice").cmd("telescope")
			end,
			desc = "Messages",
		},
		{
			"<leader>ns",
			function()
				require("noice").cmd("stats")
			end,
			desc = "Stats",
		},
	},
}
