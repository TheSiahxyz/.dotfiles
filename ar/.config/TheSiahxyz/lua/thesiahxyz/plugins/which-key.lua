return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	cmd = "WhichKey",
	opts = {},
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "g", desc = "+Goto" },
			{ "gz", desc = "+Surround" },
			{ "z", desc = "+Fold" },
			{ "]", desc = "+Next" },
			{ "[", desc = "+Prev" },
			{ "=", desc = "+Line paste" },
			{ "\\", desc = "+Local Leader" },
			{ "<leader>", desc = "+Leader" },
			{ "<leader>1", desc = "Go to Harpoon List 1" },
			{ "<leader>2", desc = "Go to Harpoon List 2" },
			{ "<leader>3", desc = "Go to Harpoon List 3" },
			{ "<leader>4", desc = "Go to Harpoon List 4" },
			{ "<leader>5", desc = "Go to Harpoon List 5" },
			{ "<leader>a", desc = "Add Buffer to Harpoon List" },
			{ "<leader>b", desc = "+Buffer" },
			{ "<leader>c", desc = "+Format" },
			{ "<leader>d", desc = "+Diagnostics" },
			{ "<leader>f", desc = "+Find" },
			{ "<leader>g", desc = "+Git" },
			{ "<leader>j", desc = "+Molten (Jupyter)" },
			{ "<leader>o", desc = "+Open" },
			{ "<leader>r", desc = "+Refactoring" },
			{ "<leader>s", desc = "+Search" },
			{ "<leader>t", desc = "+Toggle" },
			{ "<leader>v", desc = "+View" },
			{ "<leader>w", desc = "+Which Key" },
			{ "<leader>x", desc = "+Harpoon Deletes" },
			{ "<leader>z", desc = "+Zenmode" },
		})
	end,
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
		{
			"<leader>wk",
			function()
				local input = vim.fn.input("WhichKey: ")
				vim.cmd("WhichKey " .. input)
			end,
			{ desc = "Which-key Query Lookup" },
		},
		{
			"<leader>wK",
			function()
				vim.cmd("WhichKey")
			end,
			{ desc = "Which-key All Key" },
		},
	},
}
