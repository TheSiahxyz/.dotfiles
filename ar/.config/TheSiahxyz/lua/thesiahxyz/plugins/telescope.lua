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
				},
			})

			-- find
			vim.keymap.set("n", "<leader>fb", function()
				require("telescope.builtin").buffers({})
			end, { desc = "Find buffer files" })
			vim.keymap.set("n", "<leader>fc", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.expand("~/.config"),
					find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
				})
			end, { desc = "Find config files" })
			vim.keymap.set("n", "<leader>fd", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.expand("~/.dotfiles"),
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				})
			end, { desc = "Find dotfiles files" })
			vim.keymap.set("n", "<leader>ff", function()
				require("telescope.builtin").find_files({
					find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
				})
			end, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fF", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("~") })
			end, { desc = "Find root files" })
			vim.keymap.set("n", "<leader>fg", function()
				require("telescope.builtin").git_files({
					find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
				})
			end, { desc = "Find git files" })
			vim.keymap.set("n", "<leader>fn", function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.stdpath("config"),
					find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
				})
			end, { desc = "Find neovim config files" })
			vim.keymap.set("n", "<leader>fo", function()
				require("telescope.builtin").oldfiles({
					find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
				})
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
					find_command = { "rg", "--files", "--follow", "--glob", "!**/.git/*" },
				})
			end, { desc = "Find script files" })
			vim.keymap.set("n", "<leader>fs", function()
				require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/.local/src/suckless") })
			end, { desc = "Find suckless files" })
			-- git
			vim.keymap.set("n", "<leader>gc", function()
				require("telescope.builtin").git_commits({})
			end, { desc = "Find git commits" })
			vim.keymap.set("n", "<leader>gs", function()
				require("telescope.builtin").git_status({})
			end, { desc = "Find git status" })
			-- lsp
			vim.keymap.set("n", "gR", function()
				require("telescope.builtin").lsp_references({})
			end, { desc = "Find lsp references" })
			vim.keymap.set("n", "gd", function()
				require("telescope.builtin").lsp_definitions({})
			end, { desc = "Find lsp definitions" })
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
