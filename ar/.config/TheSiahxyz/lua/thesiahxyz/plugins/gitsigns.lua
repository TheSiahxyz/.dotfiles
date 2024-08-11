return {
    "lewis6991/gitsigns.nvim",
    opts = {
        signs = {
            add = { text = "▎" },
            change = { text = "▎" },
            delete = { text = "" },
            topdelete = { text = "" },
            changedelete = { text = "▎" },
            untracked = { text = "▎" },
        },
        signs_staged = {
            add = { text = "▎" },
            change = { text = "▎" },
            delete = { text = "" },
            topdelete = { text = "" },
            changedelete = { text = "▎" },
        },
        on_attach = function(buffer)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
            end

            -- stylua: ignore start
            map("n", "]h", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "]c", bang = true })
                else
                    gs.nav_hunk("next")
                end
            end, "Next hunk")
            map("n", "[h", function()
                if vim.wo.diff then
                    vim.cmd.normal({ "[c", bang = true })
                else
                    gs.nav_hunk("prev")
                end
            end, "Previous hunk")
            map("n", "]H", function() gs.nav_hunk("last") end, "Last hunk")
            map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")
            map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
            map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
            map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
            map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
            map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
            map("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk inline")
            map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
            map("n", "<leader>gB", function() gs.blame() end, "Blame buffer")
            map("n", "<leader>gd", gs.diffthis, "Diff this")
            map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff this ~")
            -- map("n", "<leader>gD", function() gs.diffthis("@") end, "Diff this @")
            map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns select hunk")
            map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
            map("n", "<leader>tD", gs.toggle_deleted, "Toggle delete")
        end,
    },
}
