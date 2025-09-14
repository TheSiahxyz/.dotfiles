return {
	{
		"yetone/avante.nvim",
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		-- ⚠️ must add this setting! ! !
		build = vim.fn.has("win32") ~= 0
				and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
			or "make",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			-- "echasnovski/mini.pick", -- for file_selector provider mini.pick
			-- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			-- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			-- "ibhagwan/fzf-lua", -- for file_selector provider fzf
			-- "stevearc/dressing.nvim", -- for input provider dressing
			-- "folke/snacks.nvim", -- for input provider snacks
			-- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			-- "zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		config = function()
			require("avante").setup({
				instructions_file = "avante.md",
				---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
				---@type Provider
				provider = "openai", -- The provider used in Aider mode or in the planning phase of Cursor Planning Mode
				---@alias Mode "agentic" | "legacy"
				---@type Mode
				mode = "agentic", -- The default mode for interaction. "agentic" uses tools to automatically generate code, "legacy" uses the old planning method to generate code.
				-- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
				-- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
				-- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
				auto_suggestions_provider = "claude",
				providers = {
					claude = {
						endpoint = "https://api.anthropic.com",
						model = "claude-sonnet-4-20250514",
						timeout = 30000, -- Timeout in milliseconds
						extra_request_body = {
							temperature = 0.75,
							max_tokens = 20480,
						},
					},
					moonshot = {
						endpoint = "https://api.moonshot.ai/v1",
						model = "kimi-k2-0711-preview",
						timeout = 30000, -- Timeout in milliseconds
						extra_request_body = {
							temperature = 0.75,
							max_tokens = 32768,
						},
					},
				},
				---Specify the special dual_boost mode
				---1. enabled: Whether to enable dual_boost mode. Default to false.
				---2. first_provider: The first provider to generate response. Default to "openai".
				---3. second_provider: The second provider to generate response. Default to "claude".
				---4. prompt: The prompt to generate response based on the two reference outputs.
				---5. timeout: Timeout in milliseconds. Default to 60000.
				---How it works:
				--- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
				---Note: This is an experimental feature and may not work as expected.
				dual_boost = {
					enabled = false,
					first_provider = "openai",
					second_provider = "claude",
					prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
					timeout = 60000, -- Timeout in milliseconds
				},
				behaviour = {
					auto_suggestions = false, -- Experimental stage
					auto_set_highlight_group = true,
					auto_set_keymaps = true,
					auto_apply_diff_after_generation = false,
					support_paste_from_clipboard = false,
					minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
					enable_token_counting = true, -- Whether to enable token counting. Default to true.
					auto_approve_tool_permissions = false, -- Default: show permission prompts for all tools
					-- Examples:
					-- auto_approve_tool_permissions = true,                -- Auto-approve all tools (no prompts)
					-- auto_approve_tool_permissions = {"bash", "replace_in_file"}, -- Auto-approve specific tools only
				},
				prompt_logger = { -- logs prompts to disk (timestamped, for replay/debugging)
					enabled = true, -- toggle logging entirely
					log_dir = vim.fn.stdpath("cache") .. "/avante_prompts", -- directory where logs are saved
					fortune_cookie_on_success = false, -- shows a random fortune after each logged prompt (requires `fortune` installed)
					next_prompt = {
						normal = "<C-n>", -- load the next (newer) prompt log in normal mode
						insert = "<C-n>",
					},
					prev_prompt = {
						normal = "<C-p>", -- load the previous (older) prompt log in normal mode
						insert = "<C-p>",
					},
				},
				mappings = {
					--- @class AvanteConflictMappings
					diff = {
						ours = "co",
						theirs = "ct",
						all_theirs = "ca",
						both = "cb",
						cursor = "cc",
						next = "]x",
						prev = "[x",
					},
					suggestion = {
						accept = "<M-l>",
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<C-]>",
					},
					jump = {
						next = "]]",
						prev = "[[",
					},
					submit = {
						normal = "<CR>",
						insert = "<C-s>",
					},
					cancel = {
						normal = { "<C-c>", "<Esc>", "q" },
						insert = { "<C-c>" },
					},
					sidebar = {
						apply_all = "A",
						apply_cursor = "a",
						retry_user_request = "r",
						edit_user_request = "e",
						switch_windows = "<Tab>",
						reverse_switch_windows = "<S-Tab>",
						remove_file = "d",
						add_file = "@",
						close = { "<Esc>", "q" },
						close_from_input = nil, -- e.g., { normal = "<Esc>", insert = "<C-d>" }
					},
				},
				selection = {
					enabled = true,
					hint_display = "delayed",
				},
				windows = {
					---@type "right" | "left" | "top" | "bottom"
					position = "right", -- the position of the sidebar
					wrap = true, -- similar to vim.o.wrap
					width = 30, -- default % based on available width
					sidebar_header = {
						enabled = true, -- true, false to enable/disable the header
						align = "center", -- left, center, right for title
						rounded = true,
					},
					spinner = {
						editing = {
							"⡀",
							"⠄",
							"⠂",
							"⠁",
							"⠈",
							"⠐",
							"⠠",
							"⢀",
							"⣀",
							"⢄",
							"⢂",
							"⢁",
							"⢈",
							"⢐",
							"⢠",
							"⣠",
							"⢤",
							"⢢",
							"⢡",
							"⢨",
							"⢰",
							"⣰",
							"⢴",
							"⢲",
							"⢱",
							"⢸",
							"⣸",
							"⢼",
							"⢺",
							"⢹",
							"⣹",
							"⢽",
							"⢻",
							"⣻",
							"⢿",
							"⣿",
						},
						generating = { "·", "✢", "✳", "∗", "✻", "✽" }, -- Spinner characters for the 'generating' state
						thinking = { "🤯", "🙄" }, -- Spinner characters for the 'thinking' state
					},
					input = {
						prefix = "> ",
						height = 8, -- Height of the input window in vertical layout
					},
					edit = {
						border = "rounded",
						start_insert = true, -- Start insert mode when opening the edit window
					},
					ask = {
						floating = false, -- Open the 'AvanteAsk' prompt in a floating window
						start_insert = true, -- Start insert mode when opening the ask window
						border = "rounded",
						---@type "ours" | "theirs"
						focus_on_apply = "ours", -- which diff to focus after applying
					},
				},
				highlights = {
					---@type AvanteConflictHighlights
					diff = {
						current = "DiffText",
						incoming = "DiffAdd",
					},
				},
				--- @class AvanteConflictUserConfig
				diff = {
					autojump = true,
					---@type string | fun(): any
					list_opener = "copen",
					--- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
					--- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
					--- Disable by setting to -1.
					override_timeoutlen = 500,
				},
				suggestion = {
					debounce = 600,
					throttle = 600,
				},
			})
		end,
		keys = {
			{
				"<leader>ae",
				function()
					require("avante.api").edit()
				end,
				desc = "avante: edit",
				mode = { "n", "v" },
			},
			{
				"<leader>ai",
				function()
					return vim.bo.filetype == "AvanteInput" and require("avante.clipboard").paste_image()
						or require("img-clip").paste_image()
				end,
				desc = "clip: paste image",
			},
		},
	},
	-- {
	-- 	"robitx/gp.nvim",
	-- 	init = function()
	-- 		local wk = require("which-key")
	-- 		wk.add({
	-- 			mode = { "n", "v", "x" },
	-- 			{ "<leader>G", group = "GPT" },
	-- 			{ "<leader>Gg", group = "Gp" },
	-- 			{ "<leader>GW", group = "Whisper" },
	-- 		})
	-- 	end,
	-- 	config = function()
	-- 		local function keymapOptions(desc)
	-- 			return {
	-- 				noremap = true,
	-- 				silent = true,
	-- 				nowait = true,
	-- 				desc = desc,
	-- 			}
	-- 		end
	--
	-- 		local conf = {
	-- 			-- For customization, refer to Install > Configuration in the Documentation/Readme
	-- 			-- openai_api_key = { "pass", "show", "api/chatGPT/nvim" },
	-- 			openai_api_key = { "pass", "show", "api/chatGPT/nvim" },
	-- 			providers = {
	-- 				openai = {
	-- 					disable = false,
	-- 					endpoint = "https://api.openai.com/v1/chat/completions",
	-- 					-- secret = { "pass", "show", "api/chatGPT/nvim" },
	-- 				},
	-- 			},
	-- 			hooks = {
	-- 				-- GpInspectPlugin provides a detailed inspection of the plugin state
	-- 				InspectPlugin = function(plugin, params)
	-- 					local bufnr = vim.api.nvim_create_buf(false, true)
	-- 					local copy = vim.deepcopy(plugin)
	-- 					local key = copy.config.openai_api_key or ""
	-- 					copy.config.openai_api_key = key:sub(1, 3) .. string.rep("*", #key - 6) .. key:sub(-3)
	-- 					local plugin_info = string.format("Plugin structure:\n%s", vim.inspect(copy))
	-- 					local params_info = string.format("Command params:\n%s", vim.inspect(params))
	-- 					local lines = vim.split(plugin_info .. "\n" .. params_info, "\n")
	-- 					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	-- 					vim.api.nvim_win_set_buf(0, bufnr)
	-- 				end,
	--
	-- 				-- GpInspectLog for checking the log file
	-- 				InspectLog = function(plugin, params)
	-- 					local log_file = plugin.config.log_file
	-- 					local buffer = plugin.helpers.get_buffer(log_file)
	-- 					if not buffer then
	-- 						vim.cmd("e " .. log_file)
	-- 					else
	-- 						vim.cmd("buffer " .. buffer)
	-- 					end
	-- 				end,
	--
	-- 				-- GpImplement rewrites the provided selection/range based on comments in it
	-- 				Implement = function(gp, params)
	-- 					local template = "Having following from {{filename}}:\n\n"
	-- 						.. "```{{filetype}}\n{{selection}}\n```\n\n"
	-- 						.. "Please rewrite this according to the contained instructions."
	-- 						.. "\n\nRespond exclusively with the snippet that should replace the selection above."
	--
	-- 					local agent = gp.get_command_agent()
	-- 					gp.logger.info("Implementing selection with agent: " .. agent.name)
	--
	-- 					gp.Prompt(
	-- 						params,
	-- 						gp.Target.rewrite,
	-- 						agent,
	-- 						template,
	-- 						nil, -- command will run directly without any prompting for user input
	-- 						nil -- no predefined instructions (e.g. speech-to-text from Whisper)
	-- 					)
	-- 				end,
	--
	-- 				-- your own functions can go here, see README for more examples like
	-- 				-- :GpExplain, :GpUnitTests.., :GpTranslator etc.
	--
	-- 				-- example of making :%GpChatNew a dedicated command which
	-- 				-- opens new chat with the entire current buffer as a context
	-- 				BufferChatNew = function(gp, _)
	-- 					-- call GpChatNew command in range mode on whole buffer
	-- 					vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
	-- 				end,
	--
	-- 				-- example of adding command which opens new chat dedicated for translation
	-- 				Translator = function(gp, params)
	-- 					local chat_system_prompt = "You are a Translator, please translate between English and Korean."
	-- 					gp.cmd.ChatNew(params, chat_system_prompt)
	--
	-- 					-- -- you can also create a chat with a specific fixed agent like this:
	-- 					-- local agent = gp.get_chat_agent("ChatGPT4o")
	-- 					-- gp.cmd.ChatNew(params, chat_system_prompt, agent)
	-- 				end,
	--
	-- 				-- example of adding command which writes unit tests for the selected code
	-- 				UnitTests = function(gp, params)
	-- 					local template = "I have the following code from {{filename}}:\n\n"
	-- 						.. "```{{filetype}}\n{{selection}}\n```\n\n"
	-- 						.. "Please respond by writing table driven unit tests for the code above."
	-- 					local agent = gp.get_command_agent()
	-- 					gp.Prompt(params, gp.Target.enew, agent, template)
	-- 				end,
	--
	-- 				-- example of adding command which explains the selected code
	-- 				Explain = function(gp, params)
	-- 					local template = "I have the following code from {{filename}}:\n\n"
	-- 						.. "```{{filetype}}\n{{selection}}\n```\n\n"
	-- 						.. "Please respond by explaining the code above."
	-- 					local agent = gp.get_chat_agent()
	-- 					gp.Prompt(params, gp.Target.popup, agent, template)
	-- 				end,
	--
	-- 				-- example of usig enew as a function specifying type for the new buffer
	-- 				CodeReview = function(gp, params)
	-- 					local template = "I have the following code from {{filename}}:\n\n"
	-- 						.. "```{{filetype}}\n{{selection}}\n```\n\n"
	-- 						.. "Please analyze for code smells and suggest improvements."
	-- 					local agent = gp.get_chat_agent()
	-- 					gp.Prompt(params, gp.Target.enew("markdown"), agent, template)
	-- 				end,
	-- 			},
	-- 		}
	-- 		require("gp").setup(conf)
	--
	-- 		-- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
	-- 		vim.keymap.set("n", "<leader>Gc", "<Cmd>GpChatNew<cr>", keymapOptions("New chat"))
	-- 		vim.keymap.set("n", "<leader>Gb", "<Cmd>GpBufferChatNew<cr>", keymapOptions("New buffer chat"))
	-- 		vim.keymap.set("n", "<leader>Gt", "<Cmd>GpChatToggle<cr>", keymapOptions("Toggle chat"))
	-- 		vim.keymap.set("n", "<leader>Gf", "<Cmd>GpChatFinder<cr>", keymapOptions("Chat finder"))
	--
	-- 		vim.keymap.set("v", "<leader>Gc", ":<C-u>'<,'>GpChatNew<cr>", keymapOptions("Chat new"))
	-- 		vim.keymap.set("v", "<leader>Gb", ":<C-u>'<,'>GpBufferChatNew<cr>", keymapOptions("Buffer chat new"))
	-- 		vim.keymap.set("v", "<leader>Gp", ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions("Chat paste"))
	-- 		vim.keymap.set("v", "<leader>Gt", ":<C-u>'<,'>GpChatToggle<cr>", keymapOptions("Toggle chat"))
	--
	-- 		vim.keymap.set("n", "<leader>Gh", "<Cmd>gpchatnew split<cr>", keymapOptions("New chat split"))
	-- 		vim.keymap.set("n", "<leader>Gv", "<Cmd>gpchatnew vsplit<cr>", keymapOptions("New chat vsplit"))
	-- 		vim.keymap.set("n", "<leader>Gn", "<Cmd>gpchatnew tabnew<cr>", keymapOptions("New chat tabnew"))
	--
	-- 		vim.keymap.set("v", "<leader>Gh", ":<C-u>'<,'>GpChatNew split<cr>", keymapOptions("Chat new split"))
	-- 		vim.keymap.set("v", "<leader>Gv", ":<C-u>'<,'>GpChatNew vsplit<cr>", keymapOptions("Chat new vsplit"))
	-- 		vim.keymap.set("v", "<leader>Gn", ":<C-u>'<,'>GpChatNew tabnew<cr>", keymapOptions("Chat new tabnew"))
	--
	-- 		-- Prompt commands
	-- 		vim.keymap.set("n", "<leader>Gw", "<Cmd>GpRewrite<cr>", keymapOptions("Inline rewrite"))
	-- 		vim.keymap.set("n", "<leader>Gr", "<Cmd>GpCodeReview<cr>", keymapOptions("Code review"))
	-- 		vim.keymap.set("n", "<leader>G]", "<Cmd>GpAppend<cr>", keymapOptions("Append (after)"))
	-- 		vim.keymap.set("n", "<leader>G[", "<Cmd>GpPrepend<cr>", keymapOptions("Prepend (before)"))
	--
	-- 		vim.keymap.set("v", "<leader>Gw", ":<C-u>'<,'>GpRewrite<cr>", keymapOptions("Rewrite"))
	-- 		vim.keymap.set("v", "<leader>Gr", ":<C-u>'<,'>GpCodeReview<cr>", keymapOptions("Code review"))
	-- 		vim.keymap.set("v", "<leader>G]", ":<C-u>'<,'>GpAppend<cr>", keymapOptions("Append (after)"))
	-- 		vim.keymap.set("v", "<leader>G[", ":<C-u>'<,'>GpPrepend<cr>", keymapOptions("Prepend (before)"))
	-- 		vim.keymap.set("v", "<leader>Gi", ":<C-u>'<,'>GpImplement<cr>", keymapOptions("Implement selection"))
	--
	-- 		vim.keymap.set("n", "<leader>Ggp", "<Cmd>GpPopup<cr>", keymapOptions("Popup"))
	-- 		vim.keymap.set("n", "<leader>Gge", "<Cmd>GpEnew<cr>", keymapOptions("GpEnew"))
	-- 		vim.keymap.set("n", "<leader>Ggc", "<Cmd>GpNew<cr>", keymapOptions("GpNew"))
	-- 		vim.keymap.set("n", "<leader>Ggv", "<Cmd>GpVnew<cr>", keymapOptions("GpVnew"))
	-- 		vim.keymap.set("n", "<leader>Ggn", "<Cmd>GpTabnew<cr>", keymapOptions("GpTabnew"))
	--
	-- 		vim.keymap.set("v", "<leader>Ggp", ":<C-u>'<,'>GpPopup<cr>", keymapOptions("Popup"))
	-- 		vim.keymap.set("v", "<leader>Gge", ":<C-u>'<,'>GpEnew<cr>", keymapOptions("GpEnew"))
	-- 		vim.keymap.set("v", "<leader>Ggc", ":<C-u>'<,'>GpNew<cr>", keymapOptions("GpNew"))
	-- 		vim.keymap.set("v", "<leader>Ggv", ":<C-u>'<,'>GpVnew<cr>", keymapOptions("GpVnew"))
	-- 		vim.keymap.set("v", "<leader>Ggn", ":<C-u>'<,'>GpTabnew<cr>", keymapOptions("GpTabnew"))
	--
	-- 		vim.keymap.set("n", "<leader>Gx", "<Cmd>GpContext<cr>", keymapOptions("Toggle context"))
	-- 		vim.keymap.set("v", "<leader>Gx", ":<C-u>'<,'>GpContext<cr>", keymapOptions("Toggle context"))
	--
	-- 		vim.keymap.set({ "n", "v", "x" }, "<leader>Ggs", "<Cmd>GpStop<cr>", keymapOptions("Stop"))
	-- 		vim.keymap.set({ "n", "v", "x" }, "<leader>Gg]", "<Cmd>GpNextAgent<cr>", keymapOptions("Next agent"))
	--
	-- 		-- optional Whisper commands with prefix <C-g>w
	-- 		vim.keymap.set("n", "<leader>GWw", "<Cmd>GpWhisper<cr>", keymapOptions("Whisper"))
	-- 		vim.keymap.set("v", "<leader>GWw", ":<C-u>'<,'>GpWhisper<cr>", keymapOptions("Whisper"))
	--
	-- 		vim.keymap.set("n", "<leader>GWr", "<Cmd>GpWhisperRewrite<cr>", keymapOptions("Inline rewrite"))
	-- 		vim.keymap.set("n", "<leader>GW]", "<Cmd>GpWhisperAppend<cr>", keymapOptions("Append (after)"))
	-- 		vim.keymap.set("n", "<leader>GW[", "<Cmd>GpWhisperPrepend<cr>", keymapOptions("Prepend (before) "))
	--
	-- 		vim.keymap.set("v", "<leader>GWr", ":<C-u>'<,'>GpWhisperRewrite<cr>", keymapOptions("Rewrite"))
	-- 		vim.keymap.set("v", "<leader>GW]", ":<C-u>'<,'>GpWhisperAppend<cr>", keymapOptions("Append (after)"))
	-- 		vim.keymap.set("v", "<leader>GW[", ":<C-u>'<,'>GpWhisperPrepend<cr>", keymapOptions("Prepend (before)"))
	--
	-- 		vim.keymap.set("n", "<leader>GWp", "<Cmd>GpWhisperPopup<cr>", keymapOptions("Popup"))
	-- 		vim.keymap.set("n", "<leader>GWe", "<Cmd>GpWhisperEnew<cr>", keymapOptions("Enew"))
	-- 		vim.keymap.set("n", "<leader>GWc", "<Cmd>GpWhisperNew<cr>", keymapOptions("New"))
	-- 		vim.keymap.set("n", "<leader>GWv", "<Cmd>GpWhisperVnew<cr>", keymapOptions("Vnew"))
	-- 		vim.keymap.set("n", "<leader>GWn", "<Cmd>GpWhisperTabnew<cr>", keymapOptions("Tabnew"))
	--
	-- 		vim.keymap.set("v", "<leader>GWp", ":<C-u>'<,'>GpWhisperPopup<cr>", keymapOptions("Popup"))
	-- 		vim.keymap.set("v", "<leader>GWe", ":<C-u>'<,'>GpWhisperEnew<cr>", keymapOptions("Enew"))
	-- 		vim.keymap.set("v", "<leader>GWc", ":<C-u>'<,'>GpWhisperNew<cr>", keymapOptions("New"))
	-- 		vim.keymap.set("v", "<leader>GWv", ":<C-u>'<,'>GpWhisperVnew<cr>", keymapOptions("Vnew"))
	-- 		vim.keymap.set("v", "<leader>GWn", ":<C-u>'<,'>GpWhisperTabnew<cr>", keymapOptions("Tabnew"))
	-- 	end,
	-- },
	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	cmd = "Copilot",
	-- 	build = ":Copilot auth",
	-- 	event = "InsertEnter",
	-- 	dependencies = {
	-- 		"hrsh7th/nvim-cmp",
	-- 		{ "AndreM222/copilot-lualine" },
	-- 		{
	-- 			"zbirenbaum/copilot-cmp",
	-- 			config = function()
	-- 				require("copilot_cmp").setup()
	-- 			end,
	-- 		},
	-- 	},
	-- 	config = function()
	-- 		require("copilot").setup({
	-- 			panel = {
	-- 				enabled = true,
	-- 				auto_refresh = true,
	-- 				keymap = {
	-- 					jump_prev = "[a",
	-- 					jump_next = "]a",
	-- 					accept = "<CR>",
	-- 					refresh = "gr",
	-- 					open = "<C-CR>",
	-- 				},
	-- 				layout = {
	-- 					position = "right", -- | top | left | right
	-- 					ratio = 0.4,
	-- 				},
	-- 			},
	-- 			suggestion = {
	-- 				enabled = true,
	-- 				auto_trigger = true,
	-- 				hide_during_completion = true,
	-- 				debounce = 75,
	-- 				keymap = {
	-- 					accept = "<C-q>",
	-- 					accept_word = false,
	-- 					accept_line = false,
	-- 					next = "<C-n>",
	-- 					prev = "<C-p>",
	-- 					dismiss = "<C-\\>",
	-- 				},
	-- 			},
	-- 			filetypes = {
	-- 				cvs = false,
	-- 				gitcommit = false,
	-- 				gitrebase = false,
	-- 				help = true,
	-- 				hgcommit = false,
	-- 				markdown = true,
	-- 				sh = function()
	-- 					if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
	-- 						-- disable for .env files
	-- 						return false
	-- 					end
	-- 					return true
	-- 				end,
	-- 				svn = false,
	-- 				yaml = false,
	-- 				["."] = false,
	-- 				["*"] = true,
	-- 			},
	-- 			copilot_node_command = "node", -- Node.js version must be > 18.x
	-- 			server_opts_overrides = {},
	-- 		})
	--
	-- 		local cmp = require("cmp")
	-- 		cmp.event:on("menu_opened", function()
	-- 			vim.b.copilot_suggestion_hidden = true
	-- 		end)
	--
	-- 		cmp.event:on("menu_closed", function()
	-- 			vim.b.copilot_suggestion_hidden = false
	-- 		end)
	-- 	end,
	--
	-- 	vim.keymap.set("n", "<leader>ct", function()
	-- 		require("copilot.suggestion").toggle_auto_trigger()
	-- 	end, { noremap = true, silent = true, desc = "Toggle copilot" }),
	-- },
}
