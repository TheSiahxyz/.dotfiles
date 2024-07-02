-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- vim.g.autoformat = true
-- vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
-- vim.g.netrw_banner = 0
-- vim.g.netrw_mouse = 2

-- vim.opt.autowrite = true -- Enable auto write
vim.opt.backup = false -- creates a backup file
-- vim.opt.clipboard = "" -- "unnamedplus" -- Sync with system clipboard
vim.opt.cmdheight = 1
vim.opt.colorcolumn = "85"
-- vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.conceallevel = 1 -- default = 3, Hide * markup for bold and italic
-- vim.opt.confirm = true -- Confirm to save changes before exiting modified buffer
-- vim.opt.cursorline = true -- Enable highlighting of the current line
-- vim.opt.expandtab = true -- Use spaces instead of tabs
-- vim.opt.fileencoding = "utf-8"
vim.opt.hlsearch = true
-- vim.opt.formatoptions = "jcroqlnt" -- tcqj
-- vim.opt.grepformat = "%f:%l:%c:%m"
-- vim.opt.grepprg = "rg --vimgrep"
-- vim.opt.guifont = "monospace:h17"
-- vim.opt.ignorecase = true -- Ignore case
-- vim.opt.inccommand = "nosplit" -- preview incremental substitute
-- vim.opt.laststatus = 3 -- global statusline
-- vim.opt.list = true -- Show some invisible characters (tabs...
-- vim.opt.mouse = "a" -- Enable mouse mode
-- vim.opt.number = true -- Print line number
-- vim.opt.numberwidth = 4
-- vim.opt.pumblend = 10 -- Popup blend
-- vim.opt.pumheight = 10 -- Maximum number of entries in a popup
-- vim.opt.relativenumber = true -- Relative line numbers
vim.opt.ruler = false
vim.opt.scrolloff = 8 -- Lines of context
-- vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
-- vim.opt.shiftround = true -- Round indent
-- vim.opt.shiftwidth = 2 -- Size of an indent
-- vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.showcmd = false
-- vim.opt.showmode = false -- Dont show mode since we have a statusline
vim.opt.showtabline = 1
-- vim.opt.sidescrolloff = 8 -- Columns of context
-- vim.opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
-- vim.opt.smartcase = true -- Don't ignore case with capitals
-- vim.opt.smartindent = true -- Insert indents automatically
-- vim.opt.spelllang = { "en" }
-- vim.opt.splitbelow = true -- Put new windows below current
-- vim.opt.splitkeep = "screen"
-- vim.opt.splitright = true -- Put new windows right of current
vim.opt.swapfile = false
vim.opt.tabstop = 4 -- Number of spaces tabs count for
-- vim.opt.termguicolors = true -- True color support
-- vim.opt.timeoutlen = 300
vim.opt.title = false
-- vim.opt.undofile = true
-- vim.opt.undolevels = 10000
-- vim.opt.updatetime = 200 -- Save swap file and trigger CursorHold
-- vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
-- vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
-- vim.opt.winminwidth = 5 -- Minimum window width
-- vim.opt.wrap = false -- Disable line wrap
vim.opt.writebackup = false

vim.cmd("set whichwrap+=<,>,[,],h,l")
vim.cmd([[set iskeyword+=-]])

-- vim.opt.fillchars = {
--   foldopen = "",
--   foldclose = "",
--   -- fold = "⸱",
--   fold = " ",
--   foldsep = " ",
--   diff = "╱",
--   eob = " ",
-- }
--
-- if vim.fn.has("nvim-0.10") == 1 then
--   vim.opt.smoothscroll = true
-- end
--
-- -- Folding
-- vim.opt.foldlevel = 99
-- vim.opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
--
-- if vim.fn.has("nvim-0.9.0") == 1 then
--   vim.opt.statuscolumn = [[%!v:lua.require'lazyvim.util'.ui.statuscolumn()]]
-- end
--
-- -- HACK: causes freezes on <= 0.9, so only enable on >= 0.10 for now
-- if vim.fn.has("nvim-0.10") == 1 then
--   vim.opt.foldmethod = "expr"
--   vim.opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
-- else
--   vim.opt.foldmethod = "indent"
-- end
--
-- vim.o.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"
--
-- -- Fix markdown indentation settings
-- vim.g.markdown_recommended_style = 0
