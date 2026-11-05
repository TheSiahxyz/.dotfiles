return {
	"mrcjkb/rustaceanvim",
	version = "^5",
	ft = { "rust" },
	config = function()
		vim.g.rustaceanvim = {
			tools = {
				hover_actions = {
					auto_focus = true,
				},
			},
			server = {
				on_attach = function(_, bufnr)
					local wk = require("which-key")
					wk.add({
						buffer = bufnr,
						{ "<leader>rr", "<Cmd>RustLsp runnables<CR>", desc = "Runnables" },
						{ "<leader>rd", "<Cmd>RustLsp debuggables<CR>", desc = "Debuggables" },
						{ "<leader>re", "<Cmd>RustLsp expandMacro<CR>", desc = "Expand macro" },
						{ "<leader>rc", "<Cmd>RustLsp openCargo<CR>", desc = "Open Cargo.toml" },
						{ "<leader>rh", "<Cmd>RustLsp hover actions<CR>", desc = "Hover actions" },
					})
				end,
				default_settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							buildScripts = { enable = true },
						},
						checkOnSave = true,
						check = {
							command = "clippy",
							extraArgs = { "--no-deps" },
						},
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
								["async-recursion"] = { "async_recursion" },
							},
						},
					},
				},
			},
			dap = {
				adapter = "codelldb",
			},
		}
	end,
}
