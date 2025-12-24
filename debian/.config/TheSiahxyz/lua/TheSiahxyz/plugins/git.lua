return {
	{
		"moyiz/git-dev.nvim",
		event = "VeryLazy",
		opts = {},
		config = function()
			require("git-dev").setup()

			local function copy_git_repo_url()
				-- Get the Git repository root
				local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
				if git_root == "" then
					vim.notify("Not inside a Git repository", vim.log.levels.WARN)
					return nil
				end

				-- Get the remote URL
				local remote_url = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")
				if remote_url == "" then
					vim.notify("No remote URL found", vim.log.levels.WARN)
					return nil
				end

				-- Convert SSH URL to HTTPS if needed
				if remote_url:match("^git@") then
					remote_url = remote_url:gsub("git@", "https://"):gsub(":", "/")
				end

				-- Remove `.git` from the remote URL
				remote_url = remote_url:gsub("%.git$", "")

				-- Get the relative path of the current file
				local file_path = vim.fn.expand("%:~:.")
				if file_path == "" then
					vim.notify("No file currently open", vim.log.levels.WARN)
					return nil
				end

				-- Get the relative path to the repository root
				local relative_path =
					vim.fn.system("git ls-files --full-name " .. vim.fn.shellescape(file_path)):gsub("\n", "")

				-- Combine the remote URL with the relative file path
				local full_url = remote_url .. "/" .. relative_path

				-- Copy to clipboard
				vim.fn.setreg("+", full_url)
				vim.notify("Copied to clipboard: " .. full_url, vim.log.levels.INFO)

				return full_url
			end

			-- Keybinding to copy the Git repository URL
			vim.keymap.set("n", "<leader>cg", function()
				copy_git_repo_url()
			end, { desc = "Copy git repository URL to clipboard" })

			-- Function to open a repository from the clipboard
			vim.keymap.set("n", "<leader>eg", function()
				local url = vim.fn.getreg("+") -- Get URL from clipboard
				if not url or url == "" then
					vim.notify("Clipboard is empty. Copy a valid URL first.", vim.log.levels.WARN)
					return
				end
				if url:match("^https://") then
					require("git-dev").open(url)
				else
					vim.notify("Not a valid URL: " .. url, vim.log.levels.ERROR)
				end
			end, { desc = "Open Git repository from clipboard" })
		end,
	},
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
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v')}) end, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v')}) end, "Reset hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gpv", gs.preview_hunk_inline, "Preview hunk inline")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gB", function() gs.blame() end, "Blame buffer")
        map("n", "<leader>gd", gs.diffthis, "Diff this")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff this ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>gtd", gs.toggle_deleted, "Toggle delete")
			end,
		},
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v", "x" },
				{ "<leader>g", group = "Git" },
				{ "<leader>gt", group = "Toggle" },
			})
		end,
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
			{ "<leader>gg", "<Cmd>LazyGit<cr>", desc = "Lazygit" },
		},
	},
	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>gu", vim.cmd.UndotreeToggle, { desc = "Undo tree" })
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
					vim.keymap.set("n", "<leader>P", function()
						vim.cmd.Git("push")
					end, { buffer = bufnr, remap = false, desc = "Git push" })
					vim.keymap.set("n", "<leader>p", function()
						vim.cmd.Git({ "pull", "--rebase" })
					end, { buffer = bufnr, remap = false, desc = "Git pull" })
					vim.keymap.set(
						"n",
						"<leader>o",
						":Git push -u origin ",
						{ buffer = bufnr, remap = false, desc = "Git push origin" }
					)
					vim.keymap.set(
						"n",
						"<leader>h",
						":Git push home ",
						{ buffer = bufnr, remap = false, desc = "Git push home" }
					)
				end,
			})
			autocmd("FileType", {
				group = TheSiahxyz_Fugitive,
				pattern = "fugitive",
				callback = function(event)
					vim.bo[event.buf].buflisted = false
					vim.keymap.set("n", "q", "<Cmd>close<cr>", { buffer = event.buf, silent = true })
				end,
			})
		end,
		keys = {
			{ mode = "n", "<leader>g<leader>", ":Git ", desc = "Git" },
			{ mode = "n", "<leader>gf", vim.cmd.Git, desc = "Git fugitive" },
			{ mode = "n", "gm", "<Cmd>diffget //2<cr>", desc = "Git diff on my side" },
			{ mode = "n", "go", "<Cmd>diffget //3<cr>", desc = "Git diff on their side" },
		},
	},
	{
		"pwntester/octo.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			-- OR 'ibhagwan/fzf-lua',
			-- OR 'folke/snacks.nvim',
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("octo").setup()
		end,
	},
}
