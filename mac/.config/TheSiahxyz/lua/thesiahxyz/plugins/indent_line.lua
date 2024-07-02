return {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    version = "3.5.4",
    main = "ibl",
    opts = {
        indent = {
            char = "│",
            tab_char = "│",
        },
        scope = { enabled = false },
        exclude = {
            filetypes = {
                "help",
                "Trouble",
                "trouble",
                "lazy",
                "mason",
            },
        },
    },
}
