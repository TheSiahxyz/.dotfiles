return {
	{
		"amitds1997/remote-nvim.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = true,
		init = function()
			local ok, wk = pcall(require, "which-key")
			if ok then
				wk.add({ { "<localleader>r", group = "SSH Remote" } })
			end
		end,
		keys = {
			{ "<localleader>rs", "<cmd>RemoteStart<CR>", desc = "Start/Connect", mode = "n", silent = true },
			{ "<localleader>rx", "<cmd>RemoteStop<CR>", desc = "Stop/Close", mode = "n", silent = true },
			{ "<localleader>ri", "<cmd>RemoteInfo<CR>", desc = "Info/Progress Viewer", mode = "n", silent = true },
			{ "<localleader>rC", "<cmd>RemoteCleanup<CR>", desc = "Cleanup workspace", mode = "n", silent = true },

			-- Delete saved config: show a list, allow multi-select, then run :RemoteConfigDel <name>
			{
				"<localleader>rd",
				function()
					local function get_names()
						-- use command-line completion if the command supports it
						local list = vim.fn.getcompletion("RemoteConfigDel ", "cmdline") or {}
						return list
					end

					local names = get_names()
					if #names == 0 then
						return vim.notify(
							"No saved remote configs found (completion empty)",
							vim.log.levels.INFO,
							{ title = "Remote" }
						)
					end

					-- Prefer Telescope if present
					local ok_picker, pickers = pcall(require, "telescope.pickers")
					if ok_picker then
						local finders = require("telescope.finders")
						local conf = require("telescope.config").values
						local actions = require("telescope.actions")
						local state = require("telescope.actions.state")

						pickers
							.new({}, {
								prompt_title = "Delete Remote Config(s)",
								finder = finders.new_table(names),
								sorter = conf.generic_sorter({}),
								attach_mappings = function(_, map)
									local function run_delete(prompt_bufnr, picked)
										local function del(name)
											vim.api.nvim_cmd({ cmd = "RemoteConfigDel", args = { name } }, {})
										end
										if picked and #picked > 0 then
											for _, entry in ipairs(picked) do
												del(entry.value or entry[1] or entry.text)
											end
										else
											local entry = state.get_selected_entry()
											if entry then
												del(entry.value or entry[1] or entry.text)
											end
										end
										actions.close(prompt_bufnr)
									end

									actions.select_default:replace(function(bufnr)
										local picker = state.get_current_picker(bufnr)
										local multi = picker:get_multi_selection()
										run_delete(bufnr, multi)
									end)

									-- quality of life: <C-d> also deletes without closing (optional)
									map("i", "<C-d>", function(bufnr)
										local picker = state.get_current_picker(bufnr)
										local multi = picker:get_multi_selection()
										local function del(name)
											vim.api.nvim_cmd({ cmd = "RemoteConfigDel", args = { name } }, {})
										end
										if multi and #multi > 0 then
											for _, e in ipairs(multi) do
												del(e.value or e[1] or e.text)
											end
										else
											local e = state.get_selected_entry()
											if e then
												del(e.value or e[1] or e.text)
											end
										end
										-- keep picker open
									end)

									return true
								end,
							})
							:find()
					else
						-- Fallback: vim.ui.select (single delete)
						vim.ui.select(names, { prompt = "Select remote config to delete" }, function(choice)
							if choice and choice ~= "" then
								vim.api.nvim_cmd({ cmd = "RemoteConfigDel", args = { choice } }, {})
							end
						end)
					end
				end,
				desc = "Delete saved config (pick from list)",
				mode = "n",
				silent = true,
			},

			{ "<localleader>rl", "<cmd>RemoteLog<CR>", desc = "Open log", mode = "n", silent = true },
		},
	},
	{
		"nosduco/remote-sshfs.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		opts = {
			-- Refer to the configuration section below
			-- or leave empty for defaults
		},
		config = function()
			require("remote-sshfs").setup({
				connections = {
					ssh_configs = { -- which ssh configs to parse for hosts list
						vim.fn.expand("$HOME") .. "/.ssh/config",
						"/etc/ssh/ssh_config",
						-- "/path/to/custom/ssh_config"
					},
					ssh_known_hosts = vim.fn.expand("$HOME") .. "/.ssh/known_hosts",
					-- NOTE: Can define ssh_configs similarly to include all configs in a folder
					-- ssh_configs = vim.split(vim.fn.globpath(vim.fn.expand "$HOME" .. "/.ssh/configs", "*"), "\n")
					sshfs_args = { -- arguments to pass to the sshfs command
						"-o reconnect",
						"-o ConnectTimeout=5",
					},
				},
				mounts = {
					base_dir = vim.fn.expand("$HOME") .. "/.sshfs/", -- base directory for mount points
					unmount_on_exit = true, -- run sshfs as foreground, will unmount on vim exit
				},
				handlers = {
					on_connect = {
						change_dir = true, -- when connected change vim working directory to mount point
					},
					on_disconnect = {
						clean_mount_folders = false, -- remove mount point folder on disconnect/unmount
					},
					on_edit = {}, -- not yet implemented
				},
				ui = {
					select_prompts = false, -- not yet implemented
					confirm = {
						connect = true, -- prompt y/n when host is selected to connect to
						change_dir = false, -- prompt y/n to change working directory on connection (only applicable if handlers.on_connect.change_dir is enabled)
					},
				},
				log = {
					enabled = false, -- enable logging
					truncate = false, -- truncate logs
					types = { -- enabled log types
						all = false,
						util = false,
						handler = false,
						sshfs = false,
					},
				},
			})
			local api = require("remote-sshfs.api")
			vim.keymap.set("n", "<localleader>rc", api.connect, { desc = "Connect SSH" })
			vim.keymap.set("n", "<localleader>rd", function()
				local mountpoint = vim.fn.getcwd()
				local ok = vim.system({ "diskutil", "unmount", "force", mountpoint }):wait().code == 0
				if not ok then
					ok = vim.system({ "umount", "-f", mountpoint }):wait().code == 0
				end
				print(ok and ("✅ Unmounted: " .. mountpoint) or ("⚠️ Failed to unmount: " .. mountpoint))
			end, { desc = "Force unmount macFUSE mount (quiet)" })
			vim.keymap.set("n", "<localleader>re", api.edit, { desc = "Edit SSH" })

			-- (optional) Override telescope find_files and live_grep to make dynamic based on if connected to host
			local builtin = require("telescope.builtin")
			local connections = require("remote-sshfs.connections")
			vim.keymap.set("n", "<localleader>rf", function()
				if connections.is_connected() then
					api.find_files()
				else
					builtin.find_files()
				end
			end, { desc = "Find SSH files" })
			vim.keymap.set("n", "<localleader>rg", function()
				if connections.is_connected() then
					api.live_grep()
				else
					builtin.live_grep()
				end
			end, { desc = "Live SSH grep" })
			require("telescope").load_extension("remote-sshfs")
		end,
	},
	{
		"inhesrom/remote-ssh.nvim",
		branch = "master",
		dependencies = {
			"inhesrom/telescope-remote-buffer", --See https://github.com/inhesrom/telescope-remote-buffer for features
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
			-- nvim-notify is recommended, but not necessarily required into order to get notifcations during operations - https://github.com/rcarriga/nvim-notify
			"rcarriga/nvim-notify",
		},
		config = function()
			require("telescope-remote-buffer").setup(
				-- Default keymaps to open telescope and search open buffers including "remote" open buffers
				--fzf = "<leader>fz",
				--match = "<leader>gb",
				--oldfiles = "<leader>rb"
			)

			-- setup lsp_config here or import from part of neovim config that sets up LSP
			require("remote-ssh").setup({
				-- Optional: Custom on_attach function for LSP clients
				on_attach = function(client, bufnr)
					-- Your LSP keybindings and setup
				end,

				-- Optional: Custom capabilities for LSP clients
				capabilities = vim.lsp.protocol.make_client_capabilities(),

				-- Custom mapping from filetype to LSP server name
				filetype_to_server = {
					-- Example: Use pylsp for Python (default and recommended)
					python = "pylsp",
					-- More customizations...
				},

				-- Custom server configurations
				server_configs = {
					-- Custom config for clangd
					clangd = {
						filetypes = { "c", "cpp", "objc", "objcpp" },
						root_patterns = { ".git", "compile_commands.json" },
						init_options = {
							usePlaceholders = true,
							completeUnimported = true,
						},
					},
					-- More server configs...
				},

				-- Async write configuration
				async_write_opts = {
					timeout = 30, -- Timeout in seconds for write operations
					debug = false, -- Enable debug logging
					log_level = vim.log.levels.INFO,
					autosave = true, -- Enable automatic saving on text changes (default: true)
					-- Set to false to disable auto-save while keeping manual saves (:w) working
					save_debounce_ms = 3000, -- Delay before initiating auto-save to handle rapid editing (default: 3000)
				},
			})

			-- Custom function to parse SSH config and extract Host entries
			local function parse_ssh_hosts()
				local ssh_config_path = vim.fn.expand("$HOME") .. "/.ssh/config"
				local hosts = {}
				local seen = {}

				-- Check if file exists
				if vim.fn.filereadable(ssh_config_path) == 0 then
					return hosts
				end

				-- Read and parse SSH config file
				local lines = vim.fn.readfile(ssh_config_path)
				for _, line in ipairs(lines) do
					-- Trim whitespace
					local trimmed = vim.fn.trim(line)
					-- Skip comments and empty lines
					if trimmed ~= "" and not vim.startswith(trimmed, "#") then
						-- Match "Host" keyword exactly (case-insensitive) followed by whitespace
						-- Use pattern to ensure it's "Host " not "HostName" or other keywords
						local host_match = string.match(string.lower(trimmed), "^host%s+(.+)$")
						if host_match then
							-- Handle multiple hosts on same line (space or comma separated)
							for host in vim.gsplit(host_match, "[%s,]+") do
								host = vim.fn.trim(host)
								-- Skip wildcards and empty strings
								if host ~= "" and host ~= "*" and not string.match(host, "^%*") and not seen[host] then
									table.insert(hosts, host)
									seen[host] = true
								end
							end
						end
					end
				end

				return hosts
			end

			-- Custom function to open RemoteTreeBrowser with selected SSH host
			local function remote_tree_browser_picker()
				local hosts = parse_ssh_hosts()
				if #hosts == 0 then
					return vim.notify(
						"No SSH hosts found in ~/.ssh/config",
						vim.log.levels.WARN,
						{ title = "Remote SSH" }
					)
				end

				-- Use vim.ui.select (default Neovim UI)
				vim.ui.select(hosts, { prompt = "Select SSH host for RemoteTreeBrowser" }, function(choice)
					if choice and choice ~= "" then
						-- Use rsync:// protocol with double slash (//) for SSH config Host aliases
						-- Format: rsync://host-alias//path (double slash is required for SSH config aliases)
						-- The plugin automatically detects and handles SSH config settings
						local rsync_url = "rsync://" .. choice .. "//"

						-- Run RemoteTreeBrowser command
						-- rsync:// protocol will use SSH config to resolve Host alias
						vim.schedule(function()
							-- Step 1: Create browser
							vim.api.nvim_cmd({ cmd = "RemoteTreeBrowser", args = { rsync_url } }, {})
							-- Step 2: Hide browser (needed for proper positioning)
							vim.defer_fn(function()
								vim.api.nvim_cmd({ cmd = "RemoteTreeBrowserHide" }, {})
								-- Step 3: Show browser (will open on the right side)
								vim.defer_fn(function()
									vim.api.nvim_cmd({ cmd = "RemoteTreeBrowserShow" }, {})
								end, 50)
							end, 100)
						end)
					end
				end)
			end

			-- Toggle function for RemoteTreeBrowser show/hide
			local function remote_tree_browser_toggle()
				-- Try to access remote-ssh.nvim's TreeBrowser module
				local ok, tree_browser = pcall(require, "remote-ssh.tree_browser")
				if ok and tree_browser then
					-- Check if browser buffer exists (like show_tree() does)
					local bufnr = tree_browser.bufnr
					if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
						-- Browser doesn't exist, show SSH config picker to create one
						remote_tree_browser_picker()
						return
					end

					-- Browser buffer exists, check if window is visible (like hide_tree() does)
					local win_id = tree_browser.win_id
					local is_visible = win_id and vim.api.nvim_win_is_valid(win_id)

					if is_visible then
						-- Browser is visible, hide it
						if tree_browser.hide_tree then
							tree_browser.hide_tree()
						else
							vim.api.nvim_cmd({ cmd = "RemoteTreeBrowserHide" }, {})
						end
						-- After hiding, return early to prevent any further actions
						return
					else
						-- Browser exists but hidden, show it
						-- Directly use command instead of show_tree() to avoid any callbacks
						vim.api.nvim_cmd({ cmd = "RemoteTreeBrowserShow" }, {})
					end
				else
					-- Fallback: only use this if module is not accessible
					-- Check if browser buffer exists (not just visible windows)
					local browser_buf_found = false
					local browser_visible = false

					-- Check all buffers, not just visible windows
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_valid(buf) then
							local buf_name = vim.api.nvim_buf_get_name(buf)
							-- Check if it's a remote tree browser buffer
							if buf_name:match("rsync://") then
								browser_buf_found = true
								-- Check if this buffer is visible in any window
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									if vim.api.nvim_win_get_buf(win) == buf then
										browser_visible = true
										break
									end
								end
								break
							end
						end
					end

					if browser_buf_found then
						-- Browser buffer exists
						if browser_visible then
							-- Browser is visible, hide it
							vim.api.nvim_cmd({ cmd = "RemoteTreeBrowserHide" }, {})
						else
							-- Browser exists but hidden, show it
							vim.api.nvim_cmd({ cmd = "RemoteTreeBrowserShow" }, {})
						end
					else
						-- Browser not found, show SSH config picker
						remote_tree_browser_picker()
					end
				end
			end

			-- Keymap for custom RemoteTreeBrowser picker
			vim.keymap.set("n", "<leader>er", remote_tree_browser_picker, {
				desc = "RemoteTreeBrowser (pick SSH host)",
				silent = true,
			})

			-- Keymap for toggle RemoteTreeBrowser show/hide
			vim.keymap.set("n", "<leader>ef", remote_tree_browser_toggle, {
				desc = "Toggle RemoteTreeBrowser",
				silent = true,
			})
		end,
	},
}
