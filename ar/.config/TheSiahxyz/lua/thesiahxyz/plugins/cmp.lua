local trigger_text = ";"

return {
	"saghen/blink.cmp",
	version = "*",
	-- build = "cargo build --release",
	opts_extend = {
		"sources.completion.enabled_providers",
		"sources.compat",
		"sources.default",
	},
	enabled = true,
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
		},
		"rafamadriz/friendly-snippets",
		{
			"saghen/blink.compat",
			optional = true, -- make optional so it's only enabled if any extras need it
			opts = {},
			version = "*",
		},
		"kristjanhusak/vim-dadbod-completion",
		"giuxtaposition/blink-cmp-copilot",
	},
	event = "InsertEnter",
	opts = function(_, opts)
		opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
			default = { "lsp", "path", "snippets", "buffer", "copilot", "luasnip", "dadbod" },
			providers = {
				lsp = {
					name = "lsp",
					enabled = true,
					module = "blink.cmp.sources.lsp",
					fallbacks = { "snippets", "luasnip", "buffer" },
					score_offset = 90, -- the higher the number, the higher the priority
				},
				luasnip = {
					name = "luasnip",
					enabled = true,
					module = "blink.cmp.sources.luasnip",
					min_keyword_length = 2,
					fallbacks = { "snippets" },
					score_offset = 85,
					max_items = 8,
				},
				path = {
					name = "Path",
					module = "blink.cmp.sources.path",
					score_offset = 3,
					-- When typing a path, I would get snippets and text in the
					-- suggestions, I want those to show only if there are no path
					-- suggestions
					fallbacks = { "snippets", "luasnip", "buffer" },
					opts = {
						trailing_slash = false,
						label_trailing_slash = true,
						get_cwd = function(context)
							return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
						end,
						show_hidden_files_by_default = true,
					},
				},
				buffer = {
					name = "Buffer",
					enabled = true,
					max_items = 3,
					module = "blink.cmp.sources.buffer",
					min_keyword_length = 4,
				},
				snippets = {
					name = "Snippets",
					enabled = true,
					max_items = 3,
					module = "blink.cmp.sources.snippets",
					min_keyword_length = 4,
					score_offset = 80, -- the higher the number, the higher the priority
				},
				-- Example on how to configure dadbod found in the main repo
				-- https://github.com/kristijanhusak/vim-dadbod-completion
				dadbod = {
					name = "Dadbod",
					module = "vim_dadbod_completion.blink",
					score_offset = 85, -- the higher the number, the higher the priority
				},
				-- Third class citizen mf always talking shit
				copilot = {
					name = "Copilot",
					enabled = true,
					module = "blink-cmp-copilot",
					min_keyword_length = 6,
					score_offset = -100, -- the higher the number, the higher the priority
					async = true,
				},
			},
			-- command line completion, thanks to dpetka2001 in reddit
			-- https://www.reddit.com/r/neovim/comments/1hjjf21/comment/m37fe4d/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
			cmdline = function()
				local type = vim.fn.getcmdtype()
				if type == "/" or type == "?" then
					return { "buffer" }
				end
				if type == ":" then
					return { "cmdline" }
				end
				return {}
			end,
		})

		-- This comes from the luasnip extra, if you don't add it, won't be able to
		-- jump forward or backward in luasnip snippets
		opts.snippets = {
			expand = function(snippet)
				require("luasnip").lsp_expand(snippet)
			end,
			active = function(filter)
				if filter and filter.direction then
					return require("luasnip").jumpable(filter.direction)
				end
				return require("luasnip").in_snippet()
			end,
			jump = function(direction)
				require("luasnip").jump(direction)
			end,
		}

		opts.appearance = {
			-- sets the fallback highlight groups to nvim-cmp's highlight groups
			-- useful for when your theme doesn't support blink.cmp
			-- will be removed in a future release, assuming themes add support
			use_nvim_cmp_as_default = false,
			-- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		}

		opts.completion = {
			accept = {
				-- experimental auto-brackets support
				auto_brackets = {
					enabled = true,
				},
			},
			menu = {
				draw = {
					treesitter = { "lsp" },
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
			},
			ghost_text = { enabled = true },
		}

		opts.keymap = {
			preset = "super-tab",
		}

		return opts
	end,
}
