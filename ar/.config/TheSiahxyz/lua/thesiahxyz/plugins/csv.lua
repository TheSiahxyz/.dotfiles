return {
	"hat0uma/csvview.nvim",
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
	event = { "BufReadPre *.csv" }, -- Lazy-load the plugin when a CSV file is about to be read
	config = function()
		require("csvview").setup()

		vim.api.nvim_create_autocmd("BufRead", {
			pattern = "*.csv",
			callback = function()
				pcall(vim.cmd, "CsvViewEnable") -- Call CsvViewEnable safely
			end,
		})
	end,
	keys = {
		{ "<leader>tv", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV view" },
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
}
