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
			{ "<leader>rd", group = "Debug" },
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

		local keymap = vim.keymap

		keymap.set({ "n", "x" }, "<leader>re", function()
			return require("refactoring").extract_func()
		end, { desc = "Extract Function", expr = true })
		-- `_` is the default textobject for "current line"
		keymap.set("n", "<leader>ree", function()
			return require("refactoring").extract_func() .. "_"
		end, { desc = "Extract Function (line)", expr = true })

		keymap.set({ "n", "x" }, "<leader>rE", function()
			return require("refactoring").extract_func_to_file()
		end, { desc = "Extract Function To File", expr = true })

		keymap.set({ "n", "x" }, "<leader>rv", function()
			return require("refactoring").extract_var()
		end, { desc = "Extract Variable", expr = true })

		-- `_` is the default textobject for "current line"
		keymap.set("n", "<leader>rvv", function()
			return require("refactoring").extract_var() .. "_"
		end, { desc = "Extract Variable (line)", expr = true })

		keymap.set({ "n", "x" }, "<leader>ri", function()
			return require("refactoring").inline_var()
		end, { desc = "Inline Variable", expr = true })
		keymap.set({ "n", "x" }, "<leader>rI", function()
			return require("refactoring").inline_func()
		end, { desc = "Inline function", expr = true })

		keymap.set({ "n", "x" }, "<leader>rs", function()
			return require("refactoring").select_refactor()
		end, { desc = "Select refactor" })

		-- `iw` is the builtin textobject for "in word". You can use any other textobject or even create the keymap without any textobject if you prefer to provide one yourself each time that you use the keymap
		keymap.set({ "x", "n" }, "<leader>rdv", function()
			return require("refactoring.debug").print_var({ output_location = "below" }) .. "iw"
		end, { desc = "Debug print var below", expr = true })

		-- `iw` is the builtin textobject for "in word". You can use any other textobject or even create the keymap without any textobject if you prefer to provide one yourself each time that you use the keymap
		keymap.set({ "x", "n" }, "<leader>rdV", function()
			return require("refactoring.debug").print_var({ output_location = "above" }) .. "iw"
		end, { desc = "Debug print var above", expr = true })

		keymap.set({ "x", "n" }, "<leader>rde", function()
			return require("refactoring.debug").print_exp({ output_location = "below" })
		end, { desc = "Debug print exp below", expr = true })
		-- `_` is the default textobject for "current line"
		keymap.set("n", "<leader>rdee", function()
			return require("refactoring.debug").print_exp({ output_location = "below" }) .. "_"
		end, { desc = "Debug print exp below", expr = true })

		keymap.set({ "x", "n" }, "<leader>rdE", function()
			return require("refactoring.debug").print_exp({ output_location = "above" })
		end, { desc = "Debug print exp above", expr = true })
		-- `_` is the default textobject for "current line"
		keymap.set("n", "<leader>rdEE", function()
			return require("refactoring.debug").print_exp({ output_location = "above" }) .. "_"
		end, { desc = "Debug print exp above", expr = true })

		keymap.set("n", "<leader>rdP", function()
			return require("refactoring.debug").print_loc({ output_location = "above" })
		end, { desc = "Debug print location", expr = true })
		keymap.set("n", "<leader>rdp", function()
			return require("refactoring.debug").print_loc({ output_location = "below" })
		end, { desc = "Debug print location", expr = true })

		keymap.set({ "x", "n" }, "<leader>rdc", function()
			-- `ag` is a custom textobject that selects the whole buffer. It's provided by plugins like `mini.ai` (requires manual configuration using `MiniExtra.gen_ai_spec.buffer()`).
			-- return require("refactoring.debug").cleanup { restore_view = true } .. "ag"

			-- this keymap doesn't select any textobject by default, so you need to provide one each time you use it.
			return require("refactoring.debug").cleanup({ restore_view = true })
		end, { desc = "Debug print clean", expr = true, remap = true })
	end,
}
