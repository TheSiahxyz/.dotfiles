return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		-- Your DBUI configuration
		vim.g.db_ui_use_nerd_fonts = 1
	end,
	keys = {
		{ "<localleader>db", "<cmd>DBUI<cr>", desc = "DB UI" },
		{ "<localleader>du", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
		{ "<localleader>da", "<cmd>DBUIAddConnection<cr>", desc = "Add connection" },
		{ "<localleader>df", "<cmd>DBUIFindBuffer<cr>", desc = "Find buffer" },
		{ "<localleader>dr", "<cmd>DBUIRenameBuffer<cr>", desc = "Rename buffer" },
		{ "<localleader>dl", "<cmd>DBUILastQueryInfo<cr>", desc = "Last query info" },
	},
}
