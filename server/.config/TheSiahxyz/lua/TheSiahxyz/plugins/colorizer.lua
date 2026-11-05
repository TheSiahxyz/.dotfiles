return {
	"brenoprata10/nvim-highlight-colors",
	event = "BufReadPre",
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n" },
			{ "<leader>zh", group = "Colorizer" },
		})
	end,
	config = function()
		require("nvim-highlight-colors").setup({
			render = "background", -- "background" | "foreground" | "virtual"
			enable_hex = true,
			enable_short_hex = true,
			enable_rgb = true,
			enable_hsl = false,
			enable_var_usage = true,
			enable_named_colors = false,
			enable_tailwind = true,
			virtual_symbol = "■",
			virtual_symbol_position = "eol", -- "eol" | "before" | "after"
		})
	end,
	keys = {
		{ "<leader>zht", "<Cmd>HighlightColorsToggle<CR>", desc = "Toggle colorizer" },
		{ "<leader>zha", "<Cmd>HighlightColorsOn<CR>", desc = "Enable colorizer" },
		{ "<leader>zhd", "<Cmd>HighlightColorsOff<CR>", desc = "Disable colorizer" },
	},
}
