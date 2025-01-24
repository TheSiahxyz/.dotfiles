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
		dependencies = {
			"neovim/nvim-lspconfig",
			"mfussenegger/nvim-dap",
			"mfussenegger/nvim-dap-python", --optional
			{ "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
		},
		lazy = false,
		branch = "regexp", -- This is the regexp branch, use this for the new version
		ft = "python",
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v" },
				{ "<leader>v", group = "Virtual envs" },
			})
		end,
		config = function()
			require("venv-selector").setup({
				settings = {
					options = {
						notify_user_on_venv_activation = true,
					},
					search = {
						venvs = {
							command = "fd /bin/python$ ~/.local/share/venvs --full-path",
						},
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
