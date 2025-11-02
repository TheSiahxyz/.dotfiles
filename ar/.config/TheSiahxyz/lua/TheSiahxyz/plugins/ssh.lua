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
			vim.keymap.set("n", "<localleader>rd", api.disconnect, { desc = "Disconnect SSH" })
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
}
