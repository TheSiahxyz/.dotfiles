return {
	{
		"numToStr/Comment.nvim",
		lazy = false,
		opts = {},
		config = function()
			require("Comment").setup()
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
		keys = {
			{
				"<leader>]td",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next Todo Comment",
			},
			{
				"<leader>[td",
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
