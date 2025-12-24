return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n", "v", "x" },
			{ "<leader>r", group = "Compiler/Refactoring" },
			{ "<leader>rb", group = "Extract block" },
		})
	end,
	lazy = false,
	config = function()
		require("refactoring").setup({
			prompt_func_return_type = {
				c = true,
				cpp = true,
				cxx = true,
				go = true,
				h = true,
				hpp = true,
				java = true,
				lua = true,
				python = true,
			},
			prompt_func_param_type = {
				c = true,
				cpp = true,
				cxx = true,
				go = true,
				h = true,
				hpp = true,
				java = true,
				lua = true,
				python = true,
			},
			printf_statements = {},
			print_var_statements = {},
			show_success_message = false,
		})
		vim.keymap.set({ "n", "x" }, "<leader>re", function()
			return require("refactoring").refactor("Extract Function")
		end, { expr = true, desc = "Extract" })
		vim.keymap.set({ "n", "x" }, "<leader>rf", function()
			return require("refactoring").refactor("Extract Function To File")
		end, { expr = true, desc = "Extract to file" })
		vim.keymap.set({ "n", "x" }, "<leader>rv", function()
			return require("refactoring").refactor("Extract Variable")
		end, { expr = true, desc = "Extract variable" })
		vim.keymap.set({ "n", "x" }, "<leader>rI", function()
			return require("refactoring").refactor("Inline Function")
		end, { expr = true, desc = "Refactor inline function" })
		vim.keymap.set({ "n", "x" }, "<leader>ri", function()
			return require("refactoring").refactor("Inline Variable")
		end, { expr = true, desc = "Refactor inline variable" })

		vim.keymap.set({ "n", "x" }, "<leader>rbb", function()
			return require("refactoring").refactor("Extract Block")
		end, { expr = true, desc = "Extract block" })
		vim.keymap.set({ "n", "x" }, "<leader>rbf", function()
			return require("refactoring").refactor("Extract Block To File")
		end, { expr = true, desc = "Extract block to file" })

		-- prompt for a refactor to apply when the remap is triggered
		vim.keymap.set({ "n", "x" }, "<leader>rs", function()
			require("refactoring").select_refactor({ prefer_ex_cmd = true })
		end, { desc = "Refactor selection" })
		-- Note that not all refactor support both normal and visual mode
		-- load refactoring Telescope extension
		require("telescope").load_extension("refactoring")
		vim.keymap.set({ "n", "x" }, "<leader>rf", function()
			require("telescope").extensions.refactoring.refactors()
		end, { desc = "Open refactor" })
	end,
}
