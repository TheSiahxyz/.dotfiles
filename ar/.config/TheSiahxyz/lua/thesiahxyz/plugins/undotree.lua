return {
	"mbbill/undotree",
	config = function()
		vim.keymap.set("n", "<leader>eu", vim.cmd.UndotreeToggle, { desc = "Toggle undo tree" })
	end,
}
