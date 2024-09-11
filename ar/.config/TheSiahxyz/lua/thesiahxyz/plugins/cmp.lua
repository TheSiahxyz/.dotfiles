return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer", -- source for text in buffer
			"hrsh7th/cmp-path", -- source for file system paths
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
				build = "make install_jsregexp",
			},
			"saadparwaiz1/cmp_luasnip", -- for autocompletion
			"rafamadriz/friendly-snippets", -- useful snippets
			"onsails/lspkind.nvim", -- vs-code like pictograms
		},
		config = function()
			local cmp = require("cmp")

			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				snippet = { -- configure how nvim-cmp interacts with snippet engine
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(), -- previous suggestion
					["<C-n>"] = cmp.mapping.select_next_item(), -- next suggestion
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-u>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
					["<C-x>"] = cmp.mapping.abort(), -- close completion window
					["<C-c>"] = cmp.mapping.close(),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
				}),
				-- sources for autocompletion
				sources = cmp.config.sources({
					{ name = "buffer" }, -- text within current buffer
					{ name = "crates" },
					{ name = "emoji" },
					{ name = "luasnip" }, -- snippets
					{ name = "nvim_lsp" },
					{ name = "nvim_lua", priority = 100 },
					{ name = "path" }, -- file system paths
					{ name = "projects", priority = 100 },
					{ name = "snippets" },
					{ name = "vim-dadbod-completion" }, -- Enable dadbod completion source
					{ name = "vsnip" },
				}),

				-- configure lspkind for vs-code like pictograms in completion menu
				formatting = {
					expandable_indicator = true,
					fields = {
						"abbr",
						"kind",
						"menu",
					},
					format = require("lspkind").cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
						menu = {
							buffer = "[Buffer]",
							nvim_lsp = "[LSP]",
							nvim_lua = "[Lua]",
							projects = "[Projects]",
							emoji = "[Emoji]",
							vsnip = "[Snippet]",
						},
					}),
				},
			})

			-- Use buffer source for `/`
			cmp.setup.cmdline("/", {
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':'
			cmp.setup.cmdline(":", {
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})

			-- sql
			cmp.setup.filetype({ "sql" }, {
				sources = {
					{ name = "vim-dadbod-completion" },
					{ name = "buffer" },
				},
			})
		end,
	},
}
