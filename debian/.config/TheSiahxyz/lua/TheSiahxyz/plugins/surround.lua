return {
	"echasnovski/mini.surround",
	version = "*",
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n", "v" },
			{ "s", group = "Surround/Search & replace on line" },
		})
	end,
	config = function()
		require("mini.surround").setup()
	end,
}
