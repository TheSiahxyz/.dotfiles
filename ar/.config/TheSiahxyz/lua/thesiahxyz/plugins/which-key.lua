return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	cmd = "WhichKey",
	opts = {},
	config = function()
		local wk = require("which-key")
		wk.add({
			{ mode = { "n", "v", "x" }, { "m", desc = "+Marks" } },
			{ mode = { "n", "v", "x" }, { "g", desc = "+Goto" } },
			{ mode = { "n", "v", "x" }, { "s", desc = "+Surround" } },
			{ mode = { "n", "v", "x" }, { "z", desc = "+Fold" } },
			{ mode = { "n", "v", "x" }, { "`", desc = "+Marks" } },
			{ mode = { "n", "v", "x" }, { "'", desc = "+Marks" } },
			{ mode = { "n", "v", "x" }, { '"', desc = "+Registers" } },
			{ mode = { "n", "v", "x" }, { "]", desc = "+Next" } },
			{ mode = { "n", "v", "x" }, { "[", desc = "+Prev" } },
			{ mode = { "n", "v", "x" }, { "=", desc = "+Line paste" } },
			{ mode = { "n", "v", "x" }, { "\\", desc = "+Local Leader (bookmarks)" } },
			{ mode = { "n", "v", "x" }, { "<C-w>", desc = "+Windows" } },
			{ mode = { "n", "v", "x" }, { "<M-x>", desc = "+Delete Harpoon List" } },
			{ mode = { "n", "v", "x" }, { "<leader>", desc = "+Leader" } },
			{ mode = { "n", "v", "x" }, { "<leader>b", desc = "+Buffer" } },
			{ mode = { "n", "v", "x" }, { "<leader>c", desc = "+Format" } },
			{ mode = { "n", "v", "x" }, { "<leader>d", desc = "+Diagnostics" } },
			{ mode = { "n", "v", "x" }, { "<leader>f", desc = "+Find" } },
			{ mode = { "n", "v", "x" }, { "<leader>fp", desc = "+Private/Public" } },
			{ mode = { "n", "v", "x" }, { "<leader>g", desc = "+Git" } },
			{ mode = { "n", "v", "x" }, { "<leader>G", desc = "+GPT" } },
			{ mode = { "n", "v", "x" }, { "<leader>Gg", desc = "+Gp" } },
			{ mode = { "n", "v", "x" }, { "<leader>GW", desc = "+Whisper" } },
			{ mode = { "n", "v", "x" }, { "<leader>j", desc = "+Molten (Jupyter)" } },
			{ mode = { "n", "v", "x" }, { "<leader>l", desc = "+Lazy" } },
			{ mode = { "n", "v", "x" }, { "<leader>m", desc = "+Mason" } },
			{ mode = { "n", "v", "x" }, { "<leader>o", desc = "+Open" } },
			{ mode = { "n", "v", "x" }, { "<leader>r", desc = "+Refactoring" } },
			{ mode = { "n", "v", "x" }, { "<leader>s", desc = "+Search" } },
			{ mode = { "n", "v", "x" }, { "<leader>sb", desc = "+Buffer" } },
			{ mode = { "n", "v", "x" }, { "<leader>t", desc = "+Toggle" } },
			{ mode = { "n", "v", "x" }, { "<leader>tf", desc = "+Format" } },
			{ mode = { "n", "v", "x" }, { "<leader>v", desc = "+View" } },
			{ mode = { "n", "v", "x" }, { "<leader>w", desc = "+Which Key" } },
			{ mode = { "n", "v", "x" }, { "<leader>z", desc = "+Zenmode" } },
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
