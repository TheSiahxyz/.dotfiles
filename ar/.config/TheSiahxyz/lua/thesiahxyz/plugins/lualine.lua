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
						function()
							return require("molten.status").initialized()
						end,
					},
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
						function()
							local function tab_status()
								local tabs = vim.api.nvim_list_tabpages()
								local current_tab = vim.api.nvim_get_current_tabpage()
								local current_tab_index = 0
								for i, tab in ipairs(tabs) do
									if tab == current_tab then
										current_tab_index = i
										break
									end
								end
								return string.format("%d", current_tab_index)
							end
							return tab_status()
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
		vim.keymap.set({ "n", "v" }, "<leader>tL", function()
			lualine_hidden = not lualine_hidden
			require("lualine").hide({
				place = { "statusline", "tabline", "winbar" },
				unhide = lualine_hidden,
			})
		end, { desc = "Toggle lualine" })
	end,
}
