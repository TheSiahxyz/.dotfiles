return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = {
			"rafamadriz/friendly-snippets",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
		config = function()
			local ls = require("luasnip")
			ls.setup({
				link_children = true,
				link_roots = false,
				keep_roots = false,
				update_events = { "TextChanged", "TextChangedI" },
			})
			local c = ls.choice_node
			ls.choice_node = function(pos, choices, opts)
				if opts then
					opts.restore_cursor = true
				else
					opts = { restore_cursor = true }
				end
				return c(pos, choices, opts)
			end

			require("luasnip.loaders.from_vscode").lazy_load({
				paths = { '"' .. vim.fn.stdpath("config") .. '/lua/TheSiahxyz/snippets"' },
			})

			vim.cmd.runtime({ args = { "lua/TheSiahxyz/snippets/*.lua" }, bang = true }) -- load custom snippets

			vim.keymap.set({ "i", "x" }, "<C-L>", function()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				end
			end, { silent = true, desc = "Expand snippet or jump to the next snippet node" })

			vim.keymap.set({ "i", "x" }, "<C-H>", function()
				if ls.jumpable(-1) then
					ls.jump(-1)
				end
			end, { silent = true, desc = "Previous spot in the snippet" })

			vim.keymap.set({ "i", "s" }, "<C-j>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				end
			end, { silent = true, desc = "Next snippet choice" })

			vim.keymap.set({ "i", "s" }, "<C-k>", function()
				if ls.choice_active() then
					ls.change_choice(-1)
				end
			end, { silent = true, desc = "Previous snippet choice" })
		end,
		keys = {
			vim.keymap.set("i", "<tab>", function()
				return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
			end, { expr = true, silent = true, desc = "Jump to next snippet" }),
			vim.keymap.set("s", "<tab>", function()
				require("luasnip").jump(1)
			end, { desc = "Jump to next snippet" }),
			vim.keymap.set({ "i", "s" }, "<s-tab>", function()
				require("luasnip").jump(-1)
			end, { desc = "Jump to Previous Snippet" }),
		},
	},
}
