return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/nvim-cmp",
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
				build = "make install_jsregexp",
			},
			"mfussenegger/nvim-lint",
			"saadparwaiz1/cmp_luasnip",
			"j-hui/fidget.nvim",
			{ "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
			{
				"folke/lazydev.nvim",
				ft = "lua", -- only load on lua files
				opts = {
					library = {
						-- See the configuration section for more details
						-- Load luvit types when the `vim.uv` word is found
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
			"stevearc/conform.nvim",
		},
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v", "x" },
				{ "<leader>tf", group = "Format" },
			})
		end,
		config = function()
			local cmp = require("cmp")
			local cmp_lsp = require("cmp_nvim_lsp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				cmp_lsp.default_capabilities()
			)
			local lspconfig = require("lspconfig")

			require("fidget").setup({
				progress = {
					poll_rate = false, -- How and when to poll for progress messages
					suppress_on_insert = true, -- Suppress new messages while in insert mode
					ignore_done_already = true, -- Ignore new tasks that are already complete
					ignore_empty_message = true, -- Ignore new tasks that don't contain a message
					clear_on_detach = function(client_id) -- Clear notification group when LSP server detaches
						local client = vim.lsp.get_client_by_id(client_id)
						return client and client.name or nil
					end,
					-- ignore = { "lua_ls" },
				},
				notification = {
					window = {
						normal_hl = "Comment", -- Base highlight group in the notification window
						winblend = 0, -- Background color opacity in the notification window
						border = "none", -- Border around the notification window
						zindex = 45, -- Stacking priority of the notification window
						max_width = 0, -- Maximum width of the notification window
						max_height = 0, -- Maximum height of the notification window
						x_padding = 1, -- Padding from right edge of window boundary
						y_padding = 0, -- Padding from bottom edge of window boundary
						align = "bottom", -- How to align the notification window
						relative = "editor", -- What the notification window position is relative to
					},
				},
				integration = {
					["nvim-tree"] = {
						enable = false, -- Integrate with nvim-tree/nvim-tree.lua (if installed)
					},
				},
			})

			require("mason").setup({
				pip = {
					use_python3_host_prog = true,
				},
			})
			require("mason-lspconfig").setup({
				ensure_installed = {
					"bashls",
					"dockerls",
					"docker_compose_language_service",
					"harper_ls",
					"jdtls",
					"jsonls",
					"lua_ls",
					-- "mutt_ls",
					"pyright",
					"ruff",
					"sqls",
					"ts_ls",
				},
				automatic_enable = true,
				handlers = {
					function(server_name) -- default handler (optional)
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
						})
					end,
					["bashls"] = function()
						lspconfig.bashls.setup({
							capabilities = capabilities,
						})
					end,
					["dockerls"] = function()
						lspconfig.dockerls.setup({
							capabilities = capabilities,
							-- settings = {
							-- 	python = {
							-- 		disableLanguageServices = false,
							-- 		disableOrganizeImports = false,
							-- 	},
							-- },
						})
					end,
					["docker_compose_language_service"] = function()
						lspconfig.docker_compose_language_service.setup({
							capabilities = capabilities,
							-- settings = {
							-- 	python = {
							-- 		disableLanguageServices = false,
							-- 		disableOrganizeImports = false,
							-- 	},
							-- },
						})
					end,
					["harper_ls"] = function()
						lspconfig.harper_ls.setup({
							capabilities = capabilities,
							filetypes = { "markdown", "python" },
							settings = {
								ToDoHyphen = false,
								-- SentenceCapitalization = true,
								-- SpellCheck = true,
								isolateEnglish = true,
								markdown = {
									-- [ignores this part]()
									-- [[ also ignores my marksman links ]]
									IgnoreLinkTitle = true,
								},
							},
						})
					end,
					["jdtls"] = function()
						lspconfig.jdtls.setup({
							capabilities = capabilities,
						})
					end,
					["jsonls"] = function()
						lspconfig.jsonls.setup({
							capabilities = capabilities,
							settings = {
								json = {
									format = {
										enable = true,
									},
									validate = { enable = true },
								},
							},
						})
					end,
					["lua_ls"] = function()
						lspconfig.lua_ls.setup({
							capabilities = capabilities,
							settings = {
								Lua = {
									runtime = { version = "Lua 5.4" },
									diagnostics = {
										globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
									},
								},
							},
						})
					end,
					["mutt_ls"] = function()
						lspconfig.mutt_ls.setup({
							capabilities = capabilities,
						})
					end,
					["pyright"] = function()
						lspconfig.pyright.setup({
							capabilities = capabilities,
							settings = {
								python = {
									disableLanguageServices = false,
									disableOrganizeImports = false,
								},
							},
						})
					end,
					["ruff"] = function()
						lspconfig.ruff.setup({
							capabilities = capabilities,
							-- settings = {
							-- 	python = {
							-- 		disableLanguageServices = false,
							-- 		disableOrganizeImports = false,
							-- 	},
							-- },
						})
					end,
					["sqls"] = function()
						lspconfig.sqls.setup({
							capabilities = capabilities,
						})
					end,
					["ts_ls"] = function()
						lspconfig.ruff.setup({
							capabilities = capabilities,
						})
					end,
				},
			})

			local lint = require("lint")
			lint.linters_by_ft = {
				dockerfile = { "hadolint" },
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				python = { "pylint" },
				sh = { "shellcheck" },
				sql = { "sqlfluff" },
				svelte = { "eslint_d" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
			}

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})

			require("mason-tool-installer").setup({
				ensure_installed = {
					"beautysh", -- zsh formatter
					"black", -- python formatter
					"debugpy", -- python debuger
					"eslint_d", -- eslint linter
					-- "hadolint", -- docker linter
					"isort", -- python formatter
					"java-debug-adapter", -- java debugger
					"java-test", -- java test
					"js-debug-adapter", -- javascript debugger
					"markdown-toc", -- markdown toc
					"prettier", -- prettier formatter
					"pylint", -- python linter
					"ruff", -- python formatter
					"shellcheck", -- bash lint
					"shfmt", -- sh formatter
					"sqlfluff", -- sql linter
					"sql-formatter", -- sql formatter
					"stylua", -- lua formatter
				},
				integrations = {
					["mason-lspconfig"] = true,
					["mason-null-ls"] = false,
					["mason-nvim-dap"] = true,
				},
			})

			local cmp_select = { behavior = cmp.SelectBehavior.Select }
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
					["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
					["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
					["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
					["<C-Space>"] = cmp.mapping.complete(),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- For luasnip users.
					{ name = "buffer" },
				}),
			})

			vim.diagnostic.config({
				update_in_insert = true,
				float = {
					header = "",
					border = "rounded",
					prefix = "",
					source = "if_many",
				},
			})

			require("conform").setup({
				formatters_by_ft = {
					bash = { "shfmt" },
					css = { "prettier" },
					graphql = { "prettier" },
					html = { "prettier" },
					javascript = { "prettier" },
					javascriptreact = { "prettier" },
					json = { "prettier" },
					liquid = { "prettier" },
					lua = { "stylua" },
					markdown = { "prettier" },
					python = { "ruff", "isort", "black" },
					sh = { "shfmt" },
					sql = { "sql-formatter" },
					svelte = { "prettier" },
					typescript = { "prettier" },
					typescriptreact = { "prettier" },
					vimwiki = { "prettier" },
					yaml = { "prettier" },
					zsh = { "beautysh" },
				},
				default_format_opts = {},
				format_on_save = function(bufnr)
					-- Disable with a global or buffer-local variable
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					local ft = vim.bo[bufnr].filetype
					local off = {
						javascript = true,
						typescript = true,
						javascriptreact = true,
						typescriptreact = true,
						json = true,
						css = true,
					}
					if off[ft] then
						return false
					end
					return { lsp_fallback = true, timeout_ms = 1000, async = false }
				end,
			})

			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,
		keys = {
			{
				"<leader>lf",
				function()
					require("conform").format({ async = true })
				end,
				mode = { "n", "v" },
				desc = "Format buffer by lsp",
			},
			{
				"<leader>ci",
				"<Cmd>PyrightOrganizeImports<cr>",
				desc = "Organize imports",
			},
			{
				"<leader>bl",
				function()
					require("lint").try_lint()
				end,
				desc = "Buffer lint",
			},
			{
				"<leader>le",
				"<Cmd>FormatEnable<CR>",
				desc = "Enable format",
			},
			{
				"<leader>ld",
				"<Cmd>FormatDisable<CR>",
				desc = "Disable format",
			},
			{
				"<leader>lD",
				"<Cmd>FormatDisable!<CR>",
				desc = "Disable current buffer format",
			},
		},
	},
	-- {
	-- 	"neovim/nvim-lspconfig",
	-- 	event = { "BufReadPre", "BufNewFile" },
	-- 	dependencies = {
	-- 		"mason-org/mason.nvim",
	-- 		"mason-org/mason-lspconfig.nvim",
	-- 		"WhoIsSethDaniel/mason-tool-installer.nvim",
	-- 		"hrsh7th/cmp-nvim-lsp",
	-- 		"hrsh7th/cmp-buffer",
	-- 		"hrsh7th/cmp-path",
	-- 		"hrsh7th/cmp-cmdline",
	-- 		{
	-- 			"L3MON4D3/LuaSnip",
	-- 			version = "v2.*",
	-- 			build = "make install_jsregexp",
	-- 		},
	-- 		"mfussenegger/nvim-lint",
	-- 		"saadparwaiz1/cmp_luasnip",
	-- 		"j-hui/fidget.nvim",
	-- 		{ "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
	--      {
	--      	"folke/lazydev.nvim",
	--      	ft = "lua", -- only load on lua files
	--      	opts = {
	--      		library = {
	--      			-- See the configuration section for more details
	--      			-- Load luvit types when the `vim.uv` word is found
	--      			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	--      		},
	--      	},
	--      },
	-- 		"stevearc/conform.nvim",
	-- 		"saghen/blink.cmp",
	-- 	},
	-- 	init = function()
	-- 		local wk = require("which-key")
	-- 		wk.add({
	-- 			mode = { "n", "v", "x" },
	-- 			{ "<leader>tf", group = "Format" },
	-- 		})
	-- 	end,
	-- 	opts = {
	-- 		servers = {
	-- 			lua_ls = {
	-- 				settings = {
	-- 					Lua = {
	-- 						workspace = {
	-- 							checkThirdParty = false,
	-- 						},
	-- 						codeLens = {
	-- 							enable = true,
	-- 						},
	-- 						completion = {
	-- 							callSnippet = "Replace",
	-- 						},
	-- 						doc = {
	-- 							privateName = { "^_" },
	-- 						},
	-- 						hint = {
	-- 							enable = true,
	-- 							setType = false,
	-- 							paramType = true,
	-- 							paramName = "Disable",
	-- 							semicolon = "Disable",
	-- 							arrayIndex = "Disable",
	-- 						},
	-- 						runtime = { version = "Lua 5.4" },
	-- 						diagnostics = {
	-- 							globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
	-- 						},
	-- 					},
	-- 				},
	-- 			},
	-- 			pyright = {
	-- 				settings = {
	-- 					python = {
	-- 						disableLanguageServices = false,
	-- 						disableOrganizeImports = false,
	-- 					},
	-- 				},
	-- 			},
	-- 		},
	-- 	},
	-- 	config = function(_, opts)
	-- 		local cmp = require("blink.cmp")
	-- 		local lspconfig = require("lspconfig")
	--
	-- 		require("mason").setup()
	--
	-- 		for server, config in pairs(opts.servers) do
	-- 			-- passing config.capabilities to blink.cmp merges with the capabilities in your
	-- 			-- `opts[server].capabilities, if you've defined it
	-- 			config.capabilities = cmp.get_lsp_capabilities(config.capabilities)
	-- 			lspconfig[server].setup(config)
	-- 			require("mason-lspconfig").setup({
	-- 				ensure_installed = { server },
	-- 				handlers = {
	-- 					[server] = function()
	-- 						lspconfig[server].setup(config)
	-- 					end,
	-- 				},
	-- 			})
	-- 		end
	--
	-- 		require("fidget").setup({
	-- 			progress = {
	-- 				poll_rate = 0, -- How and when to poll for progress messages
	-- 				suppress_on_insert = true, -- Suppress new messages while in insert mode
	-- 				ignore_done_already = true, -- Ignore new tasks that are already complete
	-- 				ignore_empty_message = true, -- Ignore new tasks that don't contain a message
	-- 				clear_on_detach = function(client_id) -- Clear notification group when LSP server detaches
	-- 					local client = vim.lsp.get_client_by_id(client_id)
	-- 					return client and client.name or nil
	-- 				end,
	-- 				ignore = { "lua_ls" },
	-- 			},
	-- 			notification = {
	-- 				window = {
	-- 					normal_hl = "Comment", -- Base highlight group in the notification window
	-- 					winblend = 0, -- Background color opacity in the notification window
	-- 					border = "none", -- Border around the notification window
	-- 					zindex = 45, -- Stacking priority of the notification window
	-- 					max_width = 0, -- Maximum width of the notification window
	-- 					max_height = 0, -- Maximum height of the notification window
	-- 					x_padding = 1, -- Padding from right edge of window boundary
	-- 					y_padding = 0, -- Padding from bottom edge of window boundary
	-- 					align = "bottom", -- How to align the notification window
	-- 					relative = "editor", -- What the notification window position is relative to
	-- 				},
	-- 			},
	-- 			integration = {
	-- 				["nvim-tree"] = {
	-- 					enable = false, -- Integrate with nvim-tree/nvim-tree.lua (if installed)
	-- 				},
	-- 			},
	-- 		})
	--
	-- 		local lint = require("lint")
	-- 		lint.linters_by_ft = {
	-- 			javascript = { "eslint_d" },
	-- 			typescript = { "eslint_d" },
	-- 			javascriptreact = { "eslint_d" },
	-- 			typescriptreact = { "eslint_d" },
	-- 			svelte = { "eslint_d" },
	-- 			python = { "pylint" },
	-- 			sh = { "shellcheck" },
	-- 		}
	--
	-- 		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
	-- 		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
	-- 			group = lint_augroup,
	-- 			callback = function()
	-- 				lint.try_lint()
	-- 			end,
	-- 		})
	--
	-- 		require("mason-tool-installer").setup({
	-- 			ensure_installed = {
	-- 				"beautysh", -- zsh formatter
	-- 				"black", -- python formatter
	-- 				"debugpy", -- python debuger
	-- 				"eslint_d", -- eslint linter
	-- 				"isort", -- python formatter
	-- 				"markdown-toc", -- markdown toc
	-- 				"prettier", -- prettier formatter
	-- 				"pylint", -- python linter
	-- 				"ruff", -- python formatter
	-- 				"shellcheck", -- bash lint
	-- 				"shfmt", -- sh formatter
	-- 				"stylua", -- lua formatter
	-- 			},
	-- 			integrations = {
	-- 				["mason-lspconfig"] = true,
	-- 				["mason-null-ls"] = false,
	-- 				["mason-nvim-dap"] = true,
	-- 			},
	-- 		})
	--
	-- 		vim.diagnostic.config({
	-- 			-- update_in_insert = true,
	-- 			float = {
	-- 				focusable = false,
	-- 				style = "minimal",
	-- 				border = "rounded",
	-- 				source = "always",
	-- 				header = "",
	-- 				prefix = "",
	-- 			},
	-- 		})
	--
	-- 		require("conform").setup({
	-- 			formatters_by_ft = {
	-- 				bash = { "shfmt" },
	-- 				css = { "prettier" },
	-- 				graphql = { "prettier" },
	-- 				html = { "prettier" },
	-- 				javascript = { "prettier" },
	-- 				javascriptreact = { "prettier" },
	-- 				json = { "prettier" },
	-- 				liquid = { "prettier" },
	-- 				lua = { "stylua" },
	-- 				markdown = { "prettier" },
	-- 				python = { "ruff", "isort", "black" },
	-- 				sh = { "shfmt" },
	-- 				svelte = { "prettier" },
	-- 				typescript = { "prettier" },
	-- 				typescriptreact = { "prettier" },
	-- 				yaml = { "prettier" },
	-- 				zsh = { "beautysh" },
	-- 			},
	-- 			default_format_opts = {},
	-- 			format_on_save = function(bufnr)
	-- 				-- Disable with a global or buffer-local variable
	-- 				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
	-- 					return
	-- 				end
	-- 				return { lsp_format = "fallback", timeout_ms = 1000, async = false }
	-- 			end,
	-- 		})
	--
	-- 		vim.api.nvim_create_user_command("FormatDisable", function(args)
	-- 			if args.bang then
	-- 				vim.b.disable_autoformat = true
	-- 			else
	-- 				vim.g.disable_autoformat = true
	-- 			end
	-- 		end, {
	-- 			desc = "Disable autoformat-on-save",
	-- 			bang = true,
	-- 		})
	-- 		vim.api.nvim_create_user_command("FormatEnable", function()
	-- 			vim.b.disable_autoformat = false
	-- 			vim.g.disable_autoformat = false
	-- 		end, {
	-- 			desc = "Re-enable autoformat-on-save",
	-- 		})
	-- 	end,
	-- 	keys = {
	-- 		{
	-- 			mode = { "n", "v" },
	-- 			"<leader>lf",
	-- 			function()
	-- 				require("conform").format({ async = true })
	-- 			end,
	-- 			desc = "Format buffer by lsp",
	-- 		},
	-- 		{
	-- 			"<leader>ci",
	-- 			"<Cmd>PyrightOrganizeImports<cr>",
	-- 			desc = "Organize imports",
	-- 		},
	-- 		{
	-- 			"<leader>bl",
	-- 			function()
	-- 				require("lint").try_lint()
	-- 			end,
	-- 			desc = "Buffer lint",
	-- 		},
	-- 		{
	-- 			"<leader>le",
	-- 			"<Cmd>FormatEnable<CR>",
	-- 			desc = "Enable format",
	-- 		},
	-- 		{
	-- 			"<leader>ld",
	-- 			"<Cmd>FormatDisable<CR>",
	-- 			desc = "Disable format",
	-- 		},
	-- 		{
	-- 			"<leader>lD",
	-- 			"<Cmd>FormatDisable!<CR>",
	-- 			desc = "Disable current buffer format",
	-- 		},
	-- 	},
	-- },
}
