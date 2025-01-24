return {
	{
		"folke/trouble.nvim",
		cmd = { "Trouble" },
		opts = {
			modes = {
				lsp = {
					win = { position = "right" },
				},
				preview_float = {
					mode = "diagnostics",
					preview = {
						type = "float",
						relative = "editor",
						border = "rounded",
						title = "Preview",
						title_pos = "center",
						position = { 0, -2 },
						size = { width = 0.3, height = 0.3 },
						zindex = 200,
					},
				},
			},
		},
		config = function(_, opts)
			require("trouble").setup(opts)
		end,
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v", "x" },
				{ "<leader>x", group = "Quickfix (trouble)" },
			})
		end,
		keys = {
			{ "<leader>xd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle diagnostics (Trouble)" },
			{
				"<leader>xD",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Toggle buffer Diagnostics (Trouble)",
			},
			{ "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Toggle symbols (Trouble)" },
			{ "<leader>xS", "<cmd>Trouble lsp toggle<cr>", desc = "Toggle LSP def/ref/... (Trouble)" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Toggle location List (Trouble)" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Toggle quickfix List (Trouble)" },
			{
				"[x",
				function()
					if require("trouble").is_open() then
						require("trouble").prev({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous quickfix (trouble)",
			},
			{
				"]x",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next quickfix (trouble)",
			},
		},
	},
}
