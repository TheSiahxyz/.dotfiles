return {
	{
		"nvzone/showkeys",
		cmd = "ShowkeysToggle",
		opts = {},
		keys = {
			{ "<leader>zk", "<Cmd>ShowkeysToggle<cr>", desc = "Toggle keys" },
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		cmd = "WhichKey",
		dependencies = { "echasnovski/mini.icons", "nvim-tree/nvim-web-devicons" },
		opts = {
			preset = "classic", -- false | "classic" | "modern" | "helix"
			keys = {
				scroll_down = "<c-e>",
				scroll_up = "<c-y>",
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.add({
				{
					mode = { "n", "v" },
					{ "g", group = "Goto" },
					{ "g`", group = "Marks" },
					{ "g'", group = "Marks" },
					{ "gr", group = "Lsp buf" },
					{ "gs", group = "Search/Surround" },
					{ "gx", desc = "Open with system app" },
					{ "s", group = "Surround/Search & replace on line" },
					{ "S", group = "Surround/Search & replace in file" },
					{ "z", group = "Fold" },
					{ "`", group = "Marks" },
					{ "'", group = "Marks" },
					{ '"', group = "Registers" },
					{ "]", group = "Next" },
					{ "]]", group = "Next" },
					{ "[", group = "Prev" },
					{ "[[", group = "Prev" },
					{ "=", group = "Line paste" },
					{ "<C-w>", group = "Windows" },
					{ "<leader>", group = "Leader" },
					{ "<leader>a", group = "Ascii" },
					{
						"<leader>b",
						group = "Buffer",
						expand = function()
							return require("which-key.extras").expand.buf()
						end,
					},
					{ "<leader>B", group = "Buffer (force)" },
					{ "<leader>C", group = "Goto realpath" },
					{ "<leader>d", group = "Delete" },
					{ "<leader>D", group = "Delete (blackhole)" },
					{ "<leader>e", group = "Explorer" },
					{ "<leader>i", group = "Inspect" },
					{ "<leader>l", group = "Location" },
					{ "<leader>L", group = "Lazy" },
					{ "<leader>M", group = "Mason" },
					{ "<leader>o", group = "Open" },
					{ "<leader>p", group = "Paste" },
					{ "<leader>P", group = "Paste" },
					{ "<leader>q", group = "Quit" },
					{ "<leader>rn", group = "Rename" },
					{ "<leader>sk", group = "Keys" },
					{ "<leader>S", group = "Save/Source" },
					{ "<leader>w", group = "Which-key" },
					{ "<leader>W", group = "Save all" },
					{ "<leader>z", group = "Toggle" },
					{ "<leader>Z", group = "All buffer" },
					{ "<leader><tab>", group = "Tabs" },
					{ "<localleader>", group = "Local Leader (bookmarks)" },
					{ "<localleader><leader>", group = "Bookmarks (explorer)" },
					{ "<localleader><localleader>", group = "Bookmarks (mini)" },
					{ "<localleader>t", group = "Task" },
				},
				{
					mode = { "n", "v", "x" },
					{ "gw", desc = "Visible in window" },
					{ "g%", desc = "Match backward" },
					{ "g;", desc = "Last change" },
					{ "<leader>Q", group = "Quit all" },
				},
				{
					mode = { "i" },
					{ "<C-o>", desc = "Execute one command" },
					{ "<C-r>", desc = "Paste from registers" },
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
					local ok, input = pcall(vim.fn.input, "WhichKey: ")
					if ok and input ~= "" then
						vim.cmd("WhichKey " .. input)
					end
				end,
				desc = "Which-key query lookup",
			},
			{
				"<leader>wK",
				"<Cmd>WhichKey<cr>",
				mode = { "n", "v", "x" },
				desc = "Which-key all key",
			},
		},
	},
}
