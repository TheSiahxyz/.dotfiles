return {
	"lmburns/lf.nvim",
	dependencies = {
		{
			"akinsho/toggleterm.nvim",
			version = "*",
			config = function()
				require("toggleterm").setup({
					highlights = {
						Normal = {
							guibg = "NONE", -- Set to transparent background
						},
						NormalFloat = {
							link = "Normal", -- Link to the Normal highlight
						},
						FloatBorder = {
							guifg = "NONE",
							guibg = "NONE",
						},
					},
					shade_terminals = false, -- Disable shading
				})
			end,
		},
	},
	config = function()
		vim.g.lf_netrw = 1
		local fn = vim.fn

		-- Defaults
		require("lf").setup({
			default_action = "drop", -- Default action when `Lf` opens a file
			default_actions = {
				["<C-t>"] = "tabedit",
				["<C-x>"] = "split",
				["<C-v>"] = "vsplit",
				["<C-o>"] = "tab drop",
			},
			winblend = 10, -- Pseudotransparency level
			direction = "float", -- Window type
			border = "rounded", -- Border kind
			height = fn.float2nr(fn.round(0.75 * vim.o.lines)), -- Height of the *floating* window
			width = fn.float2nr(fn.round(0.75 * vim.o.columns)), -- Width of the *floating* window
			escape_quit = true, -- Map escape to the quit command
			focus_on_open = true, -- Focus the current file when opening Lf
			mappings = true, -- Enable terminal buffer mapping
			tmux = true, -- Tmux statusline can be disabled
			disable_netrw_warning = true, -- Don't display a message when opening a directory
			highlights = {
				Normal = { link = "Normal" }, -- Use normal highlighting
				NormalFloat = { link = "NormalFloat" }, -- Use float highlighting
				FloatBorder = { link = "@constant" }, -- Use constant highlighting
			},

			-- Layout configurations
			layout_mapping = "<M-r>", -- Resize window with this key
			views = {
				{ width = 0.800, height = 0.800 },
				{ width = 0.600, height = 0.600 },
				{ width = 0.950, height = 0.950 },
				{ width = 0.500, height = 0.500, col = 0, row = 0 },
				{ width = 0.500, height = 0.500, col = 0, row = 0.5 },
				{ width = 0.500, height = 0.500, col = 0.5, row = 0 },
				{ width = 0.500, height = 0.500, col = 0.5, row = 0.5 },
			},
		})

		vim.keymap.set("n", "<leader>lf", "<Cmd>Lf<CR>")

		-- Autocommand to set key mapping in terminal buffer
		vim.api.nvim_create_autocmd("User", {
			pattern = "LfTermEnter",
			callback = function(a)
				vim.api.nvim_buf_set_keymap(
					a.buf,
					"t",
					"q",
					"<cmd>q<CR>",
					{ nowait = true, noremap = true, silent = true }
				)
			end,
		})
	end,
}
