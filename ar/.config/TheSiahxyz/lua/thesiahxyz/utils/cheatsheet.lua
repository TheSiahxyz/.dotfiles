local options = {
	cheatsheet = {
		theme = "grid", -- Options: "simple" or "grid"
		excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" }, -- Exclude specific groups
	},
}

-- Define a keymap for opening the cheatsheet
vim.keymap.set("n", "<leader>skc", function()
	require("thesiahxyz.utils.cheatsheet.grid")()
end, { desc = "Open Cheatsheet" })

return options
