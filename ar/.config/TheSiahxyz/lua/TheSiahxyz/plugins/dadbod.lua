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
			firefox = "sqlite://" .. home .. "/.mozilla/firefox/si.default/places.sqlite",
			librewolf = "sqlite://" .. home .. "/.librewolf/si.default/places.sqlite",
			mysql = "mariadb://user:password@localhost/mysql",
			postsql = "postgresql://postgres:mypassword@localhost:5432/postgresql",
			qutebrowser = "sqlite://" .. home .. "/.local/share/qutebrowser/history.sqlite",
			sqlite = "sqlite://" .. home .. "/.local/share/db/sqlite.db",
		}
		local wk = require("which-key")
		wk.add({
			mode = { "n" },
			{ "<localleader>d", group = "DB" },
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
		{ "<localleader>du", "<Cmd>DBUI<cr>", desc = "DB UI" },
		{ "<localleader>dt", "<Cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
		{ "<localleader>da", "<Cmd>DBUIAddConnection<cr>", desc = "Add connection" },
		{ "<localleader>df", "<Cmd>DBUIFindBuffer<cr>", desc = "Find buffer" },
		{ "<localleader>dr", "<Cmd>DBUIRenameBuffer<cr>", desc = "Rename buffer" },
		{ "<localleader>di", "<Cmd>DBUILastQueryInfo<cr>", desc = "Last query info" },
	},
}
