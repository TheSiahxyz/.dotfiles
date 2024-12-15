return {
	"folke/zen-mode.nvim",
	opts = {},
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n" },
			{ "<leader>z", group = "Zenmode (default)" },
			{ "<leader>Z", group = "Zenmode (custom)" },
		})
	end,
	config = function()
		vim.keymap.set("n", "<leader>zz", function()
			require("zen-mode").toggle({
				-- callback where you can add custom code when the Zen window opens
				on_open = function(win)
					vim.wo.wrap = true
					vim.wo.number = true
					vim.wo.rnu = true
				end,
				-- callback where you can add custom code when the Zen window closes
				on_close = function()
					vim.wo.wrap = false
					vim.wo.number = true
					vim.wo.rnu = true
					ColorMyPencils()
				end,
			})
		end, { desc = "Zenmode with default" })

		vim.keymap.set("n", "<leader>ZZ", function()
			require("zen-mode").toggle({
				window = {
					width = 90,
				},
				-- callback where you can add custom code when the Zen window opens
				on_open = function(win)
					vim.wo.wrap = true
					vim.wo.number = false
					vim.wo.rnu = false
					vim.opt.colorcolumn = "0"
					ColorMyPencils("seoul256")
				end,
				-- callback where you can add custom code when the Zen window closes
				on_close = function()
					vim.wo.wrap = false
					vim.wo.number = true
					vim.wo.rnu = true
					ColorMyPencils()
				end,
			})
		end, { desc = "Zenmode with custom" })
	end,
}
