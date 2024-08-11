return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, { desc = "Previous hunk" })

				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end, { desc = "Next hunk" })
				map("n", "]H", function()
					gitsigns.nav_hunk("last")
				end, "Last Hunk")
				map("n", "[H", function()
					gitsigns.nav_hunk("first")
				end, "First Hunk")
				map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
				map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
				map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Stage buffer" })
				map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
				map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Reset buffer" })
				map("n", "<leader>gp", gitsigns.preview_hunk_inline, { desc = "Preview Hunk Inline" })
				map("n", "<leader>gb", function()
					gitsigns.blame_line({ full = true })
				end, { desc = "Blame Line" })
				map("n", "<leader>gB", function()
					gitsigns.blame()
				end, { desc = "Blame Buffer" })
				map("n", "<leader>gd", gitsigns.diffthis, { desc = "Diff this" })
				map("n", "<leader>gD", function()
					gitsigns.diffthis("@")
				end, { desc = "Diff this @" })
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "GitSigns Select Hunk" })
				map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle line blame" })
				map("n", "<leader>tx", gitsigns.toggle_deleted, { desc = "Toggle delete" })
			end,
		},
	},
}
