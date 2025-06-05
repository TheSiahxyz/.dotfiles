function ColorMyPencils(color)
	color = color or "catppuccin"
	vim.cmd.colorscheme(color)

	local set = vim.api.nvim_set_hl
	set(0, "Normal", { bg = "NONE" })
	set(0, "NormalFloat", { bg = "NONE" })
	set(0, "@comment.todo", { bg = "NONE" })
	set(0, "@comment.note", { bg = "NONE" })
	set(0, "@comment.warning", { bg = "NONE" })
	set(0, "@comment.error", { bg = "NONE" })
	set(0, "@number", { bg = "NONE" })
	set(0, "@string.special.url", { bg = "NONE" })
end

return {
	{ "junegunn/seoul256.vim" },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				flavour = "auto", -- latte, frappe, macchiato, mocha
				background = { -- :h background
					light = "latte",
					dark = "mocha",
				},
				transparent_background = true, -- disables setting the background color.
				show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
				term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
				dim_inactive = {
					enabled = true, -- dims the background color of inactive window
					shade = "dark",
					percentage = 0.15, -- percentage of the shade to apply to the inactive window
				},
				no_italic = false, -- Force no italic
				no_bold = false, -- Force no bold
				no_underline = false, -- Force no underline
				styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
					comments = { "italic" }, -- Change the style of comments
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
					-- miscs = {}, -- Uncomment to turn off hard-coded styles
				},
				color_overrides = {},
				custom_highlights = {},
				default_integrations = true,
				integrations = {
					aerial = true,
					alpha = true,
					blink_cmp = true,
					cmp = true,
					dashboard = true,
					flash = true,
					gitsigns = true,
					headlines = true,
					illuminate = true,
					indent_blankline = { enabled = true, scope_color = "peach", colored_indent_levels = true },
					leap = true,
					lsp_trouble = true,
					mason = true,
					markdown = true,
					mini = true,
					native_lsp = {
						enabled = true,
						underlines = {
							errors = { "undercurl" },
							hints = { "undercurl" },
							warnings = { "undercurl" },
							information = { "undercurl" },
						},
					},
					navic = { enabled = true, custom_bg = "NONE" },
					neotest = true,
					neotree = true,
					noice = true,
					notify = true,
					semantic_tokens = true,
					telescope = true,
					treesitter = true,
					treesitter_context = true,
					which_key = true,
				},
				highlight_overrides = {
					mocha = function(mocha)
						return {
							LineNr = { fg = mocha.overlay2 },
							CursorLineNr = { fg = mocha.sky },
							Normal = { bg = "NONE" }, -- normal text
							NormalNC = { bg = "NONE" },
						}
					end,
				},
			})

			ColorMyPencils()
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		-- opts = ...,
		config = function()
			require("gruvbox").setup({
				terminal_colors = true, -- add neovim terminal colors
				undercurl = true,
				underline = true,
				bold = true,
				italic = {
					strings = true,
					emphasis = true,
					comments = true,
					operators = false,
					folds = true,
				},
				strikethrough = true,
				invert_selection = false,
				invert_signs = false,
				invert_tabline = false,
				invert_intend_guides = false,
				inverse = true, -- invert background for search, diffs, statuslines and errors
				contrast = "", -- can be "hard", "soft" or empty string
				palette_overrides = {
					dark1 = "NONE",
				},
				overrides = {},
				dim_inactive = true,
				transparent_mode = true,
			})
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				variant = "auto", -- auto, main, moon, or dawn
				dark_variant = "main", -- main, moon, or dawn
				dim_inactive_windows = false,
				extend_background_behind_borders = true,
				enable = {
					terminal = true,
					legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
					migrations = true, -- Handle deprecated options automatically
				},
				styles = {
					bold = true,
					italic = false,
					transparency = true,
				},
				groups = {
					border = "muted",
					link = "iris",
					panel = "surface",

					error = "love",
					hint = "iris",
					info = "foam",
					note = "pine",
					todo = "rose",
					warn = "gold",

					git_add = "foam",
					git_change = "rose",
					git_delete = "love",
					git_dirty = "rose",
					git_ignore = "muted",
					git_merge = "iris",
					git_rename = "pine",
					git_stage = "iris",
					git_text = "rose",
					git_untracked = "subtle",

					h1 = "iris",
					h2 = "foam",
					h3 = "rose",
					h4 = "gold",
					h5 = "pine",
					h6 = "foam",
				},
				palette = {
					-- Override the builtin palette per variant
					-- moon = {
					--     base = '#18191a',
					--     overlay = '#363738',
					-- },
				},
				highlight_groups = {
					-- Comment = { fg = "foam" },
					-- VertSplit = { fg = "muted", bg = "muted" },
				},
				before_highlight = function(group, highlight, palette)
					-- Disable all undercurls
					-- if highlight.undercurl then
					--     highlight.undercurl = false
					-- end
					--
					-- Change palette colour
					-- if highlight.fg == palette.pine then
					--     highlight.fg = palette.foam
					-- end
				end,
			})
			-- vim.cmd("colorscheme rose-pine")
			-- vim.cmd("colorscheme rose-pine-main")
			-- vim.cmd("colorscheme rose-pine-moon")
			-- vim.cmd("colorscheme rose-pine-dawn")
		end,
	},
	{
		"Mofiqul/dracula.nvim",
		config = function()
			local dracula = require("dracula")
			dracula.setup({
				-- customize dracula color palette
				colors = {
					bg = "#282A36",
					fg = "#F8F8F2",
					selection = "#44475A",
					comment = "#6272A4",
					red = "#FF5555",
					orange = "#FFB86C",
					yellow = "#F1FA8C",
					green = "#50fa7b",
					purple = "#BD93F9",
					cyan = "#8BE9FD",
					pink = "#FF79C6",
					bright_red = "#FF6E6E",
					bright_green = "#69FF94",
					bright_yellow = "#FFFFA5",
					bright_blue = "#D6ACFF",
					bright_magenta = "#FF92DF",
					bright_cyan = "#A4FFFF",
					bright_white = "#FFFFFF",
					menu = "#21222C",
					visual = "#3E4452",
					gutter_fg = "#4B5263",
					nontext = "#3B4048",
					white = "#ABB2BF",
					black = "#191A21",
				},
				-- show the '~' characters after the end of buffers
				show_end_of_buffer = true, -- default false
				-- use transparent background
				transparent_bg = true, -- default false
				-- set custom lualine background color
				lualine_bg_color = "#44475a", -- default nil
				-- set italic comment
				italic_comment = true, -- default false
				-- overrides the default highlights with table see `:h synIDattr`
				overrides = {},
				-- You can use overrides as table like this
				-- overrides = {
				--   NonText = { fg = "white" }, -- set NonText fg to white
				--   NvimTreeIndentMarker = { link = "NonText" }, -- link to NonText highlight
				--   Nothing = {} -- clear highlight of Nothing
				-- },
				-- Or you can also use it like a function to get color from theme
				-- overrides = function (colors)
				--   return {
				--     NonText = { fg = colors.white }, -- set NonText fg to white of theme
				--   }
				-- end,
			})
		end,
	},
}
