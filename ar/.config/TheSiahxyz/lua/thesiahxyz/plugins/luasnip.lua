return {
	{
		"L3MON4D3/LuaSnip",
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

			vim.cmd.runtime({ args = { "lua/thesiahxyz/snippets/*.lua" }, bang = true }) -- load custom snippets

			vim.keymap.set({ "i", "x" }, "<A-L>", function()
				if ls.expand_or_jumpable() then
					ls.expand_or_jump()
				end
			end, { silent = true, desc = "Expand Snippet or Jump to the Next Snippet Node" })

			vim.keymap.set({ "i", "x" }, "<A-H>", function()
				if ls.jumpable(-1) then
					ls.jump(-1)
				end
			end, { silent = true, desc = "Previous Spot in the Snippet" })

			vim.keymap.set({ "i", "x" }, "<A-l>", function()
				if ls.choice_active() then
					ls.change_choice(1)
				end
			end, { silent = true, desc = "Next Snippet Choice" })

			vim.keymap.set({ "i", "x" }, "<A-h>", function()
				if ls.choice_active() then
					ls.change_choice(-1)
				end
			end, { silent = true, desc = "Previous Snippet Choice" })
		end,
	},
}
