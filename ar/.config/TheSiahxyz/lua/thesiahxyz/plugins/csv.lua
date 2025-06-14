return {
	{
		"hat0uma/csvview.nvim",
		cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
		event = { "BufReadPre *.csv" }, -- Lazy-load the plugin when a CSV file is about to be read
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v", "x" },
				{ "<leader>cs", group = "csv" },
			})
		end,
		config = function()
			require("csvview").setup()

			vim.api.nvim_create_autocmd("BufRead", {
				pattern = "*.csv",
				callback = function()
					vim.cmd("CsvViewEnable")
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "csv",
				callback = function()
					vim.keymap.set(
						"n",
						"<leader>zv",
						"<cmd>CsvViewToggle<cr>",
						{ desc = "Toggle CSV view", buffer = true }
					)
				end,
			})
		end,
		keys = {
			{
				"<leader>csv",
				function()
					local delimiter = vim.fn.input("Delimiter (e.g., ,): ")
					local quote_char = vim.fn.input("Quote char (e.g., '): ")
					local comment = vim.fn.input("Comment char (e.g., #): ")
					local command = string.format(
						":CsvViewToggle delimiter=%s quote_char=%s comment=%s<CR>",
						delimiter,
						quote_char,
						comment
					)

					vim.cmd(command)
				end,
				desc = "Toggle CSV view",
			},
		},
	},
}
