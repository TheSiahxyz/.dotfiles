if os.getenv("NVIM") then
	require("toggle-pane"):entry("min-preview")
end

require("smart-enter"):setup({
	open_multi = true,
})

require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.PLAIN,
})

th.git = th.git or {}
th.git.modified_sign = "M"
th.git.deleted_sign = "D"
require("git"):setup()

require("mactag"):setup({
	keys = {
		r = "Red",
		o = "Orange",
		y = "Yellow",
		g = "Green",
		b = "Blue",
		p = "Purple",
	},
	colors = {
		Red = "#ee7b70",
		Orange = "#f5bd5c",
		Yellow = "#fbe764",
		Green = "#91fc87",
		Blue = "#5fa3f8",
		Purple = "#cb88f8",
	},
})
