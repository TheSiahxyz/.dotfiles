return {
	"robitx/gp.nvim",
	config = function()
		local function keymapOptions(desc)
			return {
				noremap = true,
				silent = true,
				nowait = true,
				desc = desc,
			}
		end

		local conf = {
			-- For customization, refer to Install > Configuration in the Documentation/Readme
			-- openai_api_key = { "pass", "show", "api/chatGPT/nvim" },
			openai_api_key = { "pass", "show", "api/chatGPT/nvim" },
			providers = {
				openai = {
					disable = false,
					endpoint = "https://api.openai.com/v1/chat/completions",
					-- secret = { "pass", "show", "api/chatGPT/nvim" },
				},
			},
			hooks = {
				-- GpInspectPlugin provides a detailed inspection of the plugin state
				InspectPlugin = function(plugin, params)
					local bufnr = vim.api.nvim_create_buf(false, true)
					local copy = vim.deepcopy(plugin)
					local key = copy.config.openai_api_key or ""
					copy.config.openai_api_key = key:sub(1, 3) .. string.rep("*", #key - 6) .. key:sub(-3)
					local plugin_info = string.format("Plugin structure:\n%s", vim.inspect(copy))
					local params_info = string.format("Command params:\n%s", vim.inspect(params))
					local lines = vim.split(plugin_info .. "\n" .. params_info, "\n")
					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
					vim.api.nvim_win_set_buf(0, bufnr)
				end,

				-- GpInspectLog for checking the log file
				InspectLog = function(plugin, params)
					local log_file = plugin.config.log_file
					local buffer = plugin.helpers.get_buffer(log_file)
					if not buffer then
						vim.cmd("e " .. log_file)
					else
						vim.cmd("buffer " .. buffer)
					end
				end,

				-- GpImplement rewrites the provided selection/range based on comments in it
				Implement = function(gp, params)
					local template = "Having following from {{filename}}:\n\n"
						.. "```{{filetype}}\n{{selection}}\n```\n\n"
						.. "Please rewrite this according to the contained instructions."
						.. "\n\nRespond exclusively with the snippet that should replace the selection above."

					local agent = gp.get_command_agent()
					gp.logger.info("Implementing selection with agent: " .. agent.name)

					gp.Prompt(
						params,
						gp.Target.rewrite,
						agent,
						template,
						nil, -- command will run directly without any prompting for user input
						nil -- no predefined instructions (e.g. speech-to-text from Whisper)
					)
				end,

				-- your own functions can go here, see README for more examples like
				-- :GpExplain, :GpUnitTests.., :GpTranslator etc.

				-- example of making :%GpChatNew a dedicated command which
				-- opens new chat with the entire current buffer as a context
				BufferChatNew = function(gp, _)
					-- call GpChatNew command in range mode on whole buffer
					vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
				end,

				-- example of adding command which opens new chat dedicated for translation
				Translator = function(gp, params)
					local chat_system_prompt = "You are a Translator, please translate between English and Korean."
					gp.cmd.ChatNew(params, chat_system_prompt)

					-- -- you can also create a chat with a specific fixed agent like this:
					-- local agent = gp.get_chat_agent("ChatGPT4o")
					-- gp.cmd.ChatNew(params, chat_system_prompt, agent)
				end,

				-- example of adding command which writes unit tests for the selected code
				UnitTests = function(gp, params)
					local template = "I have the following code from {{filename}}:\n\n"
						.. "```{{filetype}}\n{{selection}}\n```\n\n"
						.. "Please respond by writing table driven unit tests for the code above."
					local agent = gp.get_command_agent()
					gp.Prompt(params, gp.Target.enew, agent, template)
				end,

				-- example of adding command which explains the selected code
				Explain = function(gp, params)
					local template = "I have the following code from {{filename}}:\n\n"
						.. "```{{filetype}}\n{{selection}}\n```\n\n"
						.. "Please respond by explaining the code above."
					local agent = gp.get_chat_agent()
					gp.Prompt(params, gp.Target.popup, agent, template)
				end,

				-- example of usig enew as a function specifying type for the new buffer
				CodeReview = function(gp, params)
					local template = "I have the following code from {{filename}}:\n\n"
						.. "```{{filetype}}\n{{selection}}\n```\n\n"
						.. "Please analyze for code smells and suggest improvements."
					local agent = gp.get_chat_agent()
					gp.Prompt(params, gp.Target.enew("markdown"), agent, template)
				end,
			},
		}
		require("gp").setup(conf)

		-- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
		vim.keymap.set({ "n", "i" }, "<leader>Gc", "<cmd>GpChatNew<cr>", keymapOptions("New Chat"))
		vim.keymap.set({ "n", "i" }, "<leader>Gb", "<cmd>GpBufferChatNew<cr>", keymapOptions("New Buffer Chat"))
		vim.keymap.set({ "n", "i" }, "<leader>Gt", "<cmd>GpChatToggle<cr>", keymapOptions("Toggle Chat"))
		vim.keymap.set({ "n", "i" }, "<leader>Gf", "<cmd>GpChatFinder<cr>", keymapOptions("Chat Finder"))

		vim.keymap.set("v", "<leader>Gc", ":<C-u>'<,'>GpChatNew<cr>", keymapOptions("Visual Chat New"))
		vim.keymap.set("v", "<leader>Gb", ":<C-u>'<,'>GpBufferChatNew<cr>", keymapOptions("Visual Buffer Chat New"))
		vim.keymap.set("v", "<leader>Gp", ":<C-u>'<,'>GpChatPaste<cr>", keymapOptions("Visual Chat Paste"))
		vim.keymap.set("v", "<leader>Gt", ":<C-u>'<,'>GpChatToggle<cr>", keymapOptions("Visual Toggle Chat"))

		vim.keymap.set({ "n", "i" }, "<leader>Gh", "<cmd>GpChatNew split<cr>", keymapOptions("New Chat split"))
		vim.keymap.set({ "n", "i" }, "<leader>Gv", "<cmd>GpChatNew vsplit<cr>", keymapOptions("New Chat vsplit"))
		vim.keymap.set({ "n", "i" }, "<leader>Gn", "<cmd>GpChatNew tabnew<cr>", keymapOptions("New Chat tabnew"))

		vim.keymap.set("v", "<leader>Gh", ":<C-u>'<,'>GpChatNew split<cr>", keymapOptions("Visual Chat New split"))
		vim.keymap.set("v", "<leader>Gv", ":<C-u>'<,'>GpChatNew vsplit<cr>", keymapOptions("Visual Chat New vsplit"))
		vim.keymap.set("v", "<leader>Gn", ":<C-u>'<,'>GpChatNew tabnew<cr>", keymapOptions("Visual Chat New tabnew"))

		-- Prompt commands
		vim.keymap.set({ "n", "i" }, "<leader>Gw", "<cmd>GpRewrite<cr>", keymapOptions("Inline Rewrite"))
		vim.keymap.set({ "n", "i" }, "<leader>Gr", "<cmd>GpCodeReview<cr>", keymapOptions("Code Review"))
		vim.keymap.set({ "n", "i" }, "<leader>G]", "<cmd>GpAppend<cr>", keymapOptions("Append (after)"))
		vim.keymap.set({ "n", "i" }, "<leader>G[", "<cmd>GpPrepend<cr>", keymapOptions("Prepend (before)"))

		vim.keymap.set("v", "<leader>Gw", ":<C-u>'<,'>GpRewrite<cr>", keymapOptions("Visual Rewrite"))
		vim.keymap.set("v", "<leader>Gr", ":<C-u>'<,'>GpCodeReview<cr>", keymapOptions("Visual Code Review"))
		vim.keymap.set("v", "<leader>G]", ":<C-u>'<,'>GpAppend<cr>", keymapOptions("Visual Append (after)"))
		vim.keymap.set("v", "<leader>G[", ":<C-u>'<,'>GpPrepend<cr>", keymapOptions("Visual Prepend (before)"))
		vim.keymap.set("v", "<leader>Gi", ":<C-u>'<,'>GpImplement<cr>", keymapOptions("Implement selection"))

		vim.keymap.set({ "n", "i" }, "<leader>Ggp", "<cmd>GpPopup<cr>", keymapOptions("Popup"))
		vim.keymap.set({ "n", "i" }, "<leader>Gge", "<cmd>GpEnew<cr>", keymapOptions("GpEnew"))
		vim.keymap.set({ "n", "i" }, "<leader>Ggc", "<cmd>GpNew<cr>", keymapOptions("GpNew"))
		vim.keymap.set({ "n", "i" }, "<leader>Ggv", "<cmd>GpVnew<cr>", keymapOptions("GpVnew"))
		vim.keymap.set({ "n", "i" }, "<leader>Ggn", "<cmd>GpTabnew<cr>", keymapOptions("GpTabnew"))

		vim.keymap.set("v", "<leader>Ggp", ":<C-u>'<,'>GpPopup<cr>", keymapOptions("Visual Popup"))
		vim.keymap.set("v", "<leader>Gge", ":<C-u>'<,'>GpEnew<cr>", keymapOptions("Visual GpEnew"))
		vim.keymap.set("v", "<leader>Ggc", ":<C-u>'<,'>GpNew<cr>", keymapOptions("Visual GpNew"))
		vim.keymap.set("v", "<leader>Ggv", ":<C-u>'<,'>GpVnew<cr>", keymapOptions("Visual GpVnew"))
		vim.keymap.set("v", "<leader>Ggn", ":<C-u>'<,'>GpTabnew<cr>", keymapOptions("Visual GpTabnew"))

		vim.keymap.set({ "n", "i" }, "<leader>Gx", "<cmd>GpContext<cr>", keymapOptions("Toggle Context"))
		vim.keymap.set("v", "<leader>Gx", ":<C-u>'<,'>GpContext<cr>", keymapOptions("Visual Toggle Context"))

		vim.keymap.set({ "n", "i", "v", "x" }, "<leader>Ggs", "<cmd>GpStop<cr>", keymapOptions("Stop"))
		vim.keymap.set({ "n", "i", "v", "x" }, "<leader>Gg]", "<cmd>GpNextAgent<cr>", keymapOptions("Next Agent"))

		-- optional Whisper commands with prefix <C-g>w
		vim.keymap.set({ "n", "i" }, "<leader>GWw", "<cmd>GpWhisper<cr>", keymapOptions("Whisper"))
		vim.keymap.set("v", "<leader>GWw", ":<C-u>'<,'>GpWhisper<cr>", keymapOptions("Visual Whisper"))

		vim.keymap.set(
			{ "n", "i" },
			"<leader>GWr",
			"<cmd>GpWhisperRewrite<cr>",
			keymapOptions("Whisper Inline Rewrite")
		)
		vim.keymap.set({ "n", "i" }, "<leader>GW]", "<cmd>GpWhisperAppend<cr>", keymapOptions("Whisper Append (after)"))
		vim.keymap.set(
			{ "n", "i" },
			"<leader>GW[",
			"<cmd>GpWhisperPrepend<cr>",
			keymapOptions("Whisper Prepend (before) ")
		)

		vim.keymap.set("v", "<leader>GWr", ":<C-u>'<,'>GpWhisperRewrite<cr>", keymapOptions("Visual Whisper Rewrite"))
		vim.keymap.set(
			"v",
			"<leader>GW]",
			":<C-u>'<,'>GpWhisperAppend<cr>",
			keymapOptions("Visual Whisper Append (after)")
		)
		vim.keymap.set(
			"v",
			"<leader>GW[",
			":<C-u>'<,'>GpWhisperPrepend<cr>",
			keymapOptions("Visual Whisper Prepend (before)")
		)

		vim.keymap.set({ "n", "i" }, "<leader>GWp", "<cmd>GpWhisperPopup<cr>", keymapOptions("Whisper Popup"))
		vim.keymap.set({ "n", "i" }, "<leader>GWe", "<cmd>GpWhisperEnew<cr>", keymapOptions("Whisper Enew"))
		vim.keymap.set({ "n", "i" }, "<leader>GWc", "<cmd>GpWhisperNew<cr>", keymapOptions("Whisper New"))
		vim.keymap.set({ "n", "i" }, "<leader>GWv", "<cmd>GpWhisperVnew<cr>", keymapOptions("Whisper Vnew"))
		vim.keymap.set({ "n", "i" }, "<leader>GWn", "<cmd>GpWhisperTabnew<cr>", keymapOptions("Whisper Tabnew"))

		vim.keymap.set("v", "<leader>GWp", ":<C-u>'<,'>GpWhisperPopup<cr>", keymapOptions("Visual Whisper Popup"))
		vim.keymap.set("v", "<leader>GWe", ":<C-u>'<,'>GpWhisperEnew<cr>", keymapOptions("Visual Whisper Enew"))
		vim.keymap.set("v", "<leader>GWc", ":<C-u>'<,'>GpWhisperNew<cr>", keymapOptions("Visual Whisper New"))
		vim.keymap.set("v", "<leader>GWv", ":<C-u>'<,'>GpWhisperVnew<cr>", keymapOptions("Visual Whisper Vnew"))
		vim.keymap.set("v", "<leader>GWn", ":<C-u>'<,'>GpWhisperTabnew<cr>", keymapOptions("Visual Whisper Tabnew"))
	end,
}