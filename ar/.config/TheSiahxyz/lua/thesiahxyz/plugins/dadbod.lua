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

		local wk = require("which-key")
		wk.add({
			mode = { "n", "v", "x" },
			{ "<localleader>b", group = "DB" },
		})
	end,
	keys = {
		{ "<localleader>bu", "<cmd>DBUI<cr>", desc = "DB UI" },
		{ "<localleader>bt", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
		{ "<localleader>ba", "<cmd>DBUIAddConnection<cr>", desc = "Add connection" },
		{ "<localleader>bf", "<cmd>DBUIFindBuffer<cr>", desc = "Find buffer" },
		{ "<localleader>br", "<cmd>DBUIRenameBuffer<cr>", desc = "Rename buffer" },
		{ "<localleader>bi", "<cmd>DBUILastQueryInfo<cr>", desc = "Last query info" },
	},
}
