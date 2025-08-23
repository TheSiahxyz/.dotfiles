return {
	"hedyhli/outline.nvim",
	lazy = true,
	cmd = { "Outline", "OutlineOpen" },
	keys = { -- Example mapping to toggle outline
		{ "<leader>zo", "<Cmd>Outline<cr>", desc = "Toggle outline" },
	},
	opts = {
		-- Your setup opts here
	},
}
