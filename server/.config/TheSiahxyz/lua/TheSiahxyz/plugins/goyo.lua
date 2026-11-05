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
				-- Goyo creates multiple padding windows.
				-- Use a global (non-buffer-local) QuitPre so it fires regardless of which window is active.
				local mutt_quit_group = vim.api.nvim_create_augroup("TheSiahxyz_mutt_quit", { clear = true })
				vim.api.nvim_create_autocmd("QuitPre", {
					group = mutt_quit_group,
					once = true,
					callback = function()
						vim.cmd("qa!")
					end,
				})
				-- Clean up the global QuitPre if the buffer is deleted without quitting
				vim.api.nvim_create_autocmd("BufDelete", {
					buffer = 0,
					once = true,
					callback = function()
						pcall(vim.api.nvim_del_augroup_by_id, mutt_quit_group)
					end,
				})
			end,
		})
	end,
}
