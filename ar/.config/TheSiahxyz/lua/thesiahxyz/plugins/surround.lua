return {
	"echasnovski/mini.surround",
	version = "*",
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n", "v", "x" },
			{ "s", group = "Surround" },
		})
	end,
	config = function()
		require("mini.surround").setup()
	end,
}
