return {
	-- {
	-- 	"kr40/nvim-macros",
	-- 	lazy = false,
	-- 	cmd = { "MacroSave", "MacroYank", "MacroSelect", "MacroDelete" },
	-- 	opts = {},
	-- 	config = function()
	-- 		require("nvim-macros").setup({
	-- 			json_file_path = vim.fn.expand("~/.local/share/thesiah/macros.json"), -- Location where the macros will be stored
	-- 			default_macro_register = "q", -- Use as default register for :MacroYank and :MacroSave and :MacroSelect Raw functions
	-- 			json_formatter = "none", -- can be "none" | "jq" | "yq" used to pretty print the json file (jq or yq must be installed!)
	-- 		})
	-- 		vim.keymap.set("n", "yQ", ":MacroYank<CR>", { desc = "Yank macro" })
	-- 		vim.keymap.set("n", "<leader>wQ", ":MacroSave<CR>", { desc = "Save macro" })
	-- 		vim.keymap.set("n", "<leader>fQ", ":MacroSelect<CR>", { desc = "Search macro" })
	-- 		vim.keymap.set("n", "<leader>xQ", ":MacroDelete<CR>", { desc = "Delete macro" })
	-- 	end,
	-- },
	{
		"desdic/macrothis.nvim",
		opts = {},
		config = function()
			require("macrothis").setup({
				datafile = (function()
					local path = vim.fn.expand("~/.local/share/thesiah/macros.json")

					-- Create directory if it doesn't exist
					local dir = vim.fn.fnamemodify(path, ":h")
					if vim.fn.isdirectory(dir) == 0 then
						vim.fn.mkdir(dir, "p")
					end

					-- Create file if it doesn't exist or is empty
					if vim.fn.filereadable(path) == 0 or vim.fn.getfsize(path) == 0 then
						local file = io.open(path, "w")
						if file then
							file:write("[]")
							file:close()
						end
					end

					return path
				end)(),
				run_register = "Q", -- content of register z is replaced when running/editing a macro
				editor = { -- Edit window
					width = 100,
					height = 2,
					style = "minimal",
					border = "rounded",
				},
				clipboard_register = '"',
				default_register = "q", -- Use this register when loading a macro (will never prompt for register if set)
			})
			require("telescope").load_extension("macrothis")
			vim.keymap.set("n", "<leader>fq", ":Telescope macrothis<CR>", { desc = "Find macro" })
		end,
		keys = {
			{
				"<Leader>dq",
				function()
					require("macrothis").delete()
				end,
				desc = "Delete macro",
			},
			{
				"<Leader>eq",
				function()
					require("macrothis").edit()
				end,
				desc = "Edit macro",
			},
			{
				"<Leader>lq",
				function()
					require("macrothis").load()
				end,
				desc = "Load macro",
			},
			{
				"<Leader>rnq",
				function()
					require("macrothis").rename()
				end,
				desc = "Rename macro",
			},
			{
				"<Leader>rQ",
				function()
					require("macrothis").quickfix()
				end,
				desc = "Run macro on all files in quickfix",
			},
			{
				"<Leader>rq",
				function()
					require("macrothis").run()
				end,
				desc = "Run macro",
			},
			{
				"<Leader>wq",
				function()
					require("macrothis").save()
				end,
				desc = "Save macro",
			},
			{
				'<Leader>e"',
				function()
					require("macrothis").register()
				end,
				desc = "Edit register",
			},
			{
				'y"',
				function()
					require("macrothis").copy_register_printable()
				end,
				desc = "Copy register as printable",
			},
			{
				"yq",
				function()
					require("macrothis").copy_macro_printable()
				end,
				desc = "Copy macro as printable",
			},
		},
	},
	-- {
	-- 	"ecthelionvi/NeoComposer.nvim",
	-- 	dependencies = { "kkharji/sqlite.lua" },
	-- 	opts = {},
	-- 	config = function()
	-- 		require("NeoComposer").setup({
	-- 			notify = true,
	-- 			delay_timer = 150,
	-- 			queue_most_recent = false,
	-- 			window = {
	-- 				width = 80,
	-- 				height = 10,
	-- 				border = "rounded",
	-- 				winhl = {
	-- 					Normal = "ComposerNormal",
	-- 				},
	-- 			},
	-- 			colors = {
	-- 				bg = "NONE",
	-- 				fg = "#ff9e64",
	-- 				red = "#ec5f67",
	-- 				blue = "#5fb3b3",
	-- 				green = "#99c794",
	-- 			},
	-- 			keymaps = {
	-- 				play_macro = "Q",
	-- 				yank_macro = "yq",
	-- 				stop_macro = "cq",
	-- 				toggle_record = "q",
	-- 				cycle_next = "<m-n>",
	-- 				cycle_prev = "<m-p>",
	-- 				toggle_macro_menu = "<m-q>",
	-- 			},
	-- 		})
	--
	-- 		require("telescope").load_extension("macros")
	--
	-- 		vim.keymap.set("n", "<leader>sm", ":Telescope macros<CR>", { desc = "Search macros" })
	-- 		vim.keymap.set("n", "<leader>em", ":EditMacros<CR>", { desc = "Edit macros" })
	-- 		vim.keymap.set("n", "<leader>xm", ":ClearNeoComposer<CR>", { desc = "Clear macros" })
	-- 	end,
	-- },
}
