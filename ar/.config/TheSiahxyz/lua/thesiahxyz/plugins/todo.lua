return {
	{
		"vimichael/floatingtodo.nvim",
		config = function()
			require("floatingtodo").setup({
				target_file = "~/.local/share/vimwiki/todo.md",
				border = "single", -- single, rounded, etc.
				width = 0.8, -- width of window in % of screen size
				height = 0.8, -- height of window in % of screen size
				position = "center", -- topleft, topright, bottomleft, bottomright
			})

			vim.keymap.set("n", "<leader>tf", ":Td<CR>", { silent = true, desc = "TODO floating" })
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		cmd = { "TodoTrouble", "TodoTelescope" },
		config = function()
			require("todo-comments").setup()
		end,
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v" },
				{ "<leader>t", group = "TODO" },
			})
		end,
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next Todo Comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous Todo Comment",
			},
			{ "<leader>tt", "<cmd>Trouble todo toggle<cr>", desc = "Toggle TODO (Trouble)" },
			{
				"<leader>tT",
				"<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
				desc = "Toggle Todo/Fix/Fixme (Trouble)",
			},
			{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find Todo" },
			{ "<leader>fT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Find Todo/Fix/Fixme" },
		},
	},
}
