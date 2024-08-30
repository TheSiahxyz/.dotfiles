return {
	"folke/trouble.nvim",
	cmd = { "Trouble" },
	opts = {
		modes = {
			lsp = {
				win = { position = "right" },
			},
		},
	},
	keys = {
		{ "<leader>td", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle diagnostics (Trouble)" },
		{
			"<leader>tD",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Toggle buffer Diagnostics (Trouble)",
		},
		{ "<leader>ts", "<cmd>Trouble symbols toggle<cr>", desc = "Toggle symbols (Trouble)" },
		{ "<leader>tS", "<cmd>Trouble lsp toggle<cr>", desc = "Toggle LSP references/definitions/... (Trouble)" },
		{ "<leader>tl", "<cmd>Trouble loclist toggle<cr>", desc = "Toggle location List (Trouble)" },
		{ "<leader>tq", "<cmd>Trouble qflist toggle<cr>", desc = "Toggle quickfix List (Trouble)" },
		{
			"<leader>[tq",
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
			desc = "Previous Trouble/Quickfix Item",
		},
		{
			"<leader>]tq",
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
			desc = "Next Trouble/Quickfix Item",
		},
	},
}
