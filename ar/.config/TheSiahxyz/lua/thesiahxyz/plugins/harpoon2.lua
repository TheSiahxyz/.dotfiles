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
				mode = "n",
				"<leader>a",
				function()
					require("harpoon"):list():add()
				end,
				{ desc = "Add Buffer to Harpoon List" },
			},
			{
				mode = "n",
				"<C-w>",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				{ desc = "Open Harpoon List Menu" },
			},
			{
				mode = "n",
				"<C-p>",
				function()
					require("harpoon"):list():prev()
				end,
			},
			{
				mode = "n",
				"<C-n>",
				function()
					require("harpoon"):list():next()
				end,
			},
		}

		for i = 1, 5 do
			table.insert(keys, {
				mode = "n",
				"<leader>" .. i,
				function()
					require("harpoon"):list():select(i)
				end,
				{ desc = "Go to Harpoon List " .. i },
			})

			table.insert(keys, {
				mode = "n",
				"<leader>x" .. i,
				function()
					require("harpoon"):list():replace_at(i)
				end,
				{ desc = "Replace Buffer at Harpoon Slot " .. i },
			})
		end
		return keys
	end,
}
