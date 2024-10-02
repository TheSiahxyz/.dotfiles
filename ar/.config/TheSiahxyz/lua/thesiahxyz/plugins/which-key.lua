return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	cmd = "WhichKey",
	dependencies = { "echasnovski/mini.icons", "nvim-tree/nvim-web-devicons" },
	opts = {},
	config = function()
		local wk = require("which-key")
		wk.setup({
			keys = {
				scroll_down = "<c-e>",
				scroll_up = "<c-y>",
			},
		})
		wk.add({
			{
				mode = { "n", "v" },
				{ "g", group = "Goto" },
				{ "g`", group = "Marks" },
				{ "g'", group = "Marks" },
				{ "gs", group = "Search/Surround" },
				{ "s", group = "Search and replace on line" },
				{ "S", group = "Search and replace in file" },
				{ "z", group = "Fold" },
				{ "`", group = "Marks" },
				{ "'", group = "Marks" },
				{ '"', group = "Registers" },
				{ "]", group = "Next" },
				{ "[", group = "Prev" },
				{ "=", group = "Line paste" },
				{ "\\", group = "Local Leader (bookmarks)" },
				{ "\\\\", group = "Bookmarks" },
				{ "gx", desc = "Open with system app" },
				{ "<C-w>", group = "Windows" },
				{ "<leader>", group = "Leader" },
				{ "<leader>.", group = "cd .." },
				{
					"<leader>b",
					group = "Buffer",
					expand = function()
						return require("which-key.extras").expand.buf()
					end,
				},
				{ "<leader>B", group = "Force buffer" },
				{ "<leader>c", group = "Ascii/Goto" },
				{ "<leader>C", group = "Goto realpath" },
				{ "<leader>e", group = "Explorer" },
				{ "<leader>i", group = "Inspect" },
				{ "<leader>l", group = "Location" },
				{ "<leader>L", group = "Lazy" },
				{ "<leader>M", group = "Mason" },
				{ "<leader>o", group = "Open" },
				{ "<leader>q", group = "Quit" },
				{ "<leader>R", group = "Refresh" },
				{ "<leader>sk", group = "Keys" },
				{
					"<leader>w",
					group = "Save/Windows/Which-key",
					proxy = "<c-w>",
					expand = function()
						return require("which-key.extras").expand.win()
					end,
				},
				{ "<leader>W", group = "Save all" },
				{ "<leader><tab>", group = "Tabs" },
			},
			{
				mode = { "n", "v", "x" },
				{ "gw", desc = "Visible in window" },
				{ "g%", desc = "Match backward" },
				{ "g;", desc = "Last change" },
				{ "<leader>Q", group = "Quit all" },
			},
		})
	end,
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer local keymaps (which-key)",
		},
		{
			"<leader>wk",
			function()
				vim.cmd("WhichKey " .. vim.fn.input("WhichKey: "))
			end,
			desc = "Which-key query lookup",
		},
		{
			mode = { "n", "v", "x" },
			"<leader>wK",
			"<cmd>WhichKey<CR>",
			desc = "Which-key all key",
		},
	},
}
