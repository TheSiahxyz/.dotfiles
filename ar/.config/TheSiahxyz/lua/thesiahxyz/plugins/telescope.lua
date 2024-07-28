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
		end)
		vim.keymap.set("n", "<leader>fc", function()
			require("telescope.builtin").find_files({
				cwd = vim.fn.expand("~/.config"),
				find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
			})
		end)
		vim.keymap.set("n", "<leader>fd", function()
			require("telescope.builtin").find_files({
				cwd = vim.fn.expand("~/.dotfiles"),
				find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
			})
		end)
		vim.keymap.set("n", "<leader>ff", function()
			require("telescope.builtin").find_files({
				find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
			})
		end)
		vim.keymap.set("n", "<leader>fF", function()
            require("telescope.builtin").find_files({ cwd = vim.fn.expand("~") })
		end)
		vim.keymap.set("n", "<leader>fg", vim.find_files_from_project_git_root)
		vim.keymap.set("n", "<leader>fG", function()
			require("telescope.builtin").git_files({
				find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
			})
		end)
		vim.keymap.set("n", "<leader>fn", function()
			require("telescope.builtin").find_files({
				cwd = vim.fn.stdpath("config"),
				find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
			})
		end)
		vim.keymap.set("n", "<leader>fo", function()
			require("telescope.builtin").oldfiles({
				find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" },
			})
		end)
		vim.keymap.set("n", "<leader>fr", function()
			require("telescope.builtin").find_files({
				cwd = vim.fn.expand("~/.local/bin"),
				find_command = { "rg", "--files", "--follow", "--glob", "!**/.git/*" },
			})
		end)
		vim.keymap.set("n", "<leader>fs", function()
			require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/.local/src/suckless") })
		end)
		-- git
		vim.keymap.set("n", "<leader>gc", function()
			require("telescope.builtin").git_commits({})
		end)
		vim.keymap.set("n", "<leader>gs", function()
			require("telescope.builtin").git_status({})
		end)
		-- lsp
		vim.keymap.set("n", "gR", function()
			require("telescope.builtin").lsp_references({})
		end)
		vim.keymap.set("n", "gd", function()
			require("telescope.builtin").lsp_definitions({})
		end)
		-- search
		vim.keymap.set("n", "<leader>sa", function()
			require("telescope.builtin").autocommands({})
		end)
		vim.keymap.set("n", "<leader>sbf", function()
			require("telescope.builtin").current_buffer_fuzzy_find({})
		end)
		vim.keymap.set("n", "<leader>sbt", function()
			require("telescope.builtin").current_buffer_tags({})
		end)
		vim.keymap.set("n", "<leader>sc", function()
			require("telescope.builtin").commands({})
		end)
		vim.keymap.set("n", "<leader>sC", function()
			require("telescope.builtin").command_history({})
		end)
		vim.keymap.set("n", "<leader>co", function()
			require("telescope.builtin").colorscheme({})
		end)
		vim.keymap.set("n", "<leader>sd", function()
			require("telescope.builtin").diagnostics({})
		end)
		vim.keymap.set("n", "<leader>sg", function()
			require("telescope.builtin").live_grep({})
		end)
		vim.keymap.set("n", "<leader>sG", function()
			require("telescope.builtin").grep_string({})
		end)
		vim.keymap.set("n", "<leader>sh", function()
			require("telescope.builtin").help_tags({})
		end)
		vim.keymap.set("n", "<leader>sH", function()
			require("telescope.builtin").highlights({})
		end)
		vim.keymap.set("n", "<leader>sj", function()
			require("telescope.builtin").jumplist({})
		end)
		vim.keymap.set("n", "<leader>sk", function()
			require("telescope.builtin").keymaps({})
		end)
		vim.keymap.set("n", "<leader>sl", function()
			require("telescope.builtin").loclist({})
		end)
		vim.keymap.set("n", "<leader>sm", function()
			require("telescope.builtin").marks({})
		end)
		vim.keymap.set("n", "<leader>sM", function()
			require("telescope.builtin").man_pages({})
		end)
		vim.keymap.set("n", "<leader>so", function()
			require("telescope.builtin").vim_options({})
		end)
		vim.keymap.set("n", "<leader>sq", function()
			require("telescope.builtin").quickfix({})
		end)
		vim.keymap.set("n", "<leader>sQ", function()
			require("telescope.builtin").quickfixhistory({})
		end)
		vim.keymap.set("n", "<leader>sr", function()
			require("telescope.builtin").registers({})
		end)
		vim.keymap.set("n", "<leader>st", function()
			require("telescope.builtin").filetypes({})
		end)
		vim.keymap.set("n", "<leader>sw", function()
			local word = vim.fn.expand("<cword>")
			require("telescope.builtin").grep_string({ search = word })
		end)
		vim.keymap.set("n", "<leader>sW", function()
			local word = vim.fn.expand("<cWORD>")
			require("telescope.builtin").grep_string({ search = word })
		end)
	end,
}
