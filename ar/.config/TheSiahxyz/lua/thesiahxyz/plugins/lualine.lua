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
					statusline = 100,
					tabline = 100,
					winbar = 100,
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
					{
						function()
							local has_noice, noice = pcall(require, "noice")
							if has_noice and noice.api and noice.api.status and noice.api.status.mode then
								return noice.api.status.mode.get() or ""
							else
								return ""
							end
						end,
						cond = function()
							local has_noice, noice = pcall(require, "noice")
							return has_noice
								and noice.api
								and noice.api.status
								and noice.api.status.mode
								and noice.api.status.mode.has()
						end,
						color = { bg = "#ff9e64" },
					},
				},
				lualine_b = {
					"branch",
					{
						"diff",
						colored = true, -- Displays a colored diff status if set to true
						diff_color = {
							-- Same color values as the general color option can be used here.
							added = "LuaLineDiffAdd", -- Changes the diff's added color
							modified = "LuaLineDiffChange", -- Changes the diff's modified color
							removed = "LuaLineDiffDelete", -- Changes the diff's removed color you
						},
						symbols = { added = "+", modified = "~", removed = "-" }, -- Changes the symbols used by the diff.
						source = nil, -- A function that works as a data source for diff.
						-- It must return a table as such:
						--   { added = add_count, modified = modified_count, removed = removed_count }
						-- or nil on failure. count <= 0 won't be displayed.
					},
					{
						"diagnostics",
						-- Table of diagnostic sources, available sources are:
						--   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
						-- or a function that returns a table as such:
						--   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
						sources = { "nvim_lsp", "nvim_diagnostic", "nvim_workspace_diagnostic", "coc" },

						-- Displays diagnostics for the defined severity types
						sections = { "error", "warn", "info", "hint" },

						diagnostics_color = {
							-- Same values as the general color option can be used here.
							error = "DiagnosticError", -- Changes diagnostics' error color.
							warn = "DiagnosticWarn", -- Changes diagnostics' warn color.
							info = "DiagnosticInfo", -- Changes diagnostics' info color.
							hint = "DiagnosticHint", -- Changes diagnostics' hint color.
						},
						symbols = {
							error = " ",
							warn = " ",
							info = " ",
							hint = " ",
						},
						colored = true, -- Displays diagnostics status in color if set to true.
						update_in_insert = true, -- Update diagnostics in insert mode.
						always_visible = false, -- Show diagnostics even if there are none.
					},
					{
						function()
							local ok, neocomposer = pcall(require, "NeoComposer.ui")
							if ok and neocomposer and neocomposer.status_recording then
								return neocomposer.status_recording()
							end
							return ""
						end,
					},
				},
				lualine_c = {
					{
						"filename",
						file_status = true, -- Displays file status (readonly status, modified status)
						newfile_status = true, -- Display new file status (new file means no write after created)
						path = 3, -- 0: Just the filename
						-- 1: Relative path
						-- 2: Absolute path
						-- 3: Absolute path, with tilde as the home directory
						-- 4: Filename and parent dir, with tilde as the home directory

						shorting_target = 40, -- Shortens path to leave 40 spaces in the window
						-- for other components. (terrible name, any suggestions?)
						symbols = {
							modified = "[*]", -- Text to show when the file is modified.
							readonly = "[r]", -- Text to show when the file is non-modifiable or readonly.
							unnamed = "[?]", -- Text to show for unnamed buffers.
							newfile = "[%%]", -- Text to show for newly created file before first write
						},
					},
				},
				lualine_x = {
					{
						function()
							local has_noice, noice = pcall(require, "noice")
							if has_noice and noice.api and noice.api.status and noice.api.status.mode then
								return noice.api.status.search.get() or ""
							else
								return ""
							end
						end,
						cond = function()
							local has_noice, noice = pcall(require, "noice")
							return has_noice
								and noice.api
								and noice.api.status
								and noice.api.status.search
								and noice.api.status.search.has()
						end,
						color = { bg = "#ff9e64" },
					},
					"copilot",
					{
						function()
							return require("molten.status").initialized()
						end,
					},
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
				lualine_y = {
					"progress",
				},
				lualine_z = {
					{
						function()
							local is_tmux = os.getenv("TMUX") ~= nil
							if is_tmux then
								return ""
							end
							return os.date("%H:%M")
						end,
					},
				},
			},
			inactive_sections = {},
			tabline = {
				lualine_a = {
					{
						"tabs",
						tab_max_length = 40, -- Maximum width of each tab. The content will be shorten dynamically (example: apple/orange -> a/orange)
						max_length = vim.o.columns / 3, -- Maximum width of tabs component.
						-- Note:
						-- It can also be a function that returns
						-- the value of `max_length` dynamically.
						mode = 0, -- 0: Shows tab_nr
						-- 1: Shows tab_name
						-- 2: Shows tab_nr + tab_name

						path = nil, -- 0: just shows the filename
						-- 1: shows the relative path and shorten $HOME to ~
						-- 2: shows the full path
						-- 3: shows the full path and shorten $HOME to ~

						-- Automatically updates active tab color to match color of other components (will be overidden if buffers_color is set)
						use_mode_colors = true,

						-- tabs_color = {
						-- 	-- Same values as the general color option can be used here.
						-- 	active = "lualine_{section}_normal", -- Color for active tab.
						-- 	inactive = "lualine_{section}_inactive", -- Color for inactive tab.
						-- },
						--
						show_modified_status = false, -- Shows a symbol next to the tab name if the file has been modified.
						symbols = {
							modified = "*", -- Text to show when the file is modified.
						},

						fmt = function(name, context)
							-- Show + if buffer is modified in tab
							local buflist = vim.fn.tabpagebuflist(context.tabnr)
							local winnr = vim.fn.tabpagewinnr(context.tabnr)
							local bufnr = buflist[winnr]
							local mod = vim.fn.getbufvar(bufnr, "&mod")

							return name .. (mod == 1 and " +" or "")
						end,
					},
				},
				lualine_b = {
					{
						function()
							local function buffer_status()
								local buffers = vim.fn.getbufinfo({ buflisted = true })
								local current_buf = vim.fn.bufnr()
								local current_buffer_index = 0
								local modified_symbol = vim.bo.modified and "●" or ""
								for i, buf in ipairs(buffers) do
									if buf.bufnr == current_buf then
										current_buffer_index = i
										break
									end
								end
								return string.format("%s%d/%d", modified_symbol, current_buffer_index, #buffers)
							end
							return buffer_status()
						end,
					},
				},
				lualine_c = {
					{
						function()
							return navic.get_location()
						end,
						cond = function()
							return navic.is_available()
						end,
					},
				},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		})

		local lualine_hidden = true
		vim.keymap.set({ "n", "v" }, "<leader>zl", function()
			lualine_hidden = not lualine_hidden
			require("lualine").hide({
				place = { "statusline", "tabline", "winbar" },
				unhide = lualine_hidden,
			})
		end, { desc = "Toggle lualine" })
	end,
}
