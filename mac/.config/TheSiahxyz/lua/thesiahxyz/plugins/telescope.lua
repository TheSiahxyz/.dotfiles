return {
    "nvim-telescope/telescope.nvim",
    version = false,
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = vim.fn.executable("make") == 1 and "make"
                or
                "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
            enabled = vim.fn.executable("make") == 1 or vim.fn.executable("cmake") == 1,
            config = function()
                require("telescope").load_extension("fzf")
            end,
        }
    },
    config = function()
        require("telescope").setup({})

        -- find
        vim.keymap.set("n", "<leader>fb", function() require("telescope.builtin").buffers({}) end)
        vim.keymap.set("n", "<leader>fc",
            function() require('telescope.builtin').find_files({ cwd = vim.fn.expand("~/.config"), find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" } }) end)
        vim.keymap.set("n", "<leader>fd",
            function() require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/.dotfiles"), find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" } }) end)
        vim.keymap.set("n", "<leader>ff",
            function() require("telescope.builtin").find_files({ find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" } }) end)
        vim.keymap.set("n", "<leader>fg",
            function() require("telescope.builtin").git_files({ find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" } }) end)
        vim.keymap.set("n", "<leader>fn",
            function() require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config"), find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" } }) end)
        vim.keymap.set("n", "<leader>fo",
            function() require("telescope.builtin").oldfiles({ find_command = { "rg", "--files", "--follow", "--hidden", "--glob", "!**/.git/*" } }) end)
        vim.keymap.set("n", "<leader>fr",
            function() require('telescope.builtin').find_files({ cwd = vim.fn.expand("~/.local/bin"), find_command = { "rg", "--files", "--follow", "--glob", "!**/.git/*" } }) end)
        vim.keymap.set("n", "<leader>fs",
            function() require("telescope.builtin").find_files({ cwd = vim.fn.expand("~/.local/src/suckless") }) end)
        -- git
        vim.keymap.set("n", "<leader>gc", function() require("telescope.builtin").git_commits({}) end)
        vim.keymap.set("n", "<leader>gs", function() require("telescope.builtin").git_status({}) end)
        -- search
        vim.keymap.set("n", "<leader>sb", function() require("telescope.builtin").current_buffer_fuzzy_find({}) end)
        vim.keymap.set("n", "<leader>sc", function() require("telescope.builtin").commands({}) end)
        vim.keymap.set("n", "<leader>sch", function() require("telescope.builtin").command_history({}) end)
        vim.keymap.set("n", "<leader>co", function() require("telescope.builtin").colorscheme({}) end)
        vim.keymap.set("n", "<leader>sd", function() require("telescope.builtin").diagnostics({}) end)
        vim.keymap.set("n", "<leader>sg", function() require("telescope.builtin").live_grep({}) end)
        vim.keymap.set("n", "<leader>sG", function() require("telescope.builtin").grep_string({}) end)
        vim.keymap.set("n", "<leader>sh", function() require("telescope.builtin").help_tags({}) end)
        vim.keymap.set("n", "<leader>sk", function() require("telescope.builtin").keymaps({}) end)
        vim.keymap.set("n", "<leader>sm", function() require("telescope.builtin").marks({}) end)
        vim.keymap.set("n", "<leader>sM", function() require("telescope.builtin").man_pages({}) end)
        vim.keymap.set("n", "<leader>so", function() require("telescope.builtin").vim_options({}) end)
        vim.keymap.set("n", "<leader>sr", function() require("telescope.builtin").registers({}) end)
        -- lsp
        vim.keymap.set("n", "gR", function() require("telescope.builtin").lsp_references({}) end)
        vim.keymap.set("n", "gd", function() require("telescope.builtin").lsp_definitions({}) end)

        vim.keymap.set("n", "<leader>sw", function()
            local word = vim.fn.expand("<cword>")
            require("telescope.builtin").grep_string({ search = word })
        end)
        vim.keymap.set("n", "<leader>sW", function()
            local word = vim.fn.expand("<cWORD>")
            require("telescope.builtin").grep_string({ search = word })
        end)
    end
}
