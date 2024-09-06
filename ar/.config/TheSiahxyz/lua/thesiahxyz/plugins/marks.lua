return {
	"chentoast/marks.nvim",
	config = function()
		require("marks").setup()
	end,
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n" },
			{ "m", group = "Marks" },
		})
	end,
}
