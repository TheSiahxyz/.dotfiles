return {
    "echasnovski/mini.pairs",
    version = "*",
    event = "VeryLazy",
    config = function()
        require("mini.pairs").setup()
        vim.keymap.set("n", "<leader>up", function()
            vim.g.minipairs_disable = not vim.g.minipairs_disable
            if vim.g.minipairs_disable then
                LazyVim.warn("Disabled auto pairs", { title = "Option" })
            else
                LazyVim.info("Enabled auto pairs", { title = "Option" })
            end
        end)
    end,
}
