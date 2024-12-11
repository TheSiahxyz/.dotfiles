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
		local home = vim.fn.expand("~")
		vim.g.dbs = {
			mysql = "mariadb://user:password@localhost/mysql",
			postsql = "postgresql://postgres:mypassword@localhost:5432/postgresql",
			sqlite = "sqlite://" .. home .. "/.local/share/db/sqlite.db",
			firefox = "sqlite://" .. home .. "/.mozilla/firefox/si.default/places.sqlite",
		}
		local wk = require("which-key")
		wk.add({
			mode = { "n" },
			{ "<localleader>b", group = "DB" },
		})
	end,
	config = function()
		local function db_completion()
			require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
		end
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"sql",
				"mysql",
				"plsql",
			},
			callback = function()
				vim.schedule(db_completion)
			end,
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
