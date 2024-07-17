return {
	{
		"GCBallesteros/jupytext.nvim",
		-- Depending on your nvim distro or config you may need to make the loading not lazy
		lazy = false,
		config = function()
			require("jupytext").setup({
				style = "markdown",
				output_extension = "md",
				force_ft = "markdown",
			})
		end,
	},
	{
		"vhyrro/luarocks.nvim",
		priority = 1001, -- this plugin needs to run before anything else
		opts = {
			rocks = { "magick" },
		},
	},
	{
		"3rd/image.nvim",
		opts = {
			backend = "ueberzug", -- whatever backend you would like to use
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
		config = function()
			require("image").setup({})
		end,
	},
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			"jmbuhr/otter.nvim",
			lazy = false,
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
			opts = {},
			config = function()
				require("otter").setup()
			end,
		},
		ft = { "quarto", "markdown" },
		command = "QuartoActivate",
		config = function()
			require("quarto").setup({
				lspFeatures = {
					languages = { "r", "python", "rust" },
					chunks = "all",
					diagnostics = {
						enabled = true,
						triggers = { "BufWritePost" },
					},
					completion = {
						enabled = true,
					},
				},
				keymap = {
					hover = "H",
					definition = "gd",
					rename = "<leader>rn",
					references = "gr",
					format = "<leader>gf",
				},
				codeRunner = {
					enabled = true,
					default_method = "molten",
				},
			})
			local runner = require("quarto.runner")
			vim.keymap.set("n", "<leader>jc", runner.run_cell, { silent = true })
			vim.keymap.set("n", "<leader>jC", runner.run_above, { silent = true })
			vim.keymap.set("n", "<leader>jl", runner.run_line, { silent = true })
			vim.keymap.set("v", "<leader>jv", runner.run_range, { silent = true })
			vim.keymap.set("n", "<leader>ja", runner.run_all, { silent = true })
			vim.keymap.set("n", "<leader>jA", function()
				runner.run_all(true)
			end, { silent = true })
		end,
	},
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			vim.g.molten_output_win_max_height = 20
			-- I find auto open annoying, keep in mind setting this option will require setting
			-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
			vim.g.molten_auto_open_output = false

			-- this guide will be using image.nvim
			-- Don't forget to setup and install the plugin if you want to view image outputs
			vim.g.molten_image_provider = "image.nvim"

			-- optional, I like wrapping. works for virt text and the output window
			vim.g.molten_wrap_output = true

			-- Output as virtual text. Allows outputs to always be shown, works with images, but can
			-- be buggy with longer images
			vim.g.molten_virt_text_output = true

			-- this will make it so the output shows up below the \`\`\` cell delimiter
			vim.g.molten_virt_lines_off_by_1 = true
		end,
		config = function()
			-- image nvim options table. Pass to `require('image').setup`
			vim.keymap.set("n", "<leader>jJ", ":MoltenInit<CR>", { silent = true })
			vim.keymap.set("n", "<leader>jo", ":MoltenEvaluateOperator<CR>", { silent = true })
			vim.keymap.set("n", "<leader>jL", ":MoltenEvaluateLine<CR>", { silent = true })
			vim.keymap.set("n", "<leader>jr", ":MoltenReevaluateCell<CR>", { silent = true })
			vim.keymap.set("v", "<leader>jV", ":<C-u>MoltenEvaluateVisual<CR>gv<Esc>", { silent = true })
			vim.keymap.set("n", "<leader>jd", ":MoltenDelete<CR>", { silent = true })
			vim.keymap.set("n", "<leader>jh", ":MoltenHideOutput<CR>", { silent = true })
			vim.keymap.set("n", "<leader>jm", ":noautocmd MoltenEnterOutput<CR>", { silent = true })
			vim.api.nvim_create_autocmd("User", {
				pattern = "MoltenInitPost",
				callback = function()
					require("quarto").activate()
				end,
			})
			vim.keymap.set("n", "<leader>ji", ":MoltenImagePopup<CR>", { silent = true })
			vim.keymap.set("n", "<leader>jb", ":MoltenOpenInBrowser<CR>", { silent = true })
			vim.keymap.set("n", "<leader>jj", function()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv ~= nil then
					-- in the form of /home/benlubas/.virtualenvs/VENV_NAME
					venv = string.match(venv, "/.+/(.+)")
					vim.cmd(("MoltenInit %s"):format(venv))
				else
					vim.cmd("MoltenInit python3")
				end
			end, { desc = "Initialize Molten for python3", silent = true })
		end,
	},
}
