return {
	"https://codeberg.org/esensar/nvim-dev-container",
	dependencies = "nvim-treesitter/nvim-treesitter",
	config = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "DevcontainerBuildProgress",
			callback = function()
				vim.cmd("redrawstatus")
			end,
		})
		require("devcontainer").setup({
			config_search_start = function()
				if vim.g.devcontainer_selected_config == nil or vim.g.devcontainer_selected_config == "" then
					local candidates = vim.split(
						vim.fn.glob(vim.loop.cwd() .. "/.devcontainer/**/devcontainer.json"),
						"\n",
						{ trimempty = true }
					)
					if #candidates < 2 then
						vim.g.devcontainer_selected_config = vim.loop.cwd()
					else
						local choices = { "Select devcontainer config file to use:" }
						for idx, candidate in ipairs(candidates) do
							table.insert(choices, idx .. ". - " .. candidate)
						end
						local choice_idx = vim.fn.inputlist(choices)
						if choice_idx > #candidates then
							choice_idx = 1
						end
						vim.g.devcontainer_selected_config =
							string.gsub(candidates[choice_idx], "/devcontainer.json", "")
					end
				end
				return vim.g.devcontainer_selected_config
			end,
			workspace_folder_provider = function()
				-- By default this function uses first workspace folder for integrated lsp if available and vim.loop.cwd() as a fallback
				-- This is used to replace `${localWorkspaceFolder}` in devcontainer.json
				-- Also used for creating default .devcontainer.json file
				local bufdir = vim.fn.expand("%:p:h")
				if bufdir ~= nil and bufdir ~= "" then
					return bufdir
				end
				return vim.loop.cwd() or vim.fn.getcwd() or "."
			end,
			-- terminal_handler = function(command)
			-- 	-- By default this function creates a terminal in a new tab using :terminal command
			-- 	-- It also removes statusline when that tab is active, to prevent double statusline
			-- 	-- It can be overridden to provide custom terminal handling
			-- end,
			-- nvim_installation_commands_provider = function(path_binaries, version_string)
			-- 	-- Returns table - list of commands to run when adding neovim to container
			-- 	-- Each command can either be a string or a table (list of command parts)
			-- 	-- Takes binaries available in path on current container and version_string passed to the command or current version of neovim
			-- end,
			-- devcontainer_json_template = function()
			-- 	-- Returns table - list of lines to set when creating new devcontainer.json files
			-- 	-- As a template
			-- 	-- Used only when using functions from commands module or created commands
			-- end,
			-- Can be set to false to prevent generating default commands
			-- Default commands are listed below
			generate_commands = true,
			-- By default no autocommands are generated
			-- This option can be used to configure automatic starting and cleaning of containers
			autocommands = {
				-- can be set to true to automatically start containers when devcontainer.json is available
				init = false,
				-- can be set to true to automatically remove any started containers and any built images when exiting vim
				clean = false,
				-- can be set to true to automatically restart containers when devcontainer.json file is updated
				update = false,
			},
			-- can be changed to increase or decrease logging from library
			log_level = "info",
			-- can be set to true to disable recursive search
			-- in that case only .devcontainer.json and .devcontainer/devcontainer.json files will be checked relative
			-- to the directory provided by config_search_start
			disable_recursive_config_search = false,
			-- can be set to false to disable image caching when adding neovim
			-- by default it is set to true to make attaching to containers faster after first time
			cache_images = true,
			-- By default all mounts are added (config, data and state)
			-- This can be changed to disable mounts or change their options
			-- This can be useful to mount local configuration
			-- And any other mounts when attaching to containers with this plugin
			attach_mounts = {
				neovim_config = {
					-- enables mounting local config to /root/.config/nvim in container
					enabled = true,
					-- makes mount readonly in container
					options = { "readonly" },
				},
				neovim_data = {
					-- enables mounting local data to /root/.local/share/nvim in container
					enabled = false,
					-- no options by default
					options = {},
				},
				-- Only useful if using neovim 0.8.0+
				neovim_state = {
					-- enables mounting local state to /root/.local/state/nvim in container
					enabled = false,
					-- no options by default
					options = {},
				},
			},
			-- This takes a list of mounts (strings) that should always be added to every run container
			-- This is passed directly as --mount option to docker command
			-- Or multiple --mount options if there are multiple values
			always_mount = {},
			-- This takes a string (usually either "podman" or "docker") representing container runtime - "devcontainer-cli" is also partially supported
			-- That is the command that will be invoked for container operations
			-- If it is nil, plugin will use whatever is available (trying "podman" first)
			container_runtime = "docker",
			-- Similar to container runtime, but will be used if main runtime does not support an action - useful for "devcontainer-cli"
			backup_runtime = nil,
			-- This takes a string (usually either "podman-compose" or "docker-compose") representing compose command - "devcontainer-cli" is also partially supported
			-- That is the command that will be invoked for compose operations
			-- If it is nil, plugin will use whatever is available (trying "podman-compose" first)
			compose_command = "docker-compose",
			-- Similar to compose command, but will be used if main command does not support an action - useful for "devcontainer-cli"
			backup_compose_command = nil,
		})
	end,
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n" },
			{ "<leader>d", group = "Docker" },
			{ "<leader>db", group = "Build (docker)" },
			{ "<leader>dc", group = "Compose (docker)" },
			{ "<leader>do", group = "Open (docker)" },
			{ "<leader>dr", group = "Run (docker)" },
		})
	end,
	keys = {
		{
			"<leader>dcu",
			function()
				require("devcontainer.commands").compose_up()
			end,
			desc = "Compose up (docker)",
		},
		{
			"<leader>dcd",
			function()
				require("devcontainer.commands").compose_down()
			end,
			desc = "Compose down (docker)",
		},
		{
			"<leader>dcD",
			function()
				require("devcontainer.commands").compose_rm()
			end,
			desc = "Compose remove (docker)",
		},
		{
			"<leader>dbb",
			function()
				require("devcontainer.commands").docker_build()
			end,
			desc = "Build (docker)",
		},
		{
			"<leader>dri",
			function()
				require("devcontainer.commands").docker_image_run()
			end,
			desc = "Image run (docker)",
		},
		{
			"<leader>dbr",
			function()
				require("devcontainer.commands").docker_build_and_run()
			end,
			desc = "Build & run (docker)",
		},
		{
			"<leader>dba",
			function()
				require("devcontainer.commands").docker_build_run_and_attach()
			end,
			desc = "Build & attach (docker)",
		},
		{
			"<leader>ds",
			function()
				require("devcontainer.commands").start_auto()
			end,
			desc = "Start (docker)",
		},
		{
			"<leader>da",
			function()
				require("devcontainer.commands").attach_auto()
			end,
			desc = "Attach (docker)",
		},
		{
			"<leader>drr",
			function()
				require("devcontainer.commands").exec("devcontainer", "ls", { on_success = function(result) end })
			end,
			desc = "Execute (docker)",
		},
		{
			"<leader>dx",
			function()
				require("devcontainer.commands").stop_auto()
			end,
			desc = "Stop (docker)",
		},
		{
			"<leader>dX",
			function()
				require("devcontainer.commands").stop_all()
			end,
			desc = "Stop all (docker)",
		},
		{
			"<leader>dD",
			function()
				require("devcontainer.commands").remove_all()
			end,
			desc = "Remove all (docker)",
		},
		{
			"<leader>dol",
			function()
				require("devcontainer.commands").open_logs()
			end,
			desc = "Open logs (docker)",
		},
		{
			"<leader>doc",
			function()
				require("devcontainer.commands").open_nearest_devcontainer_config()
			end,
			desc = "Open nearest config (docker)",
		},
		{
			"<leader>de",
			function()
				require("devcontainer.commands").edit_devcontainer_config()
			end,
			desc = "Edit nearest config (docker)",
		},
	},
}
