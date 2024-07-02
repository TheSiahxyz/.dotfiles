-- Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable
vim.keymap.set("n", "Q", "<nop>")

-- Expolore
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- Remap Default
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("i", "<C-i>", "<ESC>I")
vim.keymap.set("i", "<C-a>", "<End>")
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-l>", "<Right>")
vim.keymap.set("i", "<C-j>", "<Down>")
vim.keymap.set("i", "<C-k>", "<Up>")
vim.keymap.set("n", "<C-c>", ":")
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true })
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Check Health
vim.keymap.set("n", "<leader>ch", ":checkhealth<cr>")

-- Compiler
vim.api.nvim_set_keymap("n", "<leader>rr", ':w!<CR>:!compiler "%:p"<CR>', { noremap = true, silent = true })

-- Cut, Yank & Paste
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
vim.keymap.set("n", "<leader>D", [["_D]])
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Diagnostic
local diagnostic_goto = function(next, severity)
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function()
        go({ severity = severity })
    end
end
vim.keymap.set("n", "[d", diagnostic_goto(false))
vim.keymap.set("n", "]d", diagnostic_goto(true))
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"))
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"))
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"))
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"))
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist)

-- Files
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>")

-- Fix List & Trouble
vim.keymap.set("n", "<C-[>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<C-]>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<leader>[", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<leader>]", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>/", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>xl", "<cmd>lopen<cr>")
vim.keymap.set("n", "<leader>xq", "<cmd>copen<cr>")

-- Formats
vim.keymap.set("n", "<leader>cF", vim.lsp.buf.format)

-- Health
vim.keymap.set("n", "<leader>ch", ":checkhealth<cr>")

-- Keywordprg
vim.keymap.set("n", "<leader>K", "<cmd>norm! K<cr>")

-- Lines
vim.keymap.set("n", "<A-,>", "<cmd>m .-2<cr>==")
vim.keymap.set("n", "<A-.>", "<cmd>m .+1<cr>==")
vim.keymap.set("i", "<A-,>", "<esc><cmd>m .-2<cr>==gi")
vim.keymap.set("i", "<A-.>", "<esc><cmd>m .+1<cr>==gi")
vim.keymap.set("v", "<A-,>", ":m '<-2<cr>gv=gv")
vim.keymap.set("v", "<A-.>", ":m '>+1<cr>gv=gv")

-- Ownerships
vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true })

-- Source
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- Terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>")
vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>")
vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>")
vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>")
vim.keymap.set("t", "<C-/>", "<cmd>close<cr>")
vim.keymap.set("t", "<c-_>", "<cmd>close<cr>")

-- Tmux
vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !~/.config/tmux/plugins/tmux-fzf/scripts/session.sh<CR>")

-- Lazy
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>")

-- Mason
vim.keymap.set("n", "<leader>m", "<cmd>Mason<cr>")

-- Word Definition
vim.api.nvim_set_keymap(
    "n",
    "<leader>gd",
    ":lua WordDefinition(vim.fn.expand('<cword>'))<CR>",
    { noremap = true, silent = true }
)
