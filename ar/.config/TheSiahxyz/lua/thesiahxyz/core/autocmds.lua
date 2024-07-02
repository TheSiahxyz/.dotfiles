local function augroup(name)
    return vim.api.nvim_create_augroup("thesiahxyz_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- Highlight on yank
autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- resize splits if window got resized
autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].thesiahxyz_last_loc then
            return
        end
        vim.b[buf].thesiahxyz_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- close some filetypes with <q>
autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "PlenaryTestPopup",
        "help",
        "lspinfo",
        "notify",
        "qf",
        "query",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "neotest-output",
        "checkhealth",
        "neotest-summary",
        "neotest-output-panel",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- make it easier to close man-files when opened inline
autocmd("FileType", {
    group = augroup("man_unlisted"),
    pattern = { "man" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
    end,
})

-- wrap and check for spell in text filetypes
autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

-- Fix conceallevel for json files
autocmd({ "FileType" }, {
    group = augroup("json_conceal"),
    pattern = { "json", "jsonc", "json5" },
    callback = function()
        vim.opt_local.conceallevel = 0
    end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
    group = augroup("auto_create_dir"),
    callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- Automatically deletes all trailing whitespace and newlines at end of file on save. & reset cursor position
autocmd("BufWritePre", {
    group = augroup("file_save"),
    pattern = "*",
    callback = function()
        -- Remove trailing spaces
        vim.cmd([[ %s/\s\+$//e ]])
        -- Remove trailing newlines
        vim.cmd([[ %s/\n\+\%$//e ]])
    end,
})

autocmd("BufWritePre", {
    group = augroup("file_save"),
    pattern = "*.[ch]",
    callback = function()
        -- Add a trailing newline for C files
        vim.cmd([[ %s/\%$/\r/e ]])
    end,
})

autocmd("BufWritePre", {
    group = augroup("file_save"),
    pattern = "*neomutt*",
    callback = function()
        -- Correct email signature delimiter in neomutt files
        vim.cmd([[ %s/^--$/-- /e ]])
    end,
})

autocmd("LspAttach", {
    group = augroup("lsp_attach"),
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gD", function()
            vim.lsp.buf.definition()
        end, opts)
        vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover()
        end, opts)
        vim.keymap.set("n", "<leader>vws", function()
            vim.lsp.buf.workspace_symbol()
        end, opts)
        vim.keymap.set("n", "<leader>vd", function()
            vim.diagnostic.open_float()
        end, opts)
        vim.keymap.set("n", "<leader>vca", function()
            vim.lsp.buf.code_action()
        end, opts)
        vim.keymap.set("n", "<leader>vrr", function()
            vim.lsp.buf.references()
        end, opts)
        vim.keymap.set("n", "<leader>vrn", function()
            vim.lsp.buf.rename()
        end, opts)
        vim.keymap.set("i", "<leader>vh", function()
            vim.lsp.buf.signature_help()
        end, opts)
        vim.keymap.set("n", "[d", function()
            vim.diagnostic.goto_next()
        end, opts)
        vim.keymap.set("n", "]d", function()
            vim.diagnostic.goto_prev()
        end, opts)
    end,
})

-- Save file as sudo on files that require root permission
vim.api.nvim_create_user_command("SudoWrite", function()
    vim.cmd("write !sudo tee % >/dev/null")
    vim.cmd("edit!")
end, {})
vim.api.nvim_create_user_command("SudoWritequit", function()
    vim.cmd("write !sudo tee % >/dev/null")
    vim.cmd("edit!")
    vim.cmd("quit!")
end, {})

-- Enable Goyo by default for mutt writing
local goyo_group = vim.api.nvim_create_augroup("GoyoForMutt", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "/tmp/neomutt*",
    group = goyo_group,
    callback = function()
        vim.g.goyo_width = 80
        vim.cmd("Goyo")
        vim.cmd("set bg=light")
        vim.cmd("set linebreak")
        vim.cmd("set wrap")
        vim.cmd("set textwidth=0")
        vim.cmd("set wrapmargin=0")
        vim.cmd("colorscheme seoul256")
        vim.api.nvim_buf_set_keymap(
            0,
            "n",
            "<leader>gx",
            ":Goyo|x!<CR>",
            { noremap = true, silent = true, desc = "Goyo Quit" }
        )
        vim.api.nvim_buf_set_keymap(
            0,
            "n",
            "<leader>gq",
            ":Goyo|q!<CR>",
            { noremap = true, silent = true, desc = "Goyo Abort" }
        )
    end,
})

-- Vimwiki
-- Ensure files are read with the desired filetype
vim.g.vimwiki_ext2syntax = {
    [".Rmd"] = "markdown",
    [".rmd"] = "markdown",
    [".md"] = "markdown",
    [".markdown"] = "markdown",
    [".mdown"] = "markdown",
}
-- Set up Vimwiki list
vim.g.vimwiki_list = { {
    path = vim.fn.expand("~/.local/share/vimwiki"),
    syntax = "markdown",
    ext = ".md",
} }
-- Markdown for specific files and directories
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "/tmp/calcurse*", "~/.calcurse/notes/*" },
    command = "set filetype=markdown",
})

-- Groff for specific file extensions
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.ms", "*.me", "*.mom", "*.man" },
    command = "set filetype=groff",
})

-- TeX for .tex files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.tex" },
    command = "set filetype=tex",
})

