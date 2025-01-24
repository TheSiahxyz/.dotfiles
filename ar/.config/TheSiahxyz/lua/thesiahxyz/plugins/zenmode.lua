return {
	"folke/zen-mode.nvim",
	opts = {},
	config = function()
		vim.keymap.set("n", "<leader>zz", function()
			require("zen-mode").toggle({
				-- callback where you can add custom code when the Zen window opens
				on_open = function()
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
		end, { desc = "Toggle zenmode" })

		vim.keymap.set("n", "<leader>zZ", function()
			require("zen-mode").toggle({
				window = {
					width = 90,
				},
				-- callback where you can add custom code when the Zen window opens
				on_open = function()
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
		end, { desc = "Toggle zenmode (custom)" })
	end,
}
