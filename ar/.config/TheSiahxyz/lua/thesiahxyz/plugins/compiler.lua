return {
	{ -- This plugin
		"Zeioth/compiler.nvim",
		cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
		dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
		opts = {},
		keys = {
			-- Open compiler
			vim.api.nvim_set_keymap(
				"n",
				"<leader>rR",
				"<cmd>CompilerOpen<cr>",
				{ noremap = true, silent = true, desc = "Open compiler" }
			),

			-- Redo last selected option
			vim.api.nvim_set_keymap(
				"n",
				"<leader>rc",
				"<cmd>CompilerStop<cr>" -- (Optional, to dispose all tasks before redo)
					.. "<cmd>CompilerRedo<cr>",
				{ noremap = true, silent = true, desc = "Recompile" }
			),
			-- Toggle compiler results
			vim.api.nvim_set_keymap(
				"n",
				"<leader>rt",
				"<cmd>CompilerToggleResults<cr>",
				{ noremap = true, silent = true, desc = "Toggle compiler" }
			),
		},
	},
	{ -- The task runner we use
		"stevearc/overseer.nvim",
		commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
		cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
		opts = {
			task_list = {
				direction = "bottom",
				min_height = 25,
				max_height = 25,
				default_detail = 1,
			},
		},
	},
}