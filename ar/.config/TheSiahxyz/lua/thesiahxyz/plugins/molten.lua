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
	{ "benlubas/image-save.nvim", dev = true, cmd = "SaveImage" },
	{
		"3rd/image.nvim",
		dependencies = { "leafo/magick" },
		config = function()
			require("image").setup({
				backend = "ueberzug", -- whatever backend you would like to use
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = false,
						only_render_image_at_cursor = false,
						filetypes = { "markdown", "quarto" }, -- markdown extensions (ie. quarto) can go here
					},
					neorg = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = false,
						only_render_image_at_cursor = false,
						filetypes = { "norg" },
					},
				},
				max_width = 100,
				max_height = 8,
				max_height_window_percentage = math.huge,
				max_width_window_percentage = math.huge,
				window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
				editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
				tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "fidget", "" },
			})
		end,
	},
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			{
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
			"nvim-cmp",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
			"otter.nvim",
		},
		ft = { "quarto", "markdown" },
		command = "QuartoActivate",
		config = function()
			require("quarto").setup({
				lspFeatures = {
					languages = { "r", "python", "rust", "lua" },
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
					ft_runners = {
						bash = "slime",
					},
					default_method = "molten",
				},
			})
			local runner = require("quarto.runner")
			vim.keymap.set("n", "<leader>jc", runner.run_cell, { silent = true })
			vim.keymap.set("n", "<leader>jC", runner.run_above, { silent = true })
			vim.keymap.set("n", "<leader>jl", runner.run_line, { silent = true })
			vim.keymap.set("v", "<leader>jv", runner.run_range, { silent = true })
			vim.keymap.set("n", "<leader>jA", runner.run_all, { silent = true })
			vim.keymap.set(
				"n",
				"<leader>qp",
				require("quarto").quartoPreview,
				{ desc = "Preview the Quarto document", silent = true, noremap = true }
			)
			-- to create a cell in insert mode, I have the ` snippet
			vim.keymap.set(
				"n",
				"<leader>cc",
				"i```python\n```<Esc>O",
				{ desc = "Create a new code cell", silent = true }
			)
			vim.keymap.set(
				"n",
				"<leader>cs",
				"i```\r\r```{}<left>",
				{ desc = "Split code cell", silent = true, noremap = true }
			)
		end,
	},
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			vim.g.molten_auto_image_popup = true
			vim.g.molten_auto_init_behavior = "raise"
			vim.g.molten_auto_open_html_in_browser = false
			-- I find auto open annoying, keep in mind setting this option will require setting
			-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
			vim.g.molten_auto_open_output = true
			vim.g.molten_cover_empty_lines = false
			vim.g.molten_cover_lines_starting_with = {}
			vim.g.molten_copy_output = false
			vim.g.molten_enter_output_behavior = "open_then_enter"
			-- this guide will be using image.nvim
			-- Don't forget to setup and install the plugin if you want to view image outputs
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_show_more = false
			vim.g.molten_output_win_max_height = 30
			vim.g.molten_output_win_style = "minimal"
			-- this will make it so the output shows up below the \`\`\` cell delimiter
			vim.g.molten_virt_lines_off_by_1 = true
			-- Output as virtual text. Allows outputs to always be shown, works with images, but can
			-- be buggy with longer images
			vim.g.molten_virt_text_output = true
			-- optional, works for virt text and the output window
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_max_lines = 20
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
			vim.keymap.set("n", "<leader>jw", ":MoltenOpenInBrowser<CR>", { silent = true })
			vim.keymap.set("n", "<leader>jj", function()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv ~= nil then
					-- in the form of /home/benlubas/.virtualenvs/VENV_NAME
					venv = string.match(venv, "/.+/(.+)")
					vim.cmd(("MoltenInit %s"):format(venv))
				else
					vim.cmd("MoltenInit python3")
				end
			end)
		end,
	},
}
