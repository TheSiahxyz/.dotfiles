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
	keys = function()
		local keys = {
			{
				"<C-a>",
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
				desc = "Go to previous harpoon list",
			},
			{
				"<C-n>",
				function()
					require("harpoon"):list():next()
				end,
				desc = "Go to next harpoon list",
			},
		}

		for i = 1, 5 do
			table.insert(keys, {
				"<M-" .. i .. ">",
				function()
					require("harpoon"):list():select(i)
				end,
				desc = "Go to harpoon list " .. i,
			})

			table.insert(keys, {
				"<M-x>" .. i,
				function()
					require("harpoon"):list():replace_at(i)
				end,
				desc = "Replace buffer at harpoon slot " .. i,
			})
		end

		return keys
	end,
}
