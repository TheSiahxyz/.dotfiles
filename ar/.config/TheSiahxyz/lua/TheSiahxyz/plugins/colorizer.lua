return {
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPre",
	opts = { -- set to setup table
	},
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n" },
			{ "<leader>zh", group = "Colorizer" },
		})
	end,
	config = function()
		require("colorizer").setup({
			filetypes = { "*" },
			buftypes = {},
			user_commands = true,
			lazy_load = false,
			options = {
				parsers = {
					css = false, -- preset: enables names, hex, rgb, hsl, oklch
					css_fn = false, -- preset: enables rgb, hsl, oklch
					names = {
						enable = false,
						lowercase = true,
						camelcase = true,
						uppercase = true,
						strip_digits = false,
						custom = false, -- table|function|false
					},
					hex = {
						default = false, -- default value for format keys (see above)
						rgb = true, -- #RGB
						rgba = false, -- #RGBA
						rrggbb = false, -- #RRGGBB
						rrggbbaa = false, -- #RRGGBBAA
						aarrggbb = false, -- 0xAARRGGBB
					},
					rgb = { enable = true },
					hsl = { enable = false },
					oklch = { enable = false },
					tailwind = {
						enable = true, -- parse Tailwind color names
						lsp = true, -- use Tailwind LSP documentColor
						update_names = true,
					},
					sass = {
						enable = false,
						parsers = { css = true },
						variable_pattern = "^%$([%w_-]+)",
					},
					xterm = { enable = false },
					custom = {},
				},
				display = {
					mode = "background", -- "background"|"foreground"|"virtualtext"
					background = {
						bright_fg = "#000000",
						dark_fg = "#ffffff",
					},
					virtualtext = {
						char = "■",
						position = "eol", -- "eol"|"before"|"after"
						hl_mode = "foreground",
					},
					priority = {
						default = 150, -- vim.hl.priorities.diagnostics
						lsp = 200, -- vim.hl.priorities.user
					},
				},
				hooks = {
					should_highlight_line = false, -- function(line, bufnr, line_num) -> bool
				},
				always_update = false,
			},
		})
	end,
	keys = {
		{ "<leader>zha", "<Cmd>ColorizerAttachToBuffer<CR>", desc = "Attach colorizer" },
		{ "<leader>zhd", "<Cmd>ColorizerDetachFromBuffer<CR>", desc = "Detach colorizer" },
		{ "<leader>zhr", "<Cmd>ColorizerReloadAllBuffers<CR>", desc = "Refresh colorizer" },
		{ "<leader>zht", "<Cmd>ColorizerToggle<CR>", desc = "Toggle colorizer" },
	},
}