-- When shortcut files are updated, renew bash and lf configs with new material:
local config_group = vim.api.nvim_create_augroup("ConfigUpdate", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "bm-files", "bm-dirs" },
    group = config_group,
    callback = function()
        -- Execute the 'shortcuts' shell command
        local result = vim.fn.system("shortcuts")
        -- Check if the 'shortcuts' command was successful
        if vim.v.shell_error == 0 then
            -- Display a success message in Neovim
            vim.api.nvim_echo({ { "shortcuts updated", "None" } }, true, {})
        else
            -- Display an error message if the 'shortcuts' command fails
            vim.api.nvim_echo({ { "failed to update shortcuts: " .. result, "ErrorMsg" } }, true, {})
        end
    end,
})

-- Run xrdb whenever Xdefaults or Xresources are updated.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "Xresources", "Xdefaults", "xresources", "xdefaults" },
    group = config_group,
    callback = function()
        vim.bo.filetype = "xdefaults"
    end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "Xresources", "Xdefaults", "xresources", "xdefaults" },
    group = config_group,
    callback = function()
        vim.cmd("!xrdb %")
    end,
})

-- Recompile dwmblocks on config edit.
local home = os.getenv("HOME") -- Gets the home directory
local dwmblocks_path = home .. "/.local/src/suckless/dwmblocks/config.h"
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = dwmblocks_path,
    group = vim.api.nvim_create_augroup("DwmblocksConfigGroup", { clear = true }),
    callback = function()
        vim.cmd(
            "!cd "
            .. home
            .. "/.local/src/suckless/dwmblocks/ && sudo make install && { killall -q dwmblocks; setsid -f dwmblocks; }"
        )
    end,
})

-- Autocommand group for DWM
vim.api.nvim_create_augroup("DwmConfigGroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = home .. "/.local/src/suckless/dwm/config.h",
    group = "DwmConfigGroup",
    callback = function()
        vim.cmd("!extractkeys")
    end,
})

-- Autocommand group for ST
vim.api.nvim_create_augroup("StConfigGroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = home .. "/.local/src/suckless/st/config.h",
    group = "StConfigGroup",
    callback = function()
        vim.cmd("!extractkeys")
    end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufEnter" }, {
    pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
    callback = function()
        local suckless_path = vim.fn.expand("~/.local/src"):gsub("/+$", "")
        local file_path = vim.fn.expand("%:p"):gsub("/+$", "")
        if file_path == suckless_path or file_path:find("^" .. suckless_path .. "/") then
            vim.b.autoformat = false
        end
    end,
})
