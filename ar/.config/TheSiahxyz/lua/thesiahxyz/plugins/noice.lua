return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		-- "rcarriga/nvim-notify",
	},
	opts = {
		cmdline = {
			enabled = true, -- enables the Noice cmdline UI
			view = "cmdline",
			format = {
				cmdline = false,
				search_down = false,
				search_up = false,
				filter = false,
				lua = false,
				help = false,
			},
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
		views = {
			mini = {
				timeout = 5000,
				align = "center",
				position = {
					-- Centers messages top to bottom
					row = "98%",
					-- Aligns messages to the far right
					col = "0%",
				},
			},
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
						{ find = "written" },
					},
				},
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
				require("noice").cmd("all")
			end,
			desc = "All",
		},
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
