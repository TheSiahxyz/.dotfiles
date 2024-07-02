return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
        menu = {
            width = vim.api.nvim_win_get_width(0) - 4,
        },
        settings = {
            save_on_toggle = true,
        },
    },
    keys = function()
        local keys = {
            {
                "<leader>a",
                function()
                    require("harpoon"):list():add()
                end,
            },
            {
                "<C-e>",
                function()
                    local harpoon = require("harpoon")
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end,
            },
            {
                "<C-p>",
                function()
                    require("harpoon"):list():prev()
                end,
            },
            {
                "<C-n>",
                function()
                    require("harpoon"):list():next()
                end,
            },
        }

        for i = 1, 5 do
            table.insert(keys, {
                "<leader>" .. i,
                function()
                    require("harpoon"):list():select(i)
                end,
            })

            table.insert(keys, {
                "<leader>h" .. i,
                function()
                    require("harpoon"):list():replace_at(i)
                end,
            })
        end
        return keys
    end,
}
