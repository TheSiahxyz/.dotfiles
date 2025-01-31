return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	opts = {
		menu = {
			width = vim.api.nvim_win_get_width(0) - 4,
		},
		settings = {
			save_on_toggle = true,
		},
	},
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n" },
			{ "<leader>h", group = "Harpoon" },
			{ "<leader>hr", group = "Replace harpoon slot" },
			{ "<M-x>", group = "Harpoon list delete" },
		})
	end,
	config = function(_, opts)
		local harpoon = require("harpoon")

		-- Apply the base configuration
		harpoon.setup(opts)

		-- Extend functionality
		harpoon:extend({
			UI_CREATE = function(cx)
				vim.keymap.set("n", "<C-v>", function()
					harpoon.ui:select_menu_item({ vsplit = true })
				end, { buffer = cx.bufnr })

				vim.keymap.set("n", "<C-s>", function()
					harpoon.ui:select_menu_item({ split = true })
				end, { buffer = cx.bufnr })

				vim.keymap.set("n", "<C-t>", function()
					harpoon.ui:select_menu_item({ tabedit = true })
				end, { buffer = cx.bufnr })
			end,
		})
	end,
	keys = function()
		local keys = {
			{
				"<leader>ha",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Add buffer to harpoon list",
			},
			{
				"<C-q>",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Open harpoon list menu",
			},
			{
				"<C-S-P>",
				function()
					require("harpoon"):list():prev({ ui_nav_wrap = false })
				end,
				desc = "Previous harpoon list",
			},
			{
				"<C-S-N>",
				function()
					require("harpoon"):list():next({ ui_nav_wrap = false })
				end,
				desc = "Next harpoon list",
			},
		}

		for i = 0, 9 do
			table.insert(keys, {
				"<M-" .. i .. ">",
				function()
					require("harpoon"):list():select(i)
				end,
				desc = "Harpoon list " .. i,
			})
			table.insert(keys, {
				"<leader>h" .. i,
				function()
					require("harpoon"):list():select(i)
				end,
				desc = "Harpoon list " .. i,
			})
			table.insert(keys, {
				"<leader>hr" .. i,
				function()
					require("harpoon"):list():replace_at(i)
				end,
				desc = "Replace buffer at harpoon slot " .. i,
			})
		end

		return keys
	end,
}
