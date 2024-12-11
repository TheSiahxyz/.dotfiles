return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
			on_attach = function(buffer)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

            -- stylua: ignore start
            map("n", "]h", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "]c", bang = true })
                else
                    gs.nav_hunk("next")
                end
            end, "Next hunk")
            map("n", "[h", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "[c", bang = true })
                else
                    gs.nav_hunk("prev")
                end
            end, "Previous hunk")
            map("n", "]H", function() gs.nav_hunk("last") end, "Last hunk")
            map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")
            map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
            map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
            map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
            map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
            map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
            map("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk inline")
            map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
            map("n", "<leader>gB", function() gs.blame() end, "Blame buffer")
            map("n", "<leader>gd", gs.diffthis, "Diff this")
            map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff this ~")
            -- map("n", "<leader>gD", function() gs.diffthis("@") end, "Diff this @")
            map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns select hunk")
            map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
            map("n", "<leader>tD", gs.toggle_deleted, "Toggle delete")
			end,
		},
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v", "x" },
				{ "<leader>g", group = "Git" },
			})
		end,
	},
	{
		"tpope/vim-fugitive",
		config = function()
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
			{ mode = "n", "<leader>gf", ":Git ", desc = "Git" },
			{ mode = "n", "<leader>gF", vim.cmd.Git, desc = "Git fugitive" },
			{ mode = "n", "gm", "<cmd>diffget //2<cr>", desc = "Git diff on my side" },
			{ mode = "n", "go", "<cmd>diffget //3<cr>", desc = "Git diff on their side" },
		},
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazygit" },
		},
	},
}
