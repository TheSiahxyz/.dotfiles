return {
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
		config = function()
			local mcphub = require("mcphub")
			mcphub.setup({
				--- `mcp-hub` binary related options-------------------
				config = vim.fn.expand("~/.config/mcphub/servers.json"), -- Absolute path to MCP Servers config file (will create if not exists)
				port = 37373, -- The port `mcp-hub` server listens to
				shutdown_delay = 5 * 60 * 000, -- Delay in ms before shutting down the server when last instance closes (default: 5 minutes)
				use_bundled_binary = false, -- Use local `mcp-hub` binary (set this to true when using build = "bundled_build.lua")
				mcp_request_timeout = 60000, --Max time allowed for a MCP tool or resource to execute in milliseconds, set longer for long running tasks
				global_env = {}, -- Global environment variables available to all MCP servers (can be a table or a function returning a table)
				workspace = {
					enabled = true, -- Enable project-local configuration files
					look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" }, -- Files to look for when detecting project boundaries (VS Code format supported)
					reload_on_dir_changed = true, -- Automatically switch hubs on DirChanged event
					port_range = { min = 40000, max = 41000 }, -- Port range for generating unique workspace ports
					get_port = nil, -- Optional function returning custom port number. Called when generating ports to allow custom port assignment logic
				},

				---Chat-plugin related options-----------------
				auto_approve = function(params)
					-- Auto-approve GitHub issue reading
					if params.server_name == "github" and params.tool_name == "get_issue" then
						return true -- Auto approve
					end

					-- Block access to private repos
					if params.arguments.repo == "private" then
						return "You can't access my private repo" -- Error message
					end

					-- Auto-approve safe file operations in current project
					if params.tool_name == "read_file" then
						local path = params.arguments.path or ""
						if path:match("^" .. vim.fn.getcwd()) then
							return true -- Auto approve
						end
					end

					-- Check if tool is configured for auto-approval in servers.json
					if params.is_auto_approved_in_server then
						return true -- Respect servers.json configuration
					end

					return false -- Show confirmation prompt
				end, -- Auto approve mcp tool calls
				auto_toggle_mcp_servers = true, -- Let LLMs start and stop MCP servers automatically
				extensions = {
					avante = {
						make_slash_commands = true, -- make /slash commands from MCP server prompts
					},
				},

				--- Plugin specific options-------------------
				native_servers = {}, -- add your custom lua native servers here
				builtin_tools = {
					edit_file = {
						parser = {
							track_issues = true,
							extract_inline_content = true,
						},
						locator = {
							fuzzy_threshold = 0.8,
							enable_fuzzy_matching = true,
						},
						ui = {
							go_to_origin_on_complete = true,
							keybindings = {
								accept = ".",
								reject = ",",
								next = "n",
								prev = "p",
								accept_all = "ga",
								reject_all = "gr",
							},
						},
					},
				},
				ui = {
					window = {
						width = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
						height = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
						align = "center", -- "center", "top-left", "top-right", "bottom-left", "bottom-right", "top", "bottom", "left", "right"
						relative = "editor",
						zindex = 50,
						border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
					},
					wo = { -- window-scoped options (vim.wo)
						winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder",
					},
				},
				json_decode = nil, -- Custom JSON parser function (e.g., require('json5').parse for JSON5 support)
				on_ready = function(hub)
					-- Called when hub is ready
				end,
				on_error = function(err)
					-- Called on errors
				end,
				log = {
					level = vim.log.levels.WARN,
					to_file = false,
					file_path = nil,
					prefix = "MCPHub",
				},
			})

			-- LSP diagnostics as a resource
			mcphub.add_resource("neovim", {
				name = "Diagnostics: Current File",
				description = "Get diagnostics for the current file",
				uri = "neovim://diagnostics/current",
				mimeType = "text/plain",
				handler = function(req, res)
					-- Get active buffer
					local buf_info = req.editor_info.last_active
					if not buf_info then
						return res:error("No active buffer")
					end

					-- Get diagnostics
					local diagnostics = vim.diagnostic.get(buf_info.bufnr)

					-- Format header
					local text = string.format("Diagnostics for: %s\n%s\n", buf_info.filename, string.rep("-", 40))

					-- Format diagnostics
					for _, diag in ipairs(diagnostics) do
						local severity = vim.diagnostic.severity[diag.severity]
						text = text
							.. string.format(
								"\n%s: %s\nLine %d: %s\n",
								severity,
								diag.source or "unknown",
								diag.lnum + 1,
								diag.message
							)
					end

					return res:text(text):send()
				end,
			})

			mcphub.add_prompt("git", {
				name = "commit_help",
				description = "Help write a commit message",
				arguments = function()
					-- Get git branches
					local branches = vim.fn.systemlist("git branch --format='%(refname:short)'")

					return {
						{
							name = "type",
							description = "Commit type",
							required = true,
							-- Provide standard options
							default = "feat",
							enum = {
								"feat",
								"fix",
								"docs",
								"style",
								"refactor",
								"test",
								"chore",
							},
						},
						{
							name = "branch",
							description = "Target branch",
							-- Use actual branches
							enum = branches,
						},
					}
				end,
				handler = function(req, res)
					return res:system()
						:text(
							string.format("Help write a %s commit for branch: %s", req.params.type, req.params.branch)
						)
						:send()
				end,
			})

			mcphub.add_prompt("editor", {
				name = "review_code",
				arguments = {
					{
						name = "style",
						description = "Review style",
						enum = { "brief", "detailed" },
					},
				},
				handler = function(req, res)
					-- Get current buffer
					local buf = req.editor_info.last_active
					if not buf then
						return res:error("No active buffer")
					end

					-- Generate code overview
					local overview = generate_overview(buf)

					return res
						-- Set review context
						:system()
						:text("You are a code reviewer.\n" .. "Style: " .. req.params.style)
						-- Add code visualization
						:image(overview, "image/png")
						:text("Above is a visualization of the code structure.")
						-- Add relevant resources
						:resource({
							uri = "neovim://diagnostics/current",
							mimeType = "text/plain",
						})
						:text("Above are the current diagnostics.")
						-- Send prompt
						:send()
				end,
			})

			mcphub.add_prompt("context", {
				name = "explain_code",
				handler = function(req, res)
					-- Start with base behavior
					res:system():text("You are a code explanation assistant.")

					-- Add context based on caller
					if req.caller.type == "codecompanion" then
						-- Add CodeCompanion chat context
						local chat = req.caller.codecompanion.chat
						res:text("\nPrevious discussion:\n" .. chat.history)
					elseif req.caller.type == "avante" then
						-- Add Avante code context
						local code = req.caller.avante.code
						res:text("\nSelected code:\n" .. code)
					end

					-- Add example interactions
					res:user():text("Explain this code"):llm():text("I'll explain the code in detail...")

					return res:send()
				end,
			})
		end,
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n" },
				{ "<leader>mc", group = "MCP" },
			})
		end,
		keys = {
			{ "<leader>mcp", ":MCPHub<CR>", desc = "MCP Hub" },
		},
	},
	{
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		opts = {
			terminal_cmd = "~/.local/bin/claude", -- Point to local installation
		},
		config = function()
			require("claudecode").setup({
				-- Top-level aliases are supported and forwarded to terminal config
				git_repo_cwd = true,
			})
		end,
		keys = {
			{ "<leader>a", nil, desc = "AI/Claude Code" },
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Add file",
				ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
			},
			-- Diff management
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
	},
	-- {
	-- 	"NickvanDyke/opencode.nvim",
	-- 	dependencies = {
	-- 		-- Recommended for `ask()` and `select()`.
	-- 		-- Required for `snacks` provider.
	-- 		---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
	-- 		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	-- 	},
	-- 	config = function()
	-- 		---@type opencode.Opts
	-- 		vim.g.opencode_opts = {
	-- 			-- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
	-- 		}
	--
	-- 		-- Required for `opts.events.reload`.
	-- 		vim.o.autoread = true
	--
	-- 		-- Recommended/example keymaps.
	-- 		vim.keymap.set({ "n", "x" }, "<C-q>", function()
	-- 			require("opencode").ask("@this: ", { submit = true })
	-- 		end, { desc = "Ask opencode" })
	-- 		vim.keymap.set({ "n", "x" }, "<C-CR>", function()
	-- 			require("opencode").select()
	-- 		end, { desc = "Execute opencode action…" })
	-- 		vim.keymap.set({ "n", "t" }, "<C-.>", function()
	-- 			require("opencode").toggle()
	-- 		end, { desc = "Toggle opencode" })
	--
	-- 		vim.keymap.set({ "n", "x" }, "go", function()
	-- 			return require("opencode").operator("@this ")
	-- 		end, { expr = true, desc = "Add range to opencode" })
	-- 		vim.keymap.set("n", "goo", function()
	-- 			return require("opencode").operator("@this ") .. "_"
	-- 		end, { expr = true, desc = "Add line to opencode" })
	--
	-- 		vim.keymap.set("n", "<S-C-u>", function()
	-- 			require("opencode").command("session.half.page.up")
	-- 		end, { desc = "opencode half page up" })
	-- 		vim.keymap.set("n", "<S-C-d>", function()
	-- 			require("opencode").command("session.half.page.down")
	-- 		end, { desc = "opencode half page down" })
	--
	-- 		-- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
	-- 		vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
	-- 		vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
	-- 	end,
	-- },
}
