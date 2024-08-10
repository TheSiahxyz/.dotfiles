local have_make = vim.fn.executable("make") == 1
local have_cmake = vim.fn.executable("cmake") == 1

function vim.find_files_from_project_git_root()
	local function is_git_repo()
		vim.fn.system("git rev-parse --is-inside-work-tree")
		return vim.v.shell_error == 0
	end
	local function get_git_root()
		local dot_git_path = vim.fn.finddir(".git", ".;")
		return vim.fn.fnamemodify(dot_git_path, ":h")
	end
	local opts = {}
	if is_git_repo() then
		opts = {
			cwd = get_git_root(),
		}
	end
	require("telescope.builtin").find_files(opts)
end

return {
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
	},
	config = function()
		require("telescope").setup({
			defaults = {
				-- ....
			},
			pickers = {
				find_files = {
					mappings = {
						n = {
							["cd"] = function(prompt_bufnr)
								local selection = require("telescope.actions.state").get_selected_entry()
								local dir = vim.fn.fnamemodify(selection.path, ":p:h")
								require("telescope.actions").close(prompt_bufnr)
								-- Depending on what you want put `cd`, `lcd`, `tcd`
								vim.cmd(string.format("silent lcd %s", dir))
							end,
						},
					},
				},
			},
		})

		-- find
		vim.keymap.set("n", "<leader>fb", function()
			require("telescope.builtin").buffers({})
		end, { desc = "Find Buffer Files" })
		vim.keymap.set("n", "<leader>fc", function()
			require("telescope.builtin").find_files({
				cwd = vim.fn.expand("~/.config"),
				find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
			})
		end, { desc = "Find Config Files" })
		vim.keymap.set("n", "<leader>fd", function()
			require("telescope.builtin").find_files({
				cwd = vim.fn.expand("~/.dotfiles"),
				find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
			})
		end, { desc = "Find Dotfiles Files" })
		vim.keymap.set("n", "<leader>ff", function()
			require("telescope.builtin").find_files({
				find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
			})
		end, { desc = "Find Files" })
		vim.keymap.set("n", "<leader>fF", function()
			require("telescope.builtin").find_files({ cwd = vim.fn.expand("~") })
		end, { desc = "Find Root Files" })
		vim.keymap.set("n", "<leader>fg", vim.find_files_from_project_git_root, { desc = "Find Root Git Files" })
		vim.keymap.set("n", "<leader>fG", function()
			require("telescope.builtin").git_files({
				find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
			})
		end, { desc = "Find Git Files" })
		vim.keymap.set("n", "<leader>fn", function()
			require("telescope.builtin").find_files({
				cwd = vim.fn.stdpath("config"),
				find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
			})
		end, { desc = "Find Neovim Config Files" })
		vim.keymap.set("n", "<leader>fo", function()
			require("telescope.builtin").oldfiles({
				find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
			})
		end, { desc = "Find Old Files" })
		vim.keymap.set("n", "<leader>fpv", function()
			require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/Private") })
		end, { desc = "Find Private Files" })
		vim.keymap.set("n", "<leader>fpb", function()
			require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/Public") })
		end, { desc = "Find Public Files" })
		vim.keymap.set("n", "<leader>fr", function()
			require("telescope.builtin").find_files({
				cwd = vim.fn.expand("~/.local/bin"),
				find_command = { "rg", "--files", "--follow", "--glob", "!**/.git/*" },
			})
		end, { desc = "Find Script Files" })
		vim.keymap.set("n", "<leader>fs", function()
			require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/.local/src/suckless") })
		end, { desc = "Find Suckless Files" })
		-- git
		vim.keymap.set("n", "<leader>gc", function()
			require("telescope.builtin").git_commits({})
		end, { desc = "Find Git Commits" })
		vim.keymap.set("n", "<leader>gs", function()
			require("telescope.builtin").git_status({})
		end, { desc = "Find Git Status" })
		-- lsp
		vim.keymap.set("n", "gR", function()
			require("telescope.builtin").lsp_references({})
		end, { desc = "Find Lsp References" })
		vim.keymap.set("n", "gd", function()
			require("telescope.builtin").lsp_definitions({})
		end, { desc = "Find Lsp Definitions" })
		-- search
		vim.keymap.set("n", "<leader>sa", function()
			require("telescope.builtin").autocommands({})
		end, { desc = "Search Auto Commands" })
		vim.keymap.set("n", "<leader>sbf", function()
			require("telescope.builtin").current_buffer_fuzzy_find({})
		end, { desc = "Search Current Buffers " })
		vim.keymap.set("n", "<leader>sbt", function()
			require("telescope.builtin").current_buffer_tags({})
		end, { desc = "Search Current Buffer Tags" })
		vim.keymap.set("n", "<leader>sc", function()
			require("telescope.builtin").commands({})
		end, { desc = "Search Commands" })
		vim.keymap.set("n", "<leader>sC", function()
			require("telescope.builtin").command_history({})
		end, { desc = "Search History" })
		vim.keymap.set("n", "<leader>co", function()
			require("telescope.builtin").colorscheme({})
		end, { desc = "Search Color Scheme" })
		vim.keymap.set("n", "<leader>sd", function()
			require("telescope.builtin").diagnostics({})
		end, { desc = "Search Diagonostics" })
		vim.keymap.set("n", "<leader>sg", function()
			require("telescope.builtin").live_grep({})
		end, { desc = "Live Grep" })
		vim.keymap.set("n", "<leader>sG", function()
			require("telescope.builtin").grep_string({})
		end, { desc = "Grep String" })
		vim.keymap.set("n", "<leader>sh", function()
			require("telescope.builtin").help_tags({})
		end, { desc = "Search Help Tags" })
		vim.keymap.set("n", "<leader>sH", function()
			require("telescope.builtin").highlights({})
		end, { desc = "Search Highlights" })
		vim.keymap.set("n", "<leader>sj", function()
			require("telescope.builtin").jumplist({})
		end, { desc = "Search Jump List" })
		vim.keymap.set("n", "<leader>sk", function()
			require("telescope.builtin").keymaps({})
		end, { desc = "Search Keymaps" })
		vim.keymap.set("n", "<leader>sl", function()
			require("telescope.builtin").loclist({})
		end, { desc = "Search Location List" })
		vim.keymap.set("n", "<leader>sm", function()
			require("telescope.builtin").marks({})
		end, { desc = "Search Marks" })
		vim.keymap.set("n", "<leader>sM", function()
			require("telescope.builtin").man_pages({})
		end, { desc = "Search Man Pages" })
		vim.keymap.set("n", "<leader>so", function()
			require("telescope.builtin").vim_options({})
		end, { desc = "Search Vim Options" })
		vim.keymap.set("n", "<leader>sq", function()
			require("telescope.builtin").quickfix({})
		end, { desc = "Search Quickfix List" })
		vim.keymap.set("n", "<leader>sQ", function()
			require("telescope.builtin").quickfixhistory({})
		end, { desc = "Search Quickfix History" })
		vim.keymap.set("n", "<leader>sr", function()
			require("telescope.builtin").registers({})
		end, { desc = "Search Registers" })
		vim.keymap.set("n", "<leader>st", function()
			require("telescope.builtin").filetypes({})
		end, { desc = "Search File Types" })
		vim.keymap.set("n", "<leader>sw", function()
			local word = vim.fn.expand("<cword>")
			require("telescope.builtin").grep_string({ search = word })
		end, { desc = "Search Words Under Cursor" })
		vim.keymap.set("n", "<leader>sW", function()
			local word = vim.fn.expand("<cWORD>")
			require("telescope.builtin").grep_string({ search = word })
		end, { desc = "Search All Words Under Cursor" })
	end,
}
