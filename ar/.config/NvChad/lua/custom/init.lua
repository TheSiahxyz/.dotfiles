-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

-- Visual Studio Code
if vim.g.vscode then
  -- Plug 'asvetliakov/vim-easymotion', has('nvim') ? {} : { 'on': [] }
  vim.cmd [[source $HOME/.config/nvim/vscode/settings.vim]]
  vim.cmd [[source $HOME/.config/nvim/vscode/easymotion-config.vim]]
end

vim.g.python3_host_prog = "/usr/bin/python3"
-- vim.g.loaded_python3_provider = 1

local opt = vim.opt
local api = vim.api

-- Background
-- opt.background = "dark"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append "unnamedplus"

-- Column
opt.colorcolumn = "110"

-- Disable persistent undo for files in /private directory
api.nvim_create_autocmd("BufReadPre", { pattern = "/private/*", command = "set noundofile" })

-- Indenting
opt.autoindent = true

-- line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)local
opt.relativenumber = true -- show relative line numbers
opt.scrolloff = 9

-- Swap file disable
opt.swapfile = false

-- Words
-- opt.iskeyword:append "-" -- consider string-string as whole word

-- Wrap
opt.wrap = false

-- Undo persistent enable for other files
opt.undofile = true
