return {
	"arnamak/stay-centered.nvim",
	lazy = false,
	ft = { "markdown", "ipynb" },
	config = function()
		require("stay-centered").setup({
			-- The filetype is determined by the vim filetype, not the file extension. In order to get the filetype, open a file and run the command:
			-- :lua print(vim.bo.filetype)
			skip_filetypes = {},
			-- Set to false to disable by default
			enabled = true,
			-- allows scrolling to move the cursor without centering, default recommended
			allow_scroll_move = true,
			-- temporarily disables plugin on left-mouse down, allows natural mouse selection
			-- try disabling if plugin causes lag, function uses vim.on_key
			disable_on_mouse = false,
		})
	end,
	keys = {
		{
			"<leader>zs",
			function()
				require("stay-centered").toggle()
			end,
			mode = { "n", "v" },
			desc = "Toggle stay center",
		},
	},
}
