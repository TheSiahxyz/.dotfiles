return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	cmd = "WhichKey",
	opts = {},
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "m", desc = "+Marks" },
			{ "g", desc = "+Goto" },
			{ "s", desc = "+Surround" },
			{ "z", desc = "+Fold" },
			{ "`", desc = "+Marks" },
			{ "'", desc = "+Marks" },
			{ '"', desc = "+Registers" },
			{ "]", desc = "+Next" },
			{ "[", desc = "+Prev" },
			{ "=", desc = "+Line paste" },
			{ "\\", desc = "+Local Leader (bookmarks)" },
			{ "<C-w>", desc = "+Windows" },
			{ "<M-x>", desc = "+Delete Harpoon List" },
			{ "<leader>", desc = "+Leader" },
			{ "<leader>b", desc = "+Buffer" },
			{ "<leader>c", desc = "+Format" },
			{ "<leader>d", desc = "+Diagnostics" },
			{ "<leader>f", desc = "+Find" },
			{ "<leader>fp", desc = "+Private/Public" },
			{ "<leader>g", desc = "+Git" },
			{ "<leader>G", desc = "+GPT" },
			{ "<leader>Gg", desc = "+Gp" },
			{ "<leader>GW", desc = "+Whisper" },
			{ "<leader>j", desc = "+Molten (Jupyter)" },
			{ "<leader>l", desc = "+Lazy" },
			{ "<leader>m", desc = "+Mason" },
			{ "<leader>o", desc = "+Open" },
			{ "<leader>r", desc = "+Refactoring" },
			{ "<leader>s", desc = "+Search" },
			{ "<leader>sb", desc = "+Buffer" },
			{ "<leader>t", desc = "+Toggle" },
			{ "<leader>tf", desc = "+Format" },
			{ "<leader>v", desc = "+View" },
			{ "<leader>w", desc = "+Which Key" },
			{ "<leader>z", desc = "+Zenmode" },
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
			"<leader>wK",
			"<cmd>WhichKey <CR>",
			desc = "Which-key all key",
		},
	},
}
