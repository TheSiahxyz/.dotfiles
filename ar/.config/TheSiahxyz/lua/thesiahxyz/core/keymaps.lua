-- Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to last buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to last buffer" })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear search highlights" })

-- Disable
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable q command" })

-- Explore
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open file explorer" })

-- Highlights under cursor
vim.keymap.set("n", "<leader>h", vim.show_pos, { desc = "Inspect position" })

-- Remap Default
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape to normal mode" })
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape to normal mode" })
vim.keymap.set("i", "<C-i>", "<ESC>I", { desc = "Insert at beginning of line" })
vim.keymap.set("i", "<C-a>", "<End>", { desc = "Move to end of line" })
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move left" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move right" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move down" })
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move up" })
vim.keymap.set("n", "<C-c>", ":", { desc = "Enter command mode" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result and center" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result in visual mode" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result in operator-pending mode" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Previous search result and center" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Previous search result in visual mode" })
vim.keymap.set(
	"o",
	"N",
	"'nN'[v:searchforward]",
	{ expr = true, desc = "Previous search result in operator-pending mode" }
)
vim.keymap.set("n", "x", '"_x', { desc = "Delete character without yanking" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "<C-b>", "<C-b>zz", { desc = "Page up and center" })
vim.keymap.set("n", "<C-f>", "<C-f>zz", { desc = "Page down and center" })
vim.keymap.set(
	{ "n", "x" },
	"j",
	"v:count == 0 ? 'gj' : 'j'",
	{ expr = true, silent = true, desc = "Move down (visual line)" }
)
vim.keymap.set(
	{ "n", "x" },
	"<Down>",
	"v:count == 0 ? 'gj' : 'j'",
	{ expr = true, silent = true, desc = "Move down (visual line)" }
)
vim.keymap.set(
	{ "n", "x" },
	"k",
	"v:count == 0 ? 'gk' : 'k'",
	{ expr = true, silent = true, desc = "Move up (visual line)" }
)
vim.keymap.set(
	{ "n", "x" },
	"<Up>",
	"v:count == 0 ? 'gk' : 'k'",
	{ expr = true, silent = true, desc = "Move up (visual line)" }
)
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and stay in visual mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and stay in visual mode" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down in visual mode" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up in visual mode" })

-- Check Health
vim.keymap.set("n", "<leader>ch", ":checkhealth<cr>", { desc = "Check neovim health" })

-- Cut, Yank & Paste
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>dy", [["_d"+y]], { desc = "Delete and yank to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>dd", [["_d]], { desc = "Delete without saving to clipboard" })
vim.keymap.set("n", "<leader>D", [["_D]], { desc = "Delete line without saving to clipboard" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over and preserve clipboard" })

-- Diagnostic
local diagnostic_goto = function(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next diagnostic" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Previous error" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next error" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Previous warning" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next warning" })
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Open diagnostic message" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Add diagnostics to location list" })

-- Files
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "Open new buffer" })

-- Fix List & Trouble
vim.keymap.set("n", "[l", "<cmd>lprev<CR>zz", { desc = "Previous location list item" })
vim.keymap.set("n", "]l", "<cmd>lnext<CR>zz", { desc = "Next location list item" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set(
	"n",
	"<leader>/",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Search and replace word under cursor" }
)
vim.keymap.set("n", "<leader>ol", "<cmd>lopen<cr>", { desc = "Open location list" })
vim.keymap.set("n", "<leader>oq", "<cmd>copen<cr>", { desc = "Open quickfix list" })

-- Formats
vim.keymap.set("n", "<leader>cF", vim.lsp.buf.format, { desc = "Format buffer by default lsp" })

-- Health
vim.keymap.set("n", "<leader>ch", ":checkhealth<cr>", { desc = "Check neovim health" })

-- Keywordprg
vim.keymap.set("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Look up keyword" })

-- Lines
vim.keymap.set("n", "<A-,>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("n", "<A-.>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("i", "<A-,>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up in insert mode" })
vim.keymap.set("i", "<A-.>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down in insert mode" })
vim.keymap.set("v", "<A-,>", ":m '<-2<cr>gv=gv", { desc = "Move selected lines up" })
vim.keymap.set("v", "<A-.>", ":m '>+1<cr>gv=gv", { desc = "Move selected lines down" })

-- Ownerships
vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Scripts
vim.api.nvim_set_keymap(
	"n",
	"<leader>rr",
	':w!<CR>:!compiler "%:p"<CR>',
	{ noremap = true, silent = true, desc = "Run compiler" }
)

-- Source
vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end, { desc = "Source current file" })

-- Sudo
vim.keymap.set("n", "<leader>ww", "<cmd>SudoWrite<cr><cr>", { silent = true, desc = "Save file with sudo" })
vim.keymap.set("n", "<leader>wq", "<cmd>SudoWritequit<cr>", { silent = true, desc = "Save and quit with sudo" })

-- Terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })
vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Move to left window" })
vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Move to window below" })
vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Move to window above" })
vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Move to right window" })
vim.keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Close terminal" })
vim.keymap.set("t", "<c-_>", "<cmd>close<cr>", { desc = "Close terminal" })

-- Tmux
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to window above" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right window" })
vim.keymap.set(
	"n",
	"<leader>tm",
	"<cmd>silent !~/.config/tmux/plugins/tmux-fzf/scripts/session.sh<CR>",
	{ desc = "Find tmux session" }
)

-- Lazy
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Open lazy plugin manager" })

-- Mason
vim.keymap.set("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Open mason" })

-- Word Definition
vim.api.nvim_set_keymap(
	"n",
	"<leader>gd",
	":lua WordDefinition(vim.fn.expand('<cword>'))<CR>",
	{ noremap = true, silent = true, desc = "Get word definition" }
)

-- Ascii
vim.keymap.set("n","<leader>7",":.!toilet -w 200 -f bfraktur<CR>", { desc = "Ascii art standard" })
vim.keymap.set("n","<leader>8",":.!toilet -w 200 -f future<CR>", { desc = "Ascii art small" })
vim.keymap.set("n","<leader>9",":.!toilet -w 200 -f pagga<CR>", { desc = "Ascii art small" })
vim.keymap.set("n","<leader>0",":.!toilet -w 200 -f emboss<CR>", { desc = "Ascii art small" })
