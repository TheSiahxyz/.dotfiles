return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

		local TheSiahxyz_Fugitive = vim.api.nvim_create_augroup("TheSiahxyz_Fugitive", {})

		local autocmd = vim.api.nvim_create_autocmd
		autocmd("BufWinEnter", {
			group = TheSiahxyz_Fugitive,
			pattern = "*",
			callback = function()
				if vim.bo.ft ~= "fugitive" then
					return
				end

				local bufnr = vim.api.nvim_get_current_buf()
				vim.keymap.set("n", "<leader>p", function()
					vim.cmd.Git("push")
				end, { buffer = bufnr, remap = false, desc = "Git push" })

				vim.keymap.set("n", "<leader>P", function()
					vim.cmd.Git({ "pull", "--rebase" })
				end, { buffer = bufnr, remap = false, desc = "Git pull" })

				vim.keymap.set(
					"n",
					"<leader>t",
					":Git push -u origin ",
					{ buffer = bufnr, remap = false, desc = "Git push origin" }
				)
			end,
		})
	end,
	keys = {
		{ mode = "n", "gu", "<cmd>diffget //2<cr>", desc = "Git diff on my side" },
		{ mode = "n", "gh", "<cmd>diffget //3<cr>", desc = "Git diff on their side" },
	},
}
