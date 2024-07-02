return {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "VeryLazy",
    opts = {
        draw = {
            animation = function()
                return 0
            end,
        },
        options = { try_as_border = true },
        symbol = "│",
    },
    init = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "help",
                "Trouble",
                "trouble",
                "lazy",
                "mason",
            },
            callback = function()
                vim.b.miniindentscope_disable = true
            end,
        })
    end,
}
