local trigger_text = ";"

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
			"uga-rosa/cmp-dictionary", -- dictionary & spell
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

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
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
						-- this way you will only jump inside the snippet region
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
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
				-- sources for autocompletion
				sources = cmp.config.sources({
					{ name = "buffer" }, -- text within current buffer
					{ name = "crates" },
					{ name = "copilot" },
					{ name = "dictionary", keyword_length = 2 },
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
							luasnip = "[LuaSnip]",
							nvim_lsp = "[LSP]",
							nvim_lua = "[Lua]",
							projects = "[Projects]",
							emoji = "[Emoji]",
							vsnip = "[Snippet]",
						},
					}),
				},
			})

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				matching = { disallow_symbol_nonprefix_matching = false },
			})

			-- sql
			cmp.setup.filetype({ "sql" }, {
				sources = {
					{ name = "vim-dadbod-completion" },
					{ name = "buffer" },
				},
			})

			local lspkind = require("lspkind")
			lspkind.init({
				symbol_map = {
					Copilot = "",
				},
			})

			vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

			require("cmp_dictionary").setup({
				paths = {
					"/usr/share/dict/words",
					vim.fn.expand(vim.fn.stdpath("config") .. "/lua/thesiahxyz/spells/en.utf-8.add"),
				},
				exact_length = 2,
			})
		end,
	},
	-- {
	-- 	"saghen/blink.cmp",
	-- 	version = "*",
	-- 	-- build = "cargo build --release",
	-- 	opts_extend = {
	-- 		"sources.completion.enabled_providers",
	-- 		"sources.compat",
	-- 		"sources.default",
	-- 	},
	-- 	enabled = true,
	-- 	dependencies = {
	-- 		{
	-- 			"L3MON4D3/LuaSnip",
	-- 			version = "v2.*",
	-- 			build = "make install_jsregexp",
	-- 		},
	-- 		"rafamadriz/friendly-snippets",
	-- 		{
	-- 			"saghen/blink.compat",
	-- 			optional = true, -- make optional so it's only enabled if any extras need it
	-- 			opts = {},
	-- 			version = "*",
	-- 		},
	-- 		"kristjanhusak/vim-dadbod-completion",
	-- 		"giuxtaposition/blink-cmp-copilot",
	-- 	},
	-- 	event = "InsertEnter",
	-- 	opts = function(_, opts)
	-- 		opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
	-- 			default = { "lsp", "path", "snippets", "buffer", "copilot", "luasnip", "dadbod" },
	-- 			providers = {
	-- 				lsp = {
	-- 					name = "lsp",
	-- 					enabled = true,
	-- 					module = "blink.cmp.sources.lsp",
	-- 					fallbacks = { "snippets", "luasnip", "buffer" },
	-- 					score_offset = 90, -- the higher the number, the higher the priority
	-- 				},
	-- 				luasnip = {
	-- 					name = "luasnip",
	-- 					enabled = true,
	-- 					module = "blink.cmp.sources.luasnip",
	-- 					min_keyword_length = 2,
	-- 					fallbacks = { "snippets" },
	-- 					score_offset = 85,
	-- 					max_items = 8,
	-- 				},
	-- 				path = {
	-- 					name = "Path",
	-- 					module = "blink.cmp.sources.path",
	-- 					score_offset = 3,
	-- 					-- When typing a path, I would get snippets and text in the
	-- 					-- suggestions, I want those to show only if there are no path
	-- 					-- suggestions
	-- 					fallbacks = { "snippets", "luasnip", "buffer" },
	-- 					opts = {
	-- 						trailing_slash = false,
	-- 						label_trailing_slash = true,
	-- 						get_cwd = function(context)
	-- 							return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
	-- 						end,
	-- 						show_hidden_files_by_default = true,
	-- 					},
	-- 				},
	-- 				buffer = {
	-- 					name = "Buffer",
	-- 					enabled = true,
	-- 					max_items = 3,
	-- 					module = "blink.cmp.sources.buffer",
	-- 					min_keyword_length = 4,
	-- 				},
	-- 				snippets = {
	-- 					name = "Snippets",
	-- 					enabled = true,
	-- 					max_items = 3,
	-- 					module = "blink.cmp.sources.snippets",
	-- 					min_keyword_length = 4,
	-- 					score_offset = 80, -- the higher the number, the higher the priority
	-- 				},
	-- 				-- Example on how to configure dadbod found in the main repo
	-- 				-- https://github.com/kristijanhusak/vim-dadbod-completion
	-- 				dadbod = {
	-- 					name = "Dadbod",
	-- 					module = "vim_dadbod_completion.blink",
	-- 					score_offset = 85, -- the higher the number, the higher the priority
	-- 				},
	-- 				-- Third class citizen mf always talking shit
	-- 				copilot = {
	-- 					name = "Copilot",
	-- 					enabled = true,
	-- 					module = "blink-cmp-copilot",
	-- 					min_keyword_length = 6,
	-- 					score_offset = -100, -- the higher the number, the higher the priority
	-- 					async = true,
	-- 				},
	-- 			},
	-- 			-- command line completion, thanks to dpetka2001 in reddit
	-- 			-- https://www.reddit.com/r/neovim/comments/1hjjf21/comment/m37fe4d/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
	-- 			cmdline = function()
	-- 				local type = vim.fn.getcmdtype()
	-- 				if type == "/" or type == "?" then
	-- 					return { "buffer" }
	-- 				end
	-- 				if type == ":" then
	-- 					return { "cmdline" }
	-- 				end
	-- 				return {}
	-- 			end,
	-- 		})
	--
	-- 		-- This comes from the luasnip extra, if you don't add it, won't be able to
	-- 		-- jump forward or backward in luasnip snippets
	-- 		opts.snippets = {
	-- 			expand = function(snippet)
	-- 				require("luasnip").lsp_expand(snippet)
	-- 			end,
	-- 			active = function(filter)
	-- 				if filter and filter.direction then
	-- 					return require("luasnip").jumpable(filter.direction)
	-- 				end
	-- 				return require("luasnip").in_snippet()
	-- 			end,
	-- 			jump = function(direction)
	-- 				require("luasnip").jump(direction)
	-- 			end,
	-- 		}
	--
	-- 		opts.appearance = {
	-- 			-- sets the fallback highlight groups to nvim-cmp's highlight groups
	-- 			-- useful for when your theme doesn't support blink.cmp
	-- 			-- will be removed in a future release, assuming themes add support
	-- 			use_nvim_cmp_as_default = false,
	-- 			-- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
	-- 			-- adjusts spacing to ensure icons are aligned
	-- 			nerd_font_variant = "mono",
	-- 		}
	--
	-- 		opts.completion = {
	-- 			accept = {
	-- 				-- experimental auto-brackets support
	-- 				auto_brackets = {
	-- 					enabled = true,
	-- 				},
	-- 			},
	-- 			menu = {
	-- 				draw = {
	-- 					treesitter = { "lsp" },
	-- 				},
	-- 			},
	-- 			documentation = {
	-- 				auto_show = true,
	-- 				auto_show_delay_ms = 200,
	-- 			},
	-- 			ghost_text = { enabled = true },
	-- 		}
	--
	-- 		opts.keymap = {
	-- 			preset = "super-tab",
	-- 		}
	--
	-- 		return opts
	-- 	end,
	-- },
}
