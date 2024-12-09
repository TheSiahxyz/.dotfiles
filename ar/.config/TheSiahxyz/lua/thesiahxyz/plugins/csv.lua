return {
	"hat0uma/csvview.nvim",
	cmd = { "CsvViewToggle" },
	config = function()
		require("csvview").setup()
	end,
	keys = {
		{ "<leader>tv", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV view" },
		{
			"<leader>csv",
			function()
				-- Prompt the user for delimiter
				local delimiter = vim.fn.input("Delimiter (e.g., ,): ")
				-- Prompt the user for quote_char
				local quote_char = vim.fn.input("Quote char (e.g., '): ")
				-- Prompt the user for comment character
				local comment = vim.fn.input("Comment char (e.g., #): ")

				-- Construct the CsvViewToggle command
				local command = string.format(
					":CsvViewToggle delimiter=%s quote_char=%s comment=%s<CR>",
					delimiter,
					quote_char,
					comment
				)

				-- Execute the command
				vim.cmd(command)
			end,
			desc = "Toggle CSV view",
		},
	},
}
