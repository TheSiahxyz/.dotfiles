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
		branch = "regexp", -- Use this branch for the new version
		cmd = "VenvSelect",
		opts = {
			settings = {
				options = {
					notify_user_on_venv_activation = true,
				},
			},
		},
		--  Call config for python files and load the cached venv automatically
		ft = "python",
		keys = { { "<localleader>v", "<cmd>VenvSelect<cr>", desc = "Select virtual env", ft = "python" } },
	},
}
