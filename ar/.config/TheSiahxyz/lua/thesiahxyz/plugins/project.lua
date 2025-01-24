return {
	"ahmedkhalf/project.nvim",
	dependencies = "nvim-telescope/telescope.nvim",
	config = function()
		require("project_nvim").setup()
		require("telescope").load_extension("projects")

		vim.keymap.set("n", "<leader>fpj", function()
			require("telescope").extensions.projects.projects()
		end, { desc = "Find projects" })
	end,
}
