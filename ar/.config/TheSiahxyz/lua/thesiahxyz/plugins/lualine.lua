return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local navic = require("nvim-navic")
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = false,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return str:sub(1, 1)
						end,
					},
				},
				lualine_b = {
					"branch",
					"diff",
					"diagnostics",
					"require('molten.status').initialized()",
				},
				lualine_c = {
					{
						"filename",
						file_status = true, -- Displays file status (readonly status, modified status)
						newfile_status = true, -- Display new file status (new file means no write after created)
						path = 2, -- 0: Just the filename
						-- 1: Relative path
						-- 2: Absolute path
						-- 3: Absolute path, with tilde as the home directory
						-- 4: Filename and parent dir, with tilde as the home directory

						shorting_target = 40, -- Shortens path to leave 40 spaces in the window
						-- for other components. (terrible name, any suggestions?)
						symbols = {
							modified = "[+]", -- Text to show when the file is modified.
							readonly = "[-]", -- Text to show when the file is non-modifiable or readonly.
							unnamed = "[?]", -- Text to show for unnamed buffers.
							newfile = "[*]", -- Text to show for newly created file before first write
						},
					},
				},
				lualine_x = {
					"encoding",
					"fileformat",
					{
						"filetype",
						colored = true, -- Displays filetype icon in color if set to true
						icon_only = true, -- Display only an icon for filetype
						icon = { align = "right" }, -- Display filetype icon on the right hand side
						-- icon =    {'X', align='right'}
						-- Icon string ^ in table is ignored in filetype component
					},
				},
				lualine_y = { "progress" },
				lualine_z = {
					{
						"datetime",
						style = "%H:%M",
					},
				},
			},
			inactive_sections = {},
			tabline = {
				lualine_a = {
					{
						"buffers",
						icons_enabled = false, -- Enables the display of icons alongside the component.
						separator = nil, -- Determines what separator to use for the component.
						draw_empty = false, -- Whether to draw component even if it's empty.
						padding = { left = 1, right = 0 },
						show_filename_only = true, -- Shows shortened relative path when set to false.
						hide_filename_extension = true, -- Hide filename extension when set to true.
						show_modified_status = true, -- Shows indicator when the buffer is modified.

						mode = 1, -- 0: Shows buffer name
						-- 1: Shows buffer index
						-- 2: Shows buffer name + buffer index
						-- 3: Shows buffer number
						-- 4: Shows buffer name + buffer number

						max_length = vim.o.columns * 2 / 3, -- Maximum width of buffers component,
						-- it can also be a function that returns
						-- the value of `max_length` dynamically.
						filetype_names = {
							TelescopePrompt = "Telescope",
							dashboard = "Dashboard",
							packer = "Packer",
							fzf = "FZF",
							alpha = "Alpha",
						}, -- Shows specific buffer name for that filetype ( { `filetype` = `buffer_name`, ... } )

						-- Automatically updates active buffer color to match color of other components (will be overidden if buffers_color is set)
						use_mode_colors = false,

						buffers_color = {
							-- Same values as the general color option can be used here.
							-- active = "lualine_{section}_normal", -- Color for active buffer.
							-- inactive = "lualine_{section}_inactive", -- Color for inactive buffer.
						},

						symbols = {
							modified = "● ", -- Text to show when the buffer is modified
							alternate_file = "", -- Text to show to identify the alternate file
							directory = "", -- Text to show when the buffer is a directory
						},
					},
				},
				lualine_b = {
					{
						function()
							return navic.get_location()
						end,
						cond = function()
							return navic.is_available()
						end,
					},
				},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		})

		local lualine_hidden = true
		vim.keymap.set({ "n", "v" }, "<leader>tL", function()
			lualine_hidden = not lualine_hidden
			require("lualine").hide({
				place = { "statusline", "tabline", "winbar" },
				unhide = lualine_hidden,
			})
		end, { desc = "Toggle lualine" })
	end,
}
