return {
	"chentoast/marks.nvim",
	config = function()
		require("marks").setup()
	end,
	init = function()
		local wk = require("which-key")
		wk.add({
			{
				mode = { "n", "v" },
				{ "m", group = "Marks" },
				{ "dm", desc = "Delete marks" },
			},
		})
	end,
}
