return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	cmd = "WhichKey",
	opts = {},
	config = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n" },
			{ "g", desc = "+Goto" },
			{ "s", desc = "+Search and replace on line" },
			{ "S", desc = "+Search and replace in file" },
			{ "z", desc = "+Fold" },
			{ "`", desc = "+Marks" },
			{ "'", desc = "+Marks" },
			{ '"', desc = "+Registers" },
			{ "]", desc = "+Next" },
			{ "[", desc = "+Prev" },
			{ "=", desc = "+Line paste" },
			{ "\\", desc = "+Local Leader (bookmarks)" },
			{ "\\\\", desc = "+Bookmarks" },
			{ "<C-w>", desc = "+Windows" },
			{ "<leader>", desc = "+Leader" },
			{ "<leader>.", desc = "+cd .." },
			{ "<leader>b", desc = "+Buffer" },
			{ "<leader>e", desc = "+Explorer" },
			{ "<leader>i", desc = "+Inspect" },
			{ "<leader>l", desc = "+Location" },
			{ "<leader>L", desc = "+Lazy" },
			{ "<leader>M", desc = "+Mason" },
			{ "<leader>o", desc = "+Open" },
			{ "<leader>q", desc = "+Quit" },
			{ "<leader>Q", desc = "+Quit all" },
			{ "<leader>w", desc = "+Save/Which Key" },
			{ "<leader>W", desc = "+Save all" },
		})
		wk.add({
			mode = { "n", "v", "x" },
			{ "<leader>Q", desc = "+Quit" },
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
			"<cmd>WhichKey <CR>",
			desc = "Which-key all key",
		},
	},
}
