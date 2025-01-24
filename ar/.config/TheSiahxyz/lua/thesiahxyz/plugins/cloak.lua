return {
	"laytan/cloak.nvim",
	lazy = false,
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n", "v" },
			{ "<leader>c", group = "Cloak" },
		})
	end,
	config = function()
		require("cloak").setup({
			enabled = true,
			cloak_character = "*",
			-- The applied highlight group (colors) on the cloaking, see `:h highlight`.
			highlight_group = "Comment",
			patterns = {
				{
					-- Match any file starting with ".env".
					-- This can be a table to match multiple file patterns.
					file_pattern = {
						".env*",
						"wrangler.toml",
						".dev.vars",
						"address*",
						"*api*",
					},
					-- Match an equals sign and any character after it.
					-- This can also be a table of patterns to cloak,
					-- example: cloak_pattern = { ":.+", "-.+" } for yaml files.
					cloak_pattern = { "=.+", ":.+", "-.+" },
				},
			},
		})
	end,
	keys = {
		{ "<leader>ce", "<cmd>CloakEnable<cr>", desc = "Enable cloak" },
		{ "<leader>cd", "<cmd>CloakDisable<cr>", desc = "Disable cloak" },
		{ "<leader>cl", "<cmd>CloakPreviewLine<cr>", desc = "Preview line cloak" },
		{ "<leader>zC", "<cmd>CloakToggle<cr>", desc = "Toggle cloak" },
	},
}
