return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	opts = {
		menu = {
			width = vim.api.nvim_win_get_width(0) - 4,
		},
		settings = {
			save_on_toggle = true,
			sync_on_ui_close = false, -- save over session
			key = function() -- define how to identify list
				return vim.loop.cwd()
			end,
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
		local extensions = require("harpoon.extensions")

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

		-- Highlight current file
		harpoon:extend(extensions.builtins.highlight_current_file())
		harpoon:extend(extensions.builtins.navigate_with_number())
	end,
	keys = function()
		local keys = {
			{
				"<leader>ha",
				function()
					require("harpoon"):list():add()
				end,
				mode = { "n", "i", "v", "x" },
				desc = "Add buffer to harpoon list",
			},
			{
				"<leader>ht",
				function()
					require("harpoon"):list():prepend()
				end,
				mode = { "n", "i", "v", "x" },
				desc = "Prepend buffer to harpoon list",
			},
			{
				"<C-g>",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				mode = { "n", "i" },
				desc = "Open harpoon list menu",
			},
			{
				"<C-p>",
				function()
					require("harpoon"):list():prev({ ui_nav_wrap = false })
				end,
				mode = { "n", "i", "v", "x" },
				desc = "Previous harpoon list",
			},
			{
				"<C-n>",
				function()
					require("harpoon"):list():next({ ui_nav_wrap = false })
				end,
				mode = { "n", "i", "v", "x" },
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
