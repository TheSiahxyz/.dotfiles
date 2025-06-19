local function get_args(config)
	local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
	config = vim.deepcopy(config)
	---@cast args string[]
	config.args = function()
		local new_args = vim.fn.input("Run with args: ", table.concat(args, " ")) --[[@as string]]
		return vim.split(vim.fn.expand(new_args) --[[@as string]], " ")
	end
	return config
end

return {
	{
		"mfussenegger/nvim-dap",
		recommended = true,
		desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			-- virtual text for the debugger
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
		},
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n" },
				{ "<localleader>dp", group = "Debug" },
				{ "<localleader>dP", group = "Debug (Python)" },
			})
		end,
		config = function()
			-- load mason-nvim-dap here, after all adapters have been setup
			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

			local dap = require("dap")
			dap.configurations.java = {
				{
					type = "java",
					request = "attach",
					name = "Debug (Attach) - Remote",
					hostName = "127.0.0.1",
					port = 5005,
				},
			}

			local dap_icons = {
				Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
				Breakpoint = " ",
				BreakpointCondition = " ",
				BreakpointRejected = { " ", "DiagnosticError" },
				LogPoint = ".>",
			}

			for name, sign in pairs(dap_icons) do
				sign = type(sign) == "table" and sign or { sign }
				vim.fn.sign_define(
					"Dap" .. name,
					{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
				)
			end

			-- setup dap config by VsCode launch.json file
			local vscode = require("dap.ext.vscode")
			local json = require("plenary.json")
			vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str))
			end
		end,
		keys = {
			{
				"<localleader>dpB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Dap breakpoint condition",
			},
			{
				"<localleader>dpb",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Dap toggle breakpoint",
			},
			{
				"<localleader>dpc",
				function()
					require("dap").continue()
				end,
				desc = "Dap continue",
			},
			{
				"<localleader>dpa",
				function()
					require("dap").continue({ before = get_args })
				end,
				desc = "Dap run with args",
			},
			{
				"<localleader>dpC",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Dap run to cursor",
			},
			{
				"<localleader>dpg",
				function()
					require("dap").goto_()
				end,
				desc = "Dap go to line (no execute)",
			},
			{
				"<localleader>dpi",
				function()
					require("dap").step_into()
				end,
				desc = "Dap step into",
			},
			{
				"<localleader>dpj",
				function()
					require("dap").down()
				end,
				desc = "Dap down",
			},
			{
				"<localleader>dpk",
				function()
					require("dap").up()
				end,
				desc = "Dap up",
			},
			{
				"<localleader>dpl",
				function()
					require("dap").run_last()
				end,
				desc = "Dap run last",
			},
			{
				"<localleader>dpo",
				function()
					require("dap").step_out()
				end,
				desc = "Dap step out",
			},
			{
				"<localleader>dpO",
				function()
					require("dap").step_over()
				end,
				desc = "Dap step over",
			},
			{
				"<localleader>dpp",
				function()
					require("dap").pause()
				end,
				desc = "Dap pause",
			},
			{
				"<localleader>dpr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Dap toggle repl",
			},
			{
				"<localleader>dps",
				function()
					require("dap").session()
				end,
				desc = "Dap session",
			},
			{
				"<localleader>dpt",
				function()
					require("dap").terminate()
				end,
				desc = "Dap terminate",
			},
			{
				"<localleader>dpw",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Dap widgets",
			},
			{
				"<localleader>dpR",
				"<Cmd>lua require('dapui').open({ reset = true })<cr>",
				desc = "Dap UI reset",
			},
		},
	},
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = { "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
		config = function()
			local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
			require("dap-python").setup(path)
		end,
		keys = {
			{
				"<localleader>dPt",
				function()
					require("dap-python").test_method()
				end,
				desc = "Dap debug method",
				ft = "python",
			},
			{
				"<localleader>dPc",
				function()
					require("dap-python").test_class()
				end,
				desc = "Dap debug class",
				ft = "python",
			},
		},
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
				controls = {
					icons = {
						pause = "⏸",
						play = "▶",
						step_into = "⏎",
						step_over = "⏭",
						step_out = "⏮",
						step_back = "b",
						run_last = "▶▶",
						terminate = "⏹",
						disconnect = "⏏",
					},
				},
			})

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.after.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.after.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
		keys = {
			{
				"<localleader>dpu",
				function()
					require("dapui").toggle()
				end,
				desc = "Dap UI",
			},
			{
				"<localleader>dpe",
				function()
					require("dapui").eval()
				end,
				desc = "Dap eval",
			},
		},
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = "mason.nvim",
		cmd = { "DapInstall", "DapUninstall" },
		opts = {
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {},

			-- You'll need to check that you have the required things installed
			-- online, please don't ask me how to install them :)
			ensure_installed = {
				-- Update this to ensure that you have the debuggers for the langs you want
			},
		},
		-- mason-nvim-dap is loaded when nvim-dap loads
		config = function() end,
	},
}
