return {
	"folke/noice.nvim",
	event = "VeryLazy",
	config = function()
		require("noice").setup({
			cmdline = {
				enabled = false, -- Disable the Noice cmdline UI
			},
			messages = {
				enabled = false, -- Disable all messages except for search_count
				view_search = "virtualtext", -- Enable virtualtext for search count messages
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						kind = "",
						["not"] = { kind = { "search_count" } },
					},
					opts = { skip = true },
				},
			},
			presets = {
				long_message_to_split = false, -- Disable long message splitting
				inc_rename = false, -- Disable incremental renaming UI
				lsp_doc_border = false, -- Disable LSP documentation border
			},
		})
	end,
}
