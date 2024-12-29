return {
	"folke/noice.nvim",
	event = "VeryLazy",
	config = function()
		require("noice").setup({
			cmdline = {
				enabled = true, -- enables the Noice cmdline UI
				view = "cmdline",
			},
			messages = {
				view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
			},
			routes = {
				{
					filter = { event = "msg_show", kind = "messages" },
					opts = { skip = true },
				},
				{
					filter = { event = "msg_show", kind = "search" },
					opts = { skip = true },
				},
				{
					filter = {
						event = "msg_show",
						kind = "",
					},
					opts = { skip = true },
				},
			},
		})
	end,
}
