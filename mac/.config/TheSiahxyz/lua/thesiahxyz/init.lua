require("thesiahxyz.core.autocmds")
require("thesiahxyz.core.keymaps")
require("thesiahxyz.core.options")
require("thesiahxyz.core.lazy")

vim.cmd("let g:netrw_liststyle = 0")
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Plenary
function R(name)
    require("plenary.reload").reload_module(name)
end

-- Word Definition
function WordDefinition(input)
    local escaped_input = vim.fn.shellescape({input})
    local output = vim.fn.system("dict " .. escaped_input)
    local bufnr = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(output, "\n"))
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    vim.api.nvim_buf_set_option(bufnr, 'modified', false)
end

-- Source shortcuts from bm-files and bm-folders
local shortcuts_file = vim.fn.expand("~/.config/nvim/shortcuts.lua")
local file = io.open(shortcuts_file, "r")
if file then
    file:close()
    vim.cmd("silent! source " .. shortcuts_file)
end

