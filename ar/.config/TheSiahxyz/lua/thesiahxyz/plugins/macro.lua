return {
	"ecthelionvi/NeoComposer.nvim",
	dependencies = { "kkharji/sqlite.lua" },
	opts = {},
	config = function()
		require("NeoComposer").setup({
			notify = true,
			delay_timer = 150,
			queue_most_recent = false,
			window = {
				width = 80,
				height = 10,
				border = "rounded",
				winhl = {
					Normal = "ComposerNormal",
				},
			},
			colors = {
				bg = "NONE",
				fg = "#ff9e64",
				red = "#ec5f67",
				blue = "#5fb3b3",
				green = "#99c794",
			},
			keymaps = {
				play_macro = "Q",
				yank_macro = "yq",
				stop_macro = "cq",
				toggle_record = "q",
				cycle_next = "<m-n>",
				cycle_prev = "<m-p>",
				toggle_macro_menu = "<m-q>",
			},
		})

		require("telescope").load_extension("macros")

		vim.keymap.set("n", "<leader>fQ", ":Telescope macros<CR>", { desc = "Search macros" })
		vim.keymap.set("n", "<leader>eQ", ":EditMacros<CR>", { desc = "Edit macros" })
		vim.keymap.set("n", "<leader>xQ", ":ClearNeoComposer<CR>", { desc = "Clear macros" })
	end,
}
