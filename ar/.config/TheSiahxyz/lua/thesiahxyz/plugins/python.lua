return {
	-- {
	-- 	"bps/vim-textobj-python",
	-- 	dependencies = { "kana/vim-textobj-user" },
	-- },
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = {
			"nvim-neotest/neotest-python",
		},
		opts = {
			adapters = {
				["neotest-python"] = {
					-- Here you can specify the settings for the adapter, i.e.
					-- runner = "pytest",
					-- python = ".venv/bin/python",
				},
			},
		},
	},
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
		branch = "regexp", -- Use this branch for the new version
		event = "VeryLazy", -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
		ft = "python",
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v" },
				{ "<leader>v", group = "Venv" },
			})
		end,
		config = function()
			require("venv-selector").setup({
				-- Your options go here
				-- name = "venv",
				-- auto_refresh = false
				settings = {
					options = {
						notify_user_on_venv_activation = true,
					},
				},
			})
		end,
		keys = {
			{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select virtual env", ft = "python" },
			{ "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Select venv (cache)", ft = "python" },
		},
	},
}
