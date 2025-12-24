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

local function find_nvim_plugin_files(prompt_bufnr)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	actions.close(prompt_bufnr)

	local selection = action_state.get_selected_entry()
	if selection and selection.value then
		-- Construct the full path
		local base_path = vim.fn.stdpath("data")
		local full_path = vim.fn.resolve(base_path .. "/" .. selection.value)

		require("mini.files").open(full_path, true)
	end
end

return {
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
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
						hijack_netrw = false,
						use_fd = true,
						git_status = true,
						mappings = {
							["i"] = {
								["<C-a>"] = fb_actions.create,
								["<C-e>"] = fb_actions.create_from_prompt,
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
						results_title = vim.fn.fnamemodify(vim.uv.cwd(), ":~"),
					},
				},
			})

			require("telescope").load_extension("file_browser")

			vim.keymap.set(
				"n",
				"<leader>et",
				":Telescope file_browser path=%:p:h select_buffer=true<CR>",
				{ desc = "File browser (cwd)" }
			)
			vim.keymap.set("n", "<leader>eT", ":Telescope file_browser<CR>", { desc = "File browser" })
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
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
				"nvim-telescope/telescope-github.nvim",
				init = function()
					local wk = require("which-key")
					wk.add({
						mode = { "n" },
						{ "<leader>gh", group = "gh" },
					})
				end,
				config = function()
					require("telescope").load_extension("gh")
					vim.keymap.set({ "n", "v" }, "<leader>gi", ":Telescope gh issues ", { desc = "Find gh issues" })
					vim.keymap.set(
						{ "n", "v" },
						"<leader>gp",
						":Telescope gh pull_request ",
						{ desc = "Find gh pull request" }
					)
					vim.keymap.set({ "n", "v" }, "<leader>ght", ":Telescope gh gist ", { desc = "Find gh gist" })
					vim.keymap.set({ "n", "v" }, "<leader>ghr", ":Telescope gh run ", { desc = "Find gh run" })
				end,
			},
			{
				"nvim-telescope/telescope-ui-select.nvim",
				config = function()
					require("telescope").setup({
						extensions = {
							["ui-select"] = {
								require("telescope.themes").get_dropdown({
									-- even more opts
								}),

								-- pseudo code / specification for writing custom displays, like the one
								-- for "codeactions"
								-- specific_opts = {
								--     make_indexed = function(items) -> indexed_items, width,
								--   [kind] = {
								--     make_displayer = function(widths) -> displayer
								--     make_display = function(displayer) -> function(e)
								--     make_ordinal = function(e) -> string
								--   },
								--   -- for example to disable the custom builtin "codeactions" display
								--      do the following
								--   codeactions = false,
								-- }
							},
						},
					})
					require("telescope").load_extension("ui-select")
				end,
			},
			{
				"jvgrootveld/telescope-zoxide",
				dependencies = { "nvim-lua/popup.nvim" },
				config = function()
					require("telescope").setup({
						extensions = {
							zoxide = {
								prompt_title = "[ TheSiahxyz ]",
								mappings = {
									default = {
										action = function(selection)
											vim.cmd.cd(selection.path)
										end,
										after_action = function(selection)
											print("Update to (" .. selection.z_score .. ") " .. selection.path)
										end,
									},
									["<C-s>"] = {
										action = require("telescope._extensions.zoxide.utils").create_basic_command(
											"split"
										),
										opts = { desc = "split" },
									},
									["<C-v>"] = {
										action = require("telescope._extensions.zoxide.utils").create_basic_command(
											"vsplit"
										),
									},
									["<C-e>"] = {
										action = require("telescope._extensions.zoxide.utils").create_basic_command(
											"edit"
										),
									},
									["<C-b>"] = {
										keepinsert = true,
										action = function(selection)
											require("telescope").extensions.file_browser.file_browser({
												cwd = selection.path,
											})
										end,
									},
								},
							},
						},
					})
					require("telescope").load_extension("zoxide")

					vim.keymap.set("n", "<leader>fz", function()
						require("telescope").extensions.zoxide.list()
					end, { desc = "Find files (zoxide)" })
				end,
			},
			{
				"nvim-telescope/telescope-live-grep-args.nvim",
				-- This will not install any breaking changes.
				-- For major updates, this must be adjusted manually.
				version = "^1.0.0",
				init = function()
					local wk = require("which-key")
					wk.add({
						mode = { "n", "v" },
						{ "<leader>f", group = "Find" },
						{ "<leader>F", group = "Find (root)" },
						{ "<leader>fl", group = "Live grep" },
					})
				end,
				config = function()
					local lga_actions = require("telescope-live-grep-args.actions")
					local actions = require("telescope.actions")

					require("telescope").setup({
						extensions = {
							live_grep_args = {
								auto_quoting = true, -- enable/disable auto-quoting
								-- define mappings, e.g.
								mappings = { -- extend mappings
									i = {
										["<C-w>"] = lga_actions.quote_prompt(),
										["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
										-- freeze the current list and start a fuzzy search in the frozen list
										["<C-space>"] = actions.to_fuzzy_refine,
									},
								},
								vimgrep_arguments = {
									"rg",
									"--color=never",
									"--no-heading",
									"--with-filename",
									"--line-number",
									"--column",
									"--smart-case",
									"--follow",
									"--hidden",
									"--no-ignore",
								},
								-- ... also accepts theme settings, for example:
								-- theme = "dropdown", -- use dropdown theme
								-- theme = { }, -- use own theme spec
								-- layout_config = { mirror=true }, -- mirror preview pane
							},
						},
					})
					require("telescope").load_extension("live_grep_args")
					vim.keymap.set("n", "<leader>flf", function()
						require("telescope").extensions.live_grep_args.live_grep_args()
					end, { desc = "Find live grep args" })

					local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
					vim.keymap.set(
						"n",
						"<leader>ss",
						live_grep_args_shortcuts.grep_word_under_cursor,
						{ desc = "Search shortcuts (Live grep)" }
					)

					local function search_git(visual)
						-- Retrieve the git root path
						local handle = io.popen("git rev-parse --show-toplevel")
						if not handle then
							print("Error: Unable to open git handle")
							return
						end

						local git_root_path = handle:read("*a"):gsub("%s+", "")
						handle:close()

						if not git_root_path or git_root_path == "" then
							print("Error: Unable to retrieve git root path")
							return
						end

						local opts = {
							prompt_title = visual and ("Visual-Grep in " .. git_root_path)
								or ("Live-Grep in " .. git_root_path),
							shorten_path = false,
							cwd = git_root_path,
							file_ignore_patterns = { ".git", ".png", "tags" },
							initial_mode = "insert",
							selection_strategy = "reset",
							theme = require("telescope.themes").get_dropdown({}),
						}

						if visual then
							-- Capture the selected text in visual mode
							vim.cmd('normal! "vy')
							local visual_selection = vim.fn.getreg("v")
							opts.search = visual_selection
							require("telescope.builtin").grep_string(opts)
						else
							require("telescope.builtin").live_grep(opts)
						end
					end

					vim.keymap.set("n", "<leader>flg", function()
						search_git(false)
					end, { remap = true, silent = false, desc = "Live grep in the git root folder" })

					vim.keymap.set("v", "<leader>flg", function()
						search_git(true)
					end, { remap = true, silent = false, desc = "Grep in the git root folder" })
					-- Retrieve the current tmux session path
					-- This will not change when we navigate to a different pane
					local function search_tmux(visual)
						local handle = io.popen("tmux display-message -p '#{session_path}'")
						if not handle then
							print("Error: Unable to open tmux handle")
							return
						end

						local tmux_session_path = handle:read("*a"):gsub("%s+", "")
						handle:close()

						if not tmux_session_path or tmux_session_path == "" then
							print("Error: Unable to retrieve tmux session path")
							return
						end

						local opts = {
							prompt_title = visual and ("Visual-Grep in " .. tmux_session_path)
								or ("Live-Grep in " .. tmux_session_path),
							shorten_path = false,
							cwd = tmux_session_path,
							file_ignore_patterns = { ".git", ".png", "tags" },
							initial_mode = "insert",
							selection_strategy = "reset",
							theme = require("telescope.themes").get_dropdown({}),
						}

						if visual then
							require("telescope.builtin").grep_string(opts)
						else
							require("telescope.builtin").live_grep(opts)
						end
					end

					vim.keymap.set("n", "<leader>flt", function()
						search_tmux(false)
					end, { remap = true, silent = false, desc = "Live grep in the current tmux session folder" })

					vim.keymap.set("v", "<leader>flt", function()
						search_tmux(true)
					end, { remap = true, silent = false, desc = "Grep string in the current tmux session folder" })
					vim.api.nvim_set_keymap(
						"v",
						"<leader>fls",
						'y<esc>:Telescope live_grep default_text=<c-r>0<cr> search_dirs={"$PWD"}',
						{ noremap = true, silent = true, desc = "Live grep default text" }
					)
					vim.keymap.set("n", "<leader>f/", function()
						require("telescope.builtin").current_buffer_fuzzy_find(
							require("telescope.themes").get_dropdown({
								winblend = 10,
								previewer = false,
								relative = "editor",
							})
						)
					end, { desc = "Find in current buffer" })
				end,
			},
			{
				"xiyaowong/telescope-emoji.nvim",
				config = function()
					require("telescope").setup({
						extensions = {
							emoji = {
								action = function(emoji)
									-- argument emoji is a table.
									-- {name="", value="", cagegory="", description=""}

									vim.fn.setreg("*", emoji.value)
									print([[Press p or "*p to paste this emoji]] .. emoji.value)

									-- insert emoji when picked
									-- vim.api.nvim_put({ emoji.value }, 'c', false, true)
								end,
							},
						},
					})
					require("telescope").load_extension("emoji")
				end,
				keys = {
					{ "<leader>se", ":Telescope emoji<cr>", desc = "Search emoji" },
				},
			},
			{
				"nvim-telescope/telescope-bibtex.nvim",
				requires = {
					{ "nvim-telescope/telescope.nvim" },
				},
				config = function()
					local bibtex_actions = require("telescope-bibtex.actions")
					require("telescope").setup({
						extensions = {
							bibtex = {
								-- Use context awareness
								context = true,
								-- Use non-contextual behavior if no context found
								-- This setting has no effect if context = false
								context_fallback = true,
								mappings = {
									i = {
										["<CR>"] = bibtex_actions.key_append("%s"), -- format is determined by filetype if the user has not set it explictly
										["<C-e>"] = bibtex_actions.entry_append,
										["<C-a>"] = bibtex_actions.citation_append("{{author}} ({{year}}), {{title}}."),
									},
								},
							},
						},
					})
					require("telescope").load_extension("bibtex")
				end,
				keys = {
					{
						"<leader>sB",
						function()
							require("telescope").extensions.bibtex.bibtex()
						end,
						desc = "Search bibtex",
					},
				},
			},
			{
				"mzlogin/vim-markdown-toc",
				keys = {
					{ "<leader>tg", "<Cmd>GenTocGFM<CR>", desc = "Generate ToC to GFM" },
					{ "<leader>tr", "<Cmd>GenTocRedcarpet<CR>", desc = "Generate ToC to Redcarpet" },
					{ "<leader>tl", "<Cmd>GenTocGitLab<CR>", desc = "Generate ToC to Gitlab" },
					{ "<leader>tm", "<Cmd>GenTocMarked<CR>", desc = "Generate ToC to Marked" },
				},
			},
			{
				"ThePrimeagen/harpoon",
				branch = "harpoon2",
				dependencies = { "nvim-lua/plenary.nvim" },
			},
			{
				"folke/trouble.nvim",
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
			local actions_layout = require("telescope.actions.layout")
			local open_with_trouble = require("trouble.sources.telescope").open
			local add_to_trouble = require("trouble.sources.telescope").add

			local function telescope_open_single_or_multi(prompt_bufnr)
				local picker = actions_state.get_current_picker(prompt_bufnr)
				local multi = picker:get_multi_selection()

				-- If you selected multiple (with <Tab>), open them all.
				if not vim.tbl_isempty(multi) then
					actions.close(prompt_bufnr)

					for _, entry in ipairs(multi) do
						-- Try to get a filepath across different pickers
						local path = entry.path -- find_files, oldfiles, etc.
							or entry.filename -- live_grep/grep_string
							or (type(entry.value) == "string" and entry.value)
							or (entry.value and entry.value.path)

						if path then
							vim.cmd("edit " .. vim.fn.fnameescape(path))

							-- (Optional) jump to the matched line/col for grep results
							local lnum = entry.lnum or entry.row
							local col = entry.col
							if lnum then
								vim.api.nvim_win_set_cursor(0, { lnum, math.max((col or 1) - 1, 0) })
							end
						elseif entry.bufnr then
							-- buffers picker
							vim.cmd("buffer " .. entry.bufnr)
						end
					end
					return
				end

				-- Single selection → let Telescope handle it
				-- This respects picker-specific behavior (e.g. jumping to lnum for grep).
				actions.select_default(prompt_bufnr)
			end
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-a>"] = add_to_trouble,
							["<C-e>"] = actions.complete_tag,
							["<C-g>"] = function(prompt_bufnr)
								local selection = actions_state.get_selected_entry()
								local dir = vim.fn.fnamemodify(selection.path, ":p:h")
								actions.close(prompt_bufnr)
								-- Depending on what you want put `cd`, `lcd`, `tcd`
								vim.cmd(string.format("silent lcd %s", dir))
							end,
							["<C-u>"] = actions.nop,
							["<C-d>"] = actions.nop,
							["<C-b>"] = actions.nop,
							["<C-f>"] = actions_layout.toggle_preview,
							["<C-j>"] = actions.preview_scrolling_down,
							["<C-k>"] = actions.preview_scrolling_up,
							["<C-h>"] = actions.preview_scrolling_left,
							["<C-l>"] = actions.preview_scrolling_right,
							["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
							["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-t>"] = open_with_trouble,
							["<C-z>"] = actions.select_horizontal,
							["<C-w>"] = { "<c-s-w>", type = "command" },
							["<C-o><C-w>"] = actions.insert_original_cword,
							["<C-o><C-a>"] = actions.insert_original_cWORD,
							["<C-o><C-f>"] = actions.insert_original_cfile,
							["<C-o><C-l>"] = actions.insert_original_cline,
							["<M-f>"] = actions.nop,
							["<M-k>"] = actions.nop,
							["<CR>"] = telescope_open_single_or_multi,
						},
						n = {
							["q"] = actions.close,
							["<C-a>"] = add_to_trouble,
							["<C-c>"] = actions.close,
							["<C-d>"] = actions.nop,
							["<C-u>"] = actions.nop,
							["<C-f>"] = actions_layout.toggle_preview,
							["<C-b>"] = actions.nop,
							["<C-e>"] = actions.complete_tag,
							["<C-g>"] = {
								function(prompt_bufnr)
									local selection = actions_state.get_selected_entry()
									local dir = vim.fn.fnamemodify(selection.path, ":p:h")
									actions.close(prompt_bufnr)
									-- Depending on what you want put `cd`, `lcd`, `tcd`
									vim.cmd(string.format("silent lcd %s", dir))
								end,
								opts = { desc = "Change directory" },
							},
							["<C-j>"] = actions.preview_scrolling_down,
							["<C-k>"] = actions.preview_scrolling_up,
							["<C-h>"] = actions.preview_scrolling_left,
							["<C-l>"] = actions.preview_scrolling_right,
							["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
							["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-t>"] = open_with_trouble,
							["<C-z>"] = actions.select_horizontal,
							["<M-f"] = actions.nop,
							["<M-k"] = actions.nop,
						},
					},
					file_ignore_patterns = {
						"node_modules",
						"yarn.lock",
						".git",
						"^.git/",
						"%/bin/zsh/",
						".sl",
						"_build",
						".next",
						"LICENSE",
						"%lock%.json",
					},
					find_command = {
						"rg",
						"--files",
						"--follow",
						"--hidden",
						"--no-ignore",
						"--sortr=modified",
					},
					hidden = true,
					path_display = {
						"filename_first",
					},
					git_worktrees = {
						{
							home = vim.env.HOME,
							private = vim.env.HOME .. "/Private/repos",
							public = vim.env.HOME .. "/Public/repos",
						},
					},
					results_title = vim.fn.fnamemodify(vim.uv.cwd(), ":~"),
					scroll_strategy = "limit",
				},
				pickers = {
					buffers = {
						mappings = {
							i = {
								["<C-x>"] = actions.delete_buffer,
							},
							n = {
								["dd"] = actions.delete_buffer,
								["<C-x>"] = actions.delete_buffer,
							},
						},
					},
					find_files = {
						-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
						find_command = {
							"rg",
							"--files",
							"--follow",
							"--hidden",
							"--sortr=modified",
							"--glob",
							"!**/.cache/*/*/*",
							"--glob",
							"!**/.git/*/*/*",
							"--glob",
							"!**/.next/*/*/*",
							"--glob",
							"!**/node_modules/*/*/*",
						},
					},
				},
			})

			-- find
			vim.keymap.set({ "i", "n" }, "<C-b>", function()
				require("telescope.builtin").buffers({
					sort_mru = true,
					sort_lastused = true,
					-- initial_mode = "normal",
				})
			end, { desc = "Find buffer files" })
			vim.keymap.set("n", "<leader>fb", function()
				require("telescope.builtin").buffers({
					sort_mru = true,
					sort_lastused = true,
					-- initial_mode = "normal",
				})
			end, { desc = "Find buffer files" })
			vim.keymap.set("n", "<leader>fc", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/.config") })
			end, { desc = "Find config files" })
			vim.keymap.set("n", "<leader>fd", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/.dotfiles") })
			end, { desc = "Find dotfiles files" })
			vim.keymap.set({ "n", "i" }, "<C-f>", function()
				require("telescope.builtin").find_files()
			end, { desc = "Find files" })
			vim.keymap.set("n", "<leader>ff", function()
				require("telescope.builtin").find_files()
			end, { desc = "Find files" })
			vim.keymap.set("n", "<leader>f<leader>", function()
				local pickers = require("telescope.pickers")
				local finders = require("telescope.finders")
				local sorters = require("telescope.config").values.generic_sorter
				local previewers = require("telescope.previewers")
				local entry_display = require("telescope.pickers.entry_display")

				-- Get list of open buffers
				local opened_files = {}
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buf) then
						local name = vim.api.nvim_buf_get_name(buf)
						if name ~= "" then
							opened_files[name] = true
						end
					end
				end

				-- Create the custom picker
				pickers
					.new({}, {
						prompt_title = "Find Files",
						finder = finders.new_oneshot_job({ "fd", "--type", "f" }, {
							entry_maker = function(entry)
								local is_open = opened_files[vim.fn.fnamemodify(entry, ":p")] -- Match absolute paths
								local displayer = entry_display.create({
									separator = " ",
									items = {
										{ width = 1 }, -- Marker width
										{ remaining = true }, -- Filepath
									},
								})

								return {
									value = entry,
									ordinal = entry,
									display = function()
										return displayer({ is_open and "*" or " ", entry })
									end,
									path = entry,
								}
							end,
						}),
						sorter = sorters({}),
						previewer = previewers.vim_buffer_cat.new({}),
					})
					:find()
			end, { desc = "Find files with open markers" })

			vim.keymap.set("n", "<leader>FF", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.expand("~"),
					find_command = {
						"rg",
						"--files",
						"--follow",
						"--hidden",
						"--glob",
						"!**/.cache/*/*/*",
						"--glob",
						"!**/.mozilla/*",
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
			vim.keymap.set("n", "<leader>fk", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.expand("~/.local/src/suckless/"),
					find_command = {
						"find",
						"-maxdepth",
						"2",
						"-type",
						"f",
						"-name",
						".git",
						"-prune",
						"-o",
					},
				})
			end, { desc = "Find suckless files" })
			vim.keymap.set("n", "<leader>fg", function()
				require("telescope.builtin").git_files()
			end, { desc = "Find git files" })
			vim.keymap.set("n", "<leader>fo", function()
				require("telescope.builtin").oldfiles({})
			end, { desc = "Find old files" })
			vim.keymap.set("n", "<leader>fpv", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/Private") })
			end, { desc = "Find private files" })
			vim.keymap.set("n", "<leader>fpb", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/Public") })
			end, { desc = "Find public files" })
			vim.keymap.set("n", "<leader>fa", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.expand("~/.local/bin"),
				})
			end, { desc = "Find script files" })
			vim.keymap.set("n", "<leader>fv", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.stdpath("config"),
					find_command = { "fd", "--type", "f", "--follow", "--color", "never", "--extension", "lua" },
				})
			end, { desc = "Find neovim config files" })
			vim.keymap.set("n", "<leader>fV", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.stdpath("data"),
					find_command = {
						"find",
						"-maxdepth",
						"2",
						"-type",
						"d",
						"-iname",
						".git",
						"-prune",
						"-o",
					},
					attach_mappings = function(_, map)
						map("i", "<CR>", find_nvim_plugin_files)
						map("n", "<CR>", find_nvim_plugin_files)
						return true
					end,
				})
			end, { desc = "Find neovim plugin files" })
			-- git
			vim.keymap.set("n", "<leader>gc", function()
				require("telescope.builtin").git_commits()
			end, { desc = "Find git commits" })
			vim.keymap.set("n", "<leader>gC", function()
				require("telescope.builtin").git_bcommits()
			end, { desc = "Find buffer git commits" })
			vim.keymap.set("n", "<leader>gb", function()
				require("telescope.builtin").git_branches()
			end, { desc = "Find branches" })
			vim.keymap.set("n", "<leader>gl", function()
				require("telescope.builtin").git_bcommits_range()
			end, { desc = "Find lines git commits" })
			vim.keymap.set("v", "<leader>gl", function()
				require("telescope.builtin").git_bcommits_range()
			end, { desc = "Find lines git commits" })
			vim.keymap.set("n", "<leader>gs", function()
				require("telescope.builtin").git_status()
			end, { desc = "Find git status" })
			vim.keymap.set("n", "<leader>gS", function()
				require("telescope.builtin").git_stash()
			end, { desc = "Find git stash" })
			-- lsp
			vim.keymap.set("n", "gd", function()
				require("telescope.builtin").lsp_definitions({})
			end, { desc = "Find definitions" })
			vim.keymap.set("n", "gR", function()
				require("telescope.builtin").lsp_references({})
			end, { desc = "Find references" })
			-- search
			vim.keymap.set("n", "<leader>cc", function()
				require("telescope.builtin").colorscheme({})
			end, { desc = "Search color scheme" })
			vim.keymap.set("n", "<leader>sa", function()
				require("telescope.builtin").autocommands({})
			end, { desc = "Search auto commands" })
			vim.keymap.set("n", "<leader>sb", function()
				require("telescope.builtin").current_buffer_fuzzy_find({})
			end, { desc = "Search current buffers " })
			vim.keymap.set("n", "<leader>st", function()
				require("telescope.builtin").current_buffer_tags({})
			end, { desc = "Search current buffer tags" })
			vim.keymap.set("n", "<leader>sc", function()
				require("telescope.builtin").commands({})
			end, { desc = "Search commands" })
			vim.keymap.set("n", "<leader>sC", function()
				require("telescope.builtin").command_history({})
			end, { desc = "Search history" })
			vim.keymap.set("n", "<leader>sd", function()
				require("telescope.builtin").diagnostics({})
			end, { desc = "Search diagonostics" })
			vim.keymap.set("n", "<leader>sg", vim.live_grep_from_project_git_root, { desc = "Live grep (git)" })
			vim.keymap.set("n", "<leader>sh", function()
				require("telescope.builtin").help_tags({})
			end, { desc = "Search help tags" })
			vim.keymap.set("n", "<leader>sH", function()
				require("telescope.builtin").highlights({})
			end, { desc = "Search highlights" })
			vim.keymap.set("n", "<leader>sj", function()
				require("telescope.builtin").jumplist({})
			end, { desc = "Search jump list" })
			vim.keymap.set({ "n", "v", "x" }, "<leader>skb", function()
				require("telescope.builtin").keymaps({})
			end, { desc = "Search key bindings" })
			vim.keymap.set("n", "<leader>skk", function()
				local word = vim.fn.expand("<cword>")
				require("telescope.builtin").grep_string({ search = word })
			end, { desc = "Search words under cursor" })
			vim.keymap.set("n", "<leader>skK", function()
				local word = vim.fn.expand("<cWORD>")
				require("telescope.builtin").grep_string({ search = word })
			end, { desc = "Search all words under cursor" })
			vim.keymap.set("n", "<leader>sl", function()
				require("telescope.builtin").loclist({})
			end, { desc = "Search location list" })
			vim.keymap.set("n", "<leader>s'", function()
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
			vim.keymap.set("n", '<leader>s"', function()
				require("telescope.builtin").registers({})
			end, { desc = "Search registers" })
			vim.keymap.set("n", "<leader>sr", function()
				require("telescope.builtin").resume({})
			end, { desc = "Search resume" })
			vim.keymap.set("n", "<leader>sf", function()
				require("telescope.builtin").filetypes({})
			end, { desc = "Search file types" })
			vim.keymap.set("n", "<leader>sw", function()
				require("telescope.builtin").live_grep({})
			end, { desc = "Search word (Live grep)" })
			vim.keymap.set("n", "<leader>sW", function()
				require("telescope.builtin").grep_string({})
			end, { desc = "Search word (Grep)" })
		end,
	},
	{
		"cljoly/telescope-repo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("telescope").setup({
				extensions = {
					repo = {
						list = {
							fd_opts = {
								"--no-ignore-vcs",
							},
							file_ignore_patterns = {
								"^" .. vim.env.HOME .. "/%.cache/",
								"^" .. vim.env.HOME .. "/%.cargo/",
							},
						},
					},
				},
			})

			require("telescope").load_extension("repo")
		end,
		keys = {
			{ mode = "n", "<leader>fG", "<Cmd>Telescope repo list<cr>", desc = "Find git files (repo)" },
		},
	},
	{
		"debugloop/telescope-undo.nvim",
		dependencies = { -- note how they're inverted to above example
			{
				"nvim-telescope/telescope.nvim",
				dependencies = { "nvim-lua/plenary.nvim" },
			},
		},
		opts = {
			-- don't use `defaults = { }` here, do this in the main telescope spec
			extensions = {
				undo = {
					-- telescope-undo.nvim config, see below
				},
				-- no other extensions here, they can have their own spec too
			},
		},
		config = function(_, opts)
			-- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
			-- configs for us. We won't use data, as everything is in it's own namespace (telescope
			-- defaults, as well as each extension).
			require("telescope").setup(opts)
			require("telescope").load_extension("undo")
		end,
		keys = {
			{ -- lazy style key map
				"<leader>fu",
				"<Cmd>Telescope undo<cr>",
				desc = "Find undo history",
			},
		},
	},
	{
		"nvim-telescope/telescope-frecency.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("telescope").setup({
				extensions = {
					frecency = {
						auto_validate = false,
						matcher = "fuzzy",
					},
				},
			})

			require("telescope").load_extension("frecency")

			vim.keymap.set("n", "<leader>fr", function()
				require("telescope").extensions.frecency.frecency({
					workspace = "CWD",
				})
			end, { desc = "Find frequency files" })

			vim.keymap.set("n", "<leader>flq", function()
				local frecency = require("telescope").extensions.frecency
				require("telescope.builtin").live_grep({
					search_dirs = frecency.query({}),
				})
			end, { desc = "Find frequency live grep" })

			vim.keymap.set("n", "<leader>qd", "<Cmd>FrecencyDelete<cr>", { desc = "Delete current buffer frequency" })
		end,
	},
	{
		"nvim-telescope/telescope-media-files.nvim",
		dependencies = {
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("telescope").setup({
				extensions = {
					media_files = {
						-- filetypes whitelist
						-- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
						filetypes = { "png", "jpg", "mp4", "mkv", "webm", "pdf" },
						-- find command (defaults to `fd`)
						find_cmd = "rg",
					},
				},
			})
			require("telescope").load_extension("media_files")
		end,
		keys = {
			{
				"<leader>fm",
				"<Cmd>Telescope media_files<cr>",
				desc = "Find media files",
			},
		},
	},
	{
		"nvim-telescope/telescope-project.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
		},
		config = function()
			local project_actions = require("telescope._extensions.project.actions")
			require("telescope").setup({
				extensions = {
					project = {
						base_dirs = {
							{ path = "~/Private", max_depth = 2 },
							{ path = "~/Public", max_depth = 2 },
						},
						mappings = {
							i = {
								["<C-x>"] = project_actions.delete_project,
								["<C-r>"] = project_actions.rename_project,
								["<C-a>"] = project_actions.add_project,
								["<C-A>"] = project_actions.add_project_cwd,
								["<C-f>"] = project_actions.find_project_files,
								["<C-b>"] = project_actions.browse_project_files,
								["<C-s>"] = project_actions.search_in_project_files,
								["<C-o>"] = project_actions.recent_project_files,
								["<C-g>"] = project_actions.change_working_directory,
								["<C-l>"] = project_actions.next_cd_scope,
								["<C-w>"] = project_actions.change_workspace,
							},
							n = {
								["x"] = project_actions.delete_project,
								["r"] = project_actions.rename_project,
								["c"] = project_actions.add_project,
								["C"] = project_actions.add_project_cwd,
								["f"] = project_actions.find_project_files,
								["b"] = project_actions.browse_project_files,
								["s"] = project_actions.search_in_project_files,
								["o"] = project_actions.recent_project_files,
								["g"] = project_actions.change_working_directory,
								["l"] = project_actions.next_cd_scope,
							},
						},
					},
				},
			})
			require("telescope").load_extension("project")
		end,
		keys = {
			{
				"<leader>fpj",
				"<Cmd>Telescope projects<cr>",
				desc = "Find projects",
			},
		},
	},
}
