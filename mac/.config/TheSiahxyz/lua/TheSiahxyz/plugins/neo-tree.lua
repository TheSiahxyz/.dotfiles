return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			{
				"s1n7ax/nvim-window-picker", -- for open_with_window_picker keymaps
				version = "2.*",
				config = function()
					require("window-picker").setup({
						filter_rules = {
							include_current_win = false,
							autoselect_one = true,
							-- filter using buffer options
							bo = {
								-- if the file type is one of following, the window will be ignored
								filetype = { "neo-tree", "neo-tree-popup", "notify" },
								-- if the buffer type is one of following, the window will be ignored
								buftype = { "terminal", "quickfix" },
							},
						},
					})
				end,
			},
			{ "3rd/image.nvim", opts = {} }, -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		lazy = false, -- neo-tree will lazily load itself
		---@module "neo-tree"
		---@type neotree.Config?
		opts = {
			hijack_netrw_behavior = "disabled", -- netrw disabled, opening a directory opens neo-tree
			filesystem = {
				follow_current_file = { enabled = false },
				commands = {
					-- over write default 'delete' command to 'trash'.
					delete = function(state)
						if vim.fn.executable("trash") == 0 then
							vim.api.nvim_echo({
								{ "- Trash utility not installed. Make sure to install it first\n", nil },
								{ "- In macOS run `brew install trash`\n", nil },
								{ "- Or delete the `custom delete command` section in neo-tree", nil },
							}, false, {})
							return
						end
						local inputs = require("neo-tree.ui.inputs")
						local path = state.tree:get_node().path
						local msg = "Are you sure you want to trash " .. path
						inputs.confirm(msg, function(confirmed)
							if not confirmed then
								return
							end

							vim.fn.system({ "trash", vim.fn.fnameescape(path) })
							require("neo-tree.sources.manager").refresh(state.name)
						end)
					end,
					-- Overwrite default 'delete_visual' command to 'trash' x n.
					delete_visual = function(state, selected_nodes)
						if vim.fn.executable("trash") == 0 then
							vim.api.nvim_echo({
								{ "- Trash utility not installed. Make sure to install it first\n", nil },
								{ "- In macOS run `brew install trash`\n", nil },
								{ "- Or delete the `custom delete command` section in neo-tree", nil },
							}, false, {})
							return
						end
						local inputs = require("neo-tree.ui.inputs")

						-- Function to get the count of items in a table
						local function GetTableLen(tbl)
							local len = 0
							for _ in pairs(tbl) do
								len = len + 1
							end
							return len
						end

						local count = GetTableLen(selected_nodes)
						local msg = "Are you sure you want to trash " .. count .. " files?"
						inputs.confirm(msg, function(confirmed)
							if not confirmed then
								return
							end
							for _, node in ipairs(selected_nodes) do
								vim.fn.system({ "trash", vim.fn.fnameescape(node.path) })
							end
							require("neo-tree.sources.manager").refresh(state.name)
						end)
					end,
					avante_add_files = function(state)
						local node = state.tree:get_node()
						local filepath = node:get_id()
						local relative_path = require("avante.utils").relative_path(filepath)

						local sidebar = require("avante").get()

						local open = sidebar:is_open()
						-- ensure avante sidebar is open
						if not open then
							require("avante.api").ask()
							sidebar = require("avante").get()
						end

						sidebar.file_selector:add_selected_file(relative_path)

						-- remove neo tree buffer
						if not open then
							sidebar.file_selector:remove_selected_file("neo-tree filesystem [1]")
						end
					end,
				},
				window = {
					mappings = {
						["oa"] = "avante_add_files",
					},
				},
			},
		},
		keys = {
			{ "<leader>e", false },
			{ "<leader>E", false },
			{
				"<leader>en",
				function()
					local buf_name = vim.api.nvim_buf_get_name(0)
					-- Function to check if NeoTree is open in any window
					local function is_neo_tree_open()
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.bo[buf].filetype == "neo-tree" then
								return true
							end
						end
						return false
					end
					-- Check if the current file exists
					if
						vim.fn.filereadable(buf_name) == 1
						or vim.fn.isdirectory(vim.fn.fnamemodify(buf_name, ":p:h")) == 1
					then
						if is_neo_tree_open() then
							-- Close NeoTree if it's open
							vim.cmd("Neotree close")
						else
							-- Open NeoTree and reveal the current file
							vim.cmd("Neotree reveal")
						end
					else
						-- If the file doesn't exist, execute the logic for <leader>R
						require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
					end
				end,
				desc = "Open neo-tree",
			},
			{
				"<leader>eN",
				function()
					require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
				end,
				desc = "Open neo-tree (cwd)",
			},
		},
	},
}
