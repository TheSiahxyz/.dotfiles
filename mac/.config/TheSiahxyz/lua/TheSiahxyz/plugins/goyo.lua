return {
	"junegunn/goyo.vim",
	dependencies = "junegunn/seoul256.vim",
	config = function()
		-- Enable Goyo by default for mutt writing
		vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
			group = vim.api.nvim_create_augroup("TheSiahxyz_goyo_config", { clear = true }),
			pattern = "/tmp/neomutt*",
			callback = function()
				vim.g.goyo_width = 80
				vim.g.seoul256_background = 235
				vim.cmd([[
          Goyo
          set bg=light
          set linebreak
          set wrap
          set textwidth=0
          set wrapmargin=0
          set background=dark
          colorscheme seoul256
        ]])
				vim.api.nvim_buf_set_keymap(
					0,
					"n",
					"<leader>gd",
					":Goyo|x!<CR>",
					{ noremap = true, silent = true, desc = "Goyo quit" }
				)
				vim.api.nvim_buf_set_keymap(
					0,
					"n",
					"<leader>gq",
					":Goyo|q!<CR>",
					{ noremap = true, silent = true, desc = "Goyo abort" }
				)
			end,
		})
	end,
}
