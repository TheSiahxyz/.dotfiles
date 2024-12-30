return {
	"axieax/urlview.nvim",
	dependencies = "nvim-telescope/telescope.nvim",
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n", "v" },
			{ "<leader>u", group = "URLs" },
		})
	end,
	config = function()
		require("urlview").setup({})

		vim.keymap.set("n", "<leader>ur", "<Cmd>UrlView<CR>", { desc = "View buffer URLs" })
		vim.keymap.set("n", "<leader>ul", "<Cmd>UrlView lazy<CR>", { desc = "View plugin URLs" })
	end,
}
