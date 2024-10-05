local have_make = vim.fn.executable("make") == 1
local have_cmake = vim.fn.executable("cmake") == 1

function vim.live_grep_from_project_git_root()
	local function get_git_toplevel()
		local path = vim.fn.system("git rev-parse --show-toplevel")
		if vim.v.shell_error then
			return nil
		end
		return path
	end

	local opts = { cwd = get_git_toplevel() }

	require("telescope.builtin").live_grep(opts)
end

return {
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		-- init = function()
		-- 	vim.api.nvim_create_autocmd("VimEnter", {
		-- 		group = vim.api.nvim_create_augroup("TelescopeFileBrowserStartDirectory", { clear = true }),
		-- 		desc = "Start telescope-file-browser with directory",
		-- 		once = true,
		-- 		callback = function()
		-- 			if package.loaded["telescope-file-browser.nvim"] then
		-- 				return
		-- 			else
		-- 				local stats = vim.uv.fs_stat(vim.fn.argv(0))
		-- 				if stats and stats.type == "directory" then
		-- 					require("telescope").extensions.file_browser.file_browser()
		-- 				end
		-- 			end
		-- 		end,
		-- 	})
		-- end,
		config = function()
			local fb_actions = require("telescope._extensions.file_browser.actions")

			require("telescope").setup({
				extensions = {
					file_browser = {
						path = vim.uv.cwd(),
						cwd = vim.uv.cwd(),
						cwd_to_path = false,
						grouped = true,
						files = true,
						add_dirs = true,
						depth = 1,
						auto_depth = true,
						select_buffer = true,
						hidden = { file_browser = false, folder_browser = false },
						respect_gitignore = vim.fn.executable("fd") == 1,
						no_ignore = true,
						follow_symlinks = true,
						browse_files = require("telescope._extensions.file_browser.finders").browse_files,
						browse_folders = require("telescope._extensions.file_browser.finders").browse_folders,
						hide_parent_dir = false,
						collapse_dirs = true,
						prompt_path = true,
						quiet = true,
						dir_icon = "",
						dir_icon_hl = "Default",
						display_stat = { date = true, size = true, mode = true },
						hijack_netrw = true,
						use_fd = true,
						git_status = true,
						mappings = {
							["i"] = {
								["<C-a>"] = fb_actions.create,
								["<C-i>"] = fb_actions.create_from_prompt,
								["<C-r>"] = fb_actions.rename,
								["<C-d>"] = fb_actions.move,
								["<C-y>"] = fb_actions.copy,
								["<Del>"] = fb_actions.remove,
								["<C-o>"] = fb_actions.open,
								["<C-h>"] = fb_actions.goto_parent_dir,
								["<C-Space>"] = fb_actions.goto_home_dir,
								["<C-w>"] = fb_actions.goto_cwd,
								["<C-g>"] = fb_actions.change_cwd,
								["<C-f>"] = fb_actions.toggle_browser,
								["<C-_>"] = fb_actions.toggle_hidden,
								["<C-t>"] = fb_actions.toggle_all,
								["<bs>"] = fb_actions.backspace,
							},
							["n"] = {
								["a"] = fb_actions.create,
								["n"] = fb_actions.create_from_prompt,
								["r"] = fb_actions.rename,
								["d"] = fb_actions.move,
								["y"] = fb_actions.copy,
								["Del"] = fb_actions.remove,
								["o"] = fb_actions.open,
								["h"] = fb_actions.goto_parent_dir,
								["gh"] = fb_actions.goto_home_dir,
								["<C-w>"] = fb_actions.goto_cwd,
								["<C-g>"] = fb_actions.change_cwd,
								["f"] = fb_actions.toggle_browser,
								["/"] = fb_actions.toggle_hidden,
								["t"] = fb_actions.toggle_all,
							},
						},
						file_ignore_patterns = {
							"node_modules",
							"yarn.lock",
							".git",
							".sl",
							"_build",
							".next",
						},
						path_display = {
							"filename_first",
						},
						find_command = {
							"rg",
							"--files",
							"--follow",
							"--hidden",
							"--glob",
							"**/*",
							"--glob",
							"!**/.git/*",
							"--no-ignore",
							"--sortr=modified",
						},
						results_title = vim.fn.fnamemodify(vim.uv.cwd(), ":~"),
					},
				},
			})

			vim.keymap.set("n", "<leader>et", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")
			vim.keymap.set("n", "<leader>eT", ":Telescope file_browser<CR>")

			require("telescope").load_extension("file_browser")
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		version = false,
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = have_make and "make"
					or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
				enabled = have_make or have_cmake,
				config = function()
					require("telescope").load_extension("fzf")
				end,
			},
			{
				"xiyaowong/telescope-emoji.nvim",
				config = function()
					require("telescope").load_extension("emoji")
				end,
				keys = {
					{ "<leader>se", ":Telescope emoji<cr>", desc = "Search emoji" },
				},
			},
			{
				"ThePrimeagen/harpoon",
				branch = "harpoon2",
				dependencies = { "nvim-lua/plenary.nvim" },
			},
		},
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n" },
				{ "<leader>f", group = "Find" },
				{ "<leader>fp", group = "Private/Public" },
				{ "<leader>s", group = "Search" },
				{ "<leader>sb", group = "Buffer" },
			})
		end,
		config = function()
			local actions = require("telescope.actions")
			local actions_state = require("telescope.actions.state")

			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-e>"] = actions.complete_tag,
							["<C-g>"] = function(prompt_bufnr)
								local selection = actions_state.get_selected_entry()
								local dir = vim.fn.fnamemodify(selection.path, ":p:h")
								actions.close(prompt_bufnr)
								-- Depending on what you want put `cd`, `lcd`, `tcd`
								vim.cmd(string.format("silent lcd %s", dir))
							end,
							["<C-j>"] = actions.preview_scrolling_down,
							["<C-k>"] = actions.preview_scrolling_up,
							["<C-h>"] = actions.preview_scrolling_left,
							["<C-l>"] = actions.preview_scrolling_right,
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-s>"] = actions.select_horizontal,
							["<C-x>"] = actions.delete_buffer,
						},
						n = {
							["dd"] = actions.delete_buffer,
							["q"] = actions.close,
							["<C-c>"] = actions.close,
							["<C-e>"] = actions.complete_tag,
							["<C-f>"] = actions.nop,
							["<C-g>"] = function(prompt_bufnr)
								local selection = actions_state.get_selected_entry()
								local dir = vim.fn.fnamemodify(selection.path, ":p:h")
								actions.close(prompt_bufnr)
								-- Depending on what you want put `cd`, `lcd`, `tcd`
								vim.cmd(string.format("silent lcd %s", dir))
							end,
							["<C-j>"] = actions.preview_scrolling_down,
							["<C-k>"] = actions.preview_scrolling_up,
							["<C-h>"] = actions.preview_scrolling_left,
							["<C-l>"] = actions.preview_scrolling_right,
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-s>"] = actions.select_horizontal,
							["<C-x>"] = actions.delete_buffer,
						},
					},
					file_ignore_patterns = {
						"node_modules",
						"yarn.lock",
						".git",
						".sl",
						"_build",
						".next",
					},
					hidden = true,
					path_display = {
						"filename_first",
					},
					git_worktrees = {
						{
							toplevel = vim.env.HOME,
							private = vim.env.HOME .. "/Private/git",
							public = vim.env.HOME .. "/Public/git",
						},
					},
					results_title = vim.fn.fnamemodify(vim.uv.cwd(), ":~"),
				},
				pickers = {
					find_files = {
						-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
						find_command = {
							"rg",
							"--files",
							"--follow",
							"--hidden",
							"--glob",
							"**/*",
							"--glob",
							"!**/.git/*",
							"--no-ignore",
							"--sortr=modified",
						},
					},
				},
			})

			-- find
			vim.keymap.set("n", "<leader>fb", function()
				require("telescope.builtin").buffers({
					sort_mru = true,
					sort_lastused = true,
					initial_mode = "normal",
				})
			end, { desc = "Find buffer files" })
			vim.keymap.set("n", "<C-g>", function()
				require("telescope.builtin").buffers({
					sort_mru = true,
					sort_lastused = true,
					initial_mode = "normal",
				})
			end, { desc = "Find buffer files" })
			vim.keymap.set("n", "<leader>fc", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/.config") })
			end, { desc = "Find config files" })
			vim.keymap.set("n", "<leader>fd", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/.dotfiles") })
			end, { desc = "Find dotfiles files" })
			vim.keymap.set("n", "<leader>ff", function()
				require("telescope.builtin").find_files()
			end, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fF", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.expand("~"),
					find_command = {
						"rg",
						"--files",
						"--follow",
						"--hidden",
						"--glob",
						"!**/.git/*",
						"--glob",
						"!**/.cache/*/*/*",
						"--glob",
						"!**/.mozilla/*",
						"--glob",
						"!**/.local/bin/zsh/*",
						"--glob",
						"!**/.local/lib/*/*",
						"--glob",
						"!**/.local/share/*/*",
						"--glob",
						"!**/.local/state/*/*/*/*",
						"--sortr=modified",
					},
				})
			end, { desc = "Find root files" })
			vim.keymap.set("n", "<leader>fg", function()
				require("telescope.builtin").git_files()
			end, { desc = "Find git files" })
			vim.keymap.set("n", "<leader>fn", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "Find neovim config files" })
			vim.keymap.set("n", "<leader>fo", function()
				require("telescope.builtin").oldfiles({})
			end, { desc = "Find old files" })
			vim.keymap.set("n", "<leader>fpv", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/Private") })
			end, { desc = "Find private files" })
			vim.keymap.set("n", "<leader>fpb", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/Public") })
			end, { desc = "Find public files" })
			vim.keymap.set("n", "<leader>fr", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.expand("~/.local/bin"),
					find_command = {
						"rg",
						"--files",
						"--follow",
						"--glob",
						"!**/.git/*",
						"--glob",
						"!**/zsh/*",
						"--sortr=modified",
					},
				})
			end, { desc = "Find script files" })
			vim.keymap.set("n", "<leader>fs", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.expand("~/.local/src/suckless/"),
				})
			end, { desc = "Find suckless files" })
			vim.keymap.set("n", "<leader>fts", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.expand("~/Private/repos"),
					find_command = {
						"rg",
						"--files",
						"--follow",
						"--hidden",
						"--glob",
						"!**/.git/*",
						"--glob",
						"!**/public/*/*",
						"--sortr=modified",
					},
				})
			end, { desc = "Find suckless files" })
			-- git
			vim.keymap.set("n", "<leader>gc", function()
				require("telescope.builtin").git_commits()
			end, { desc = "Find git commits" })
			vim.keymap.set("n", "<leader>gs", function()
				require("telescope.builtin").git_status()
			end, { desc = "Find git status" })
			-- lsp
			vim.keymap.set("n", "gR", function()
				require("telescope.builtin").lsp_references({})
			end, { desc = "Find references" })
			vim.keymap.set("n", "gd", function()
				require("telescope.builtin").lsp_definitions({})
			end, { desc = "Find definitions" })
			-- search
			vim.keymap.set("n", "<leader>sa", function()
				require("telescope.builtin").autocommands({})
			end, { desc = "Search auto commands" })
			vim.keymap.set("n", "<leader>sbf", function()
				require("telescope.builtin").current_buffer_fuzzy_find({})
			end, { desc = "Search current buffers " })
			vim.keymap.set("n", "<leader>sbt", function()
				require("telescope.builtin").current_buffer_tags({})
			end, { desc = "Search current buffer tags" })
			vim.keymap.set("n", "<leader>sc", function()
				require("telescope.builtin").commands({})
			end, { desc = "Search commands" })
			vim.keymap.set("n", "<leader>sC", function()
				require("telescope.builtin").command_history({})
			end, { desc = "Search history" })
			vim.keymap.set("n", "<leader>co", function()
				require("telescope.builtin").colorscheme({})
			end, { desc = "Search color scheme" })
			vim.keymap.set("n", "<leader>sd", function()
				require("telescope.builtin").diagnostics({})
			end, { desc = "Search diagonostics" })
			vim.keymap.set("n", "<leader>sg", vim.live_grep_from_project_git_root, { desc = "Grep from git files" })
			vim.keymap.set("n", "<leader>sw", function()
				require("telescope.builtin").live_grep({})
			end, { desc = "Search word with live grep" })
			vim.keymap.set("n", "<leader>sW", function()
				require("telescope.builtin").grep_string({})
			end, { desc = "Search word with grep" })
			vim.keymap.set("n", "<leader>sh", function()
				require("telescope.builtin").help_tags({})
			end, { desc = "Search help tags" })
			vim.keymap.set("n", "<leader>sH", function()
				require("telescope.builtin").highlights({})
			end, { desc = "Search highlights" })
			vim.keymap.set("n", "<leader>sj", function()
				require("telescope.builtin").jumplist({})
			end, { desc = "Search jump list" })
			vim.keymap.set("n", "<leader>skb", function()
				require("telescope.builtin").keymaps({})
			end, { desc = "Search key bindings" })
			vim.keymap.set("n", "<leader>sl", function()
				require("telescope.builtin").loclist({})
			end, { desc = "Search location list" })
			vim.keymap.set("n", "<leader>sm", function()
				require("telescope.builtin").marks({})
			end, { desc = "Search marks" })
			vim.keymap.set("n", "<leader>sM", function()
				require("telescope.builtin").man_pages({})
			end, { desc = "Search man pages" })
			vim.keymap.set("n", "<leader>so", function()
				require("telescope.builtin").vim_options({})
			end, { desc = "Search vim options" })
			vim.keymap.set("n", "<leader>sq", function()
				require("telescope.builtin").quickfix({})
			end, { desc = "Search quickfix list" })
			vim.keymap.set("n", "<leader>sQ", function()
				require("telescope.builtin").quickfixhistory({})
			end, { desc = "Search quickfix history" })
			vim.keymap.set("n", "<leader>sr", function()
				require("telescope.builtin").registers({})
			end, { desc = "Search registers" })
			vim.keymap.set("n", "<leader>sR", function()
				require("telescope.builtin").resume({})
			end, { desc = "Search resume" })
			vim.keymap.set("n", "<leader>st", function()
				require("telescope.builtin").filetypes({})
			end, { desc = "Search file types" })
			vim.keymap.set("n", "<leader>skk", function()
				local word = vim.fn.expand("<cword>")
				require("telescope.builtin").grep_string({ search = word })
			end, { desc = "Search words under cursor" })
			vim.keymap.set("n", "<leader>skK", function()
				local word = vim.fn.expand("<cWORD>")
				require("telescope.builtin").grep_string({ search = word })
			end, { desc = "Search all words under cursor" })
		end,
	},
	{
		"cljoly/telescope-repo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("telescope").load_extension("repo")
		end,
		keys = {
			{ mode = "n", "<leader>fG", "<cmd>Telescope repo list<cr>", desc = "Find git repo" },
		},
	},
}
