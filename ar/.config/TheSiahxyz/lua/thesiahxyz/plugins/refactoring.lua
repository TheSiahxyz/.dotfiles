return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("refactoring").setup({
            prompt_func_return_type = {
                c = true,
                cpp = true,
                cxx = true,
                go = true,
                h = true,
                hpp = true,
                java = true,
                lua = true,
                python = true,
            },
            prompt_func_param_type = {
                c = true,
                cpp = true,
                cxx = true,
                go = true,
                h = true,
                hpp = true,
                java = true,
                lua = true,
                python = true,
            },
            printf_statements = {},
            print_var_statements = {},
            show_success_message = false,
        })
        vim.keymap.set("x", "<leader>re", ":Refactor extract ")
        vim.keymap.set("x", "<leader>rf", ":Refactor extract_to_file ")
        vim.keymap.set("x", "<leader>rv", ":Refactor extract_var ")
        vim.keymap.set({ "n", "x" }, "<leader>ri", ":Refactor inline_var")
        vim.keymap.set( "n", "<leader>rI", ":Refactor inline_func")
        vim.keymap.set("n", "<leader>rb", ":Refactor extract_block")
        vim.keymap.set("n", "<leader>rbf", ":Refactor extract_block_to_file")
        -- prompt for a refactor to apply when the remap is triggered
        vim.keymap.set(
            {"n", "x"},
            "<leader>rr",
            function() require('refactoring').select_refactor() end
        )
        -- Note that not all refactor support both normal and visual mode
        -- load refactoring Telescope extension
        require("telescope").load_extension("refactoring")
        vim.keymap.set(
            {"n", "x"},
            "<leader>rt",
            function() require('telescope').extensions.refactoring.refactors() end
        )
	end,
}
