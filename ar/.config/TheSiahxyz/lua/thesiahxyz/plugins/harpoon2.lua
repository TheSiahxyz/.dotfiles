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
				"<C-p>",
				function()
					require("harpoon"):list():prev()
				end,
				desc = "Previous harpoon list",
			},
			{
				"<C-n>",
				function()
					require("harpoon"):list():next()
				end,
				desc = "Next harpoon list",
			},
		}

		for i = 1, 5 do
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
