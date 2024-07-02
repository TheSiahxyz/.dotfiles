return {
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            on_attach = function(bufnr)
                local gitsigns = require "gitsigns"

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "]c", function()
                    if vim.wo.diff then
                        vim.cmd.normal { "]c", bang = true }
                    else
                        gitsigns.nav_hunk "next"
                    end
                end)

                map("n", "[c", function()
                    if vim.wo.diff then
                        vim.cmd.normal { "[c", bang = true }
                    else
                        gitsigns.nav_hunk "prev"
                    end
                end)

                -- Actions
                -- visual mode
                map("v", "<leader>gs", function()
                    gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
                end)
                map("v", "<leader>gr", function()
                    gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
                end)
                -- normal mode
                map("n", "<leader>gs", gitsigns.stage_hunk)
                map("n", "<leader>gr", gitsigns.reset_hunk)
                map("n", "<leader>gS", gitsigns.stage_buffer)
                map("n", "<leader>gu", gitsigns.undo_stage_hunk)
                map("n", "<leader>gR", gitsigns.reset_buffer)
                map("n", "<leader>gp", gitsigns.preview_hunk)
                map("n", "<leader>gb", gitsigns.blame_line)
                map("n", "<leader>gd", gitsigns.diffthis)
                map("n", "<leader>gD", function()
                    gitsigns.diffthis "@"
                end)
                -- Toggles
                map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
                map("n", "<leader>tD", gitsigns.toggle_deleted)
            end,
        },
    },
}
