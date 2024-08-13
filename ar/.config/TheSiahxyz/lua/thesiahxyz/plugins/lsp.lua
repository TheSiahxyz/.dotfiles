return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"mfussenegger/nvim-lint",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
		{ "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
		{ "folke/neodev.nvim", opts = {} },
		"stevearc/conform.nvim",
	},
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
		require("fidget").setup()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"jdtls",
				"lua_ls",
				"pyright",
			},
			handlers = {
				function(server_name) -- default handler (optional)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
					})
				end,
				["lua_ls"] = function()
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								runtime = { version = "Lua 5.4" },
								diagnostics = {
									globals = { "vim", "it", "describe", "before_each", "after_each" },
								},
							},
						},
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
			},
		})

		local lint = require("lint")
		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
			lua = { "luacheck" },
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
				"isort", -- python formatter
				"prettier", -- prettier formatter
				"pylint", -- python linter
				"shfmt", -- sh formatter
				"stylua", -- lua formatter
				"luacheck", -- lua lint
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
			-- update_in_insert = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
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
				python = { "isort", "black" },
				sh = { "shfmt" },
				svelte = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				yaml = { "prettier" },
				zsh = { "beautysh" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 500,
			},
		})
	end,
	keys = {
		{
			mode = { "n", "v" },
			"<leader>cf",
			function()
				require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 500 })
			end,
			desc = "Format buffer by lsp",
		},
		{
			"<leader>ci",
			"<cmd>PyrightOrganizeImports<cr>",
			desc = "Organize imports",
		},
		{
			"<leader>ll",
			function()
				require("lint").try_lint()
			end,
			desc = "Lint buffer",
		},
	},
}
