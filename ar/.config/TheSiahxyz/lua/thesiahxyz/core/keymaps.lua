-- Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to last buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd!<cr>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New buffer" })
vim.keymap.set("n", "<C-s>", ":w<cr>", { desc = "Save current buffer" })
vim.keymap.set({ "n", "v" }, "<leader>wq", "<cmd>wq<cr>", { desc = "Save current buffer and quit" })
vim.keymap.set({ "n", "v" }, "<leader>WQ", "<cmd>wqa<cr>", { desc = "Save all buffers and quit" })
vim.keymap.set({ "n", "v" }, "<leader>qq", "<cmd>q!<cr>", { desc = "Force quit" })
vim.keymap.set({ "n", "v" }, "<leader>QQ", "<cmd>qa!<cr>", { desc = "Force quit all" })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear search highlights" })

-- Copy
vim.keymap.set({ "i", "n" }, "<leader>cp", function()
	local filename = vim.fn.expand("%") -- Get the current filename
	local file_root = vim.fn.expand("%:r") -- Get the file root (without extension)
	local file_ext = vim.fn.expand("%:e") -- Get the file extension
	local new_filename = file_root .. "_copied" -- Start with the base for new filename
	local num = 1
	while vim.fn.filereadable(new_filename .. "." .. file_ext) == 1 do
		new_filename = file_root .. "_copied_" .. num
		num = num + 1
	end
	new_filename = new_filename .. "." .. file_ext
	local cmd = "cp " .. filename .. " " .. new_filename
	local confirm = vim.fn.input("Are you sure you want to copy " .. filename .. "? (y/n): ")
	if confirm:lower() == "y" then
		vim.cmd("silent !" .. cmd)
		vim.cmd("silent edit " .. new_filename)
	end
end, { desc = "Copy current file" })
vim.keymap.set(
	"n",
	"<leader>cP",
	':let @+ = expand("%:p")<cr>:lua print("Copied path to: " .. vim.fn.expand("%:p"))<cr>',
	{ desc = "Copy current file name and path", silent = false }
)

-- Remove
vim.keymap.set("n", "<leader>rm", function()
	local filename = vim.fn.expand("%")
	if vim.fn.filereadable(filename) == 1 then
		local confirm = vim.fn.input("Are you sure you want to delete " .. filename .. "? (y/n): ")
		if confirm:lower() == "y" then
			vim.cmd("silent !rm " .. filename)
			vim.cmd("bd!")
		end
	end
end, { desc = "Remove current file" })

-- Disable
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable q command" })

-- Explore
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>es", vim.cmd.Sex, { desc = "Open file explorer in a horizontal split" })
vim.keymap.set("n", "<leader>ev", vim.cmd.Vex, { desc = "Open file explorer in a vertical split" })
vim.keymap.set("n", "<leader>qe", function()
	if vim.bo.filetype == "netrw" then
		vim.cmd("bd")
	end
end, { desc = "Close explorer (netrw)" })

-- Highlights under cursor
vim.keymap.set("n", "<leader>ip", vim.show_pos, { desc = "Inspect position" })

-- Remap Default
vim.keymap.set("n", "ㅑ", "i", { desc = "Insert mode" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape to normal mode" })
vim.keymap.set("i", "<C-c>", "<esc>", { desc = "Escape to normal mode" })
vim.keymap.set("i", "<C-a>", "<esc>I", { desc = "Insert at beginning of line" })
vim.keymap.set("i", "<C-e>", "<end>", { desc = "Move to end of line" })
vim.keymap.set("i", "<C-h>", "<left>", { desc = "Move left" })
vim.keymap.set("i", "<C-l>", "<right>", { desc = "Move right" })
vim.keymap.set("i", "<C-j>", "<down>", { desc = "Move down" })
vim.keymap.set("i", "<C-k>", "<up>", { desc = "Move up" })
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
	"<down>",
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
	"<up>",
	"v:count == 0 ? 'gk' : 'k'",
	{ expr = true, silent = true, desc = "Move up (visual line)" }
)
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and stay in visual mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and stay in visual mode" })
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line down in visual mode" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move line up in visual mode" })
vim.keymap.set("n", "sl", "vg_", { desc = "Select to end of line" })
vim.keymap.set("n", "sp", "ggVGp", { desc = "Select all and paste" })
vim.keymap.set("n", "sv", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "gp", "`[v`]", { desc = "Select pasted text" })
vim.keymap.set("n", "ss", ":s/\\v", { desc = "Search and replace on line" })
vim.keymap.set("n", "SS", ":%s/\\v", { desc = "Search and replace in file" })
vim.keymap.set("v", "<leader><C-s>", ":s/\\%V", { desc = "Search only in visual selection using %V atom" })
vim.keymap.set("v", "<C-r>", '"hy:%s/\\v<C-r>h//g<left><left>', { desc = "Change selection" })

-- Cd
vim.keymap.set("n", "<leader>cd", ":cd %:p:h<cr>:pwd<cr>", { desc = "Go to current file path" })
vim.keymap.set("n", "<leader>cD", function()
	local realpath = vim.fn.systemlist("readlink -f " .. vim.fn.shellescape(vim.fn.expand("%:p")))[1]
	vim.cmd("silent cd " .. vim.fn.fnameescape(vim.fn.fnamemodify(realpath, ":h")))
	vim.cmd("pwd")
end, { desc = "Go to real path of current file" })
vim.keymap.set("n", "<leader>..", ":cd ..<cr>:pwd<cr>", { desc = "Go to current file path" })

-- Check Health
vim.keymap.set("n", "<leader>ch", ":checkhealth<cr>", { desc = "Check neovim health" })

-- Cut, Yank & Paste
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader><C-y>", ":%y<cr>", { desc = "Yank current file to clipboard" })
vim.keymap.set("n", "<leader>p", [["+p]], { desc = "Paste over clipboard" })
vim.keymap.set("n", "<leader>P", [["+P]], { desc = "Paste over clipboard" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over and preserve clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["+d]], { desc = "Delete without store to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>D", [["_d]], { desc = "Delete and yank to clipboard" })
vim.keymap.set("n", "<leader><C-d>", ":%d_<cr>", { desc = "Delete all to black hole register" })

-- Diagnostic
local diagnostic_goto = function(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end
-- vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Previous diagnostic" })
-- vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>[e", diagnostic_goto(false, "ERROR"), { desc = "Previous error" })
vim.keymap.set("n", "<leader>]e", diagnostic_goto(true, "ERROR"), { desc = "Next error" })
vim.keymap.set("n", "<leader>[w", diagnostic_goto(false, "WARN"), { desc = "Previous warning" })
vim.keymap.set("n", "<leader>]w", diagnostic_goto(true, "WARN"), { desc = "Next warning" })
vim.keymap.set("n", "<leader>od", vim.diagnostic.open_float, { desc = "Open diagnostic message" })
vim.keymap.set("n", "<leader>la", vim.diagnostic.setloclist, { desc = "Add diagnostics to location list" })

-- Files
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "Open new buffer" })

-- Fix List & Trouble
-- vim.keymap.set("n", "[l", "<cmd>lprev<cr>zz", { desc = "Previous location list item" })
-- vim.keymap.set("n", "]l", "<cmd>lnext<cr>zz", { desc = "Next location list item" })
-- vim.keymap.set("n", "[q", "<cmd>cprev<cr>zz", { desc = "Previous quickfix item" })
-- vim.keymap.set("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix item" })
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
vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make file executable" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Scripts
vim.api.nvim_set_keymap(
	"n",
	"<leader>rr",
	':w!<cr>:!compiler "%:p"<cr>',
	{ noremap = true, silent = true, desc = "Run compiler" }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>op",
	":!output <C-r>%<cr><cr>",
	{ noremap = true, silent = true, desc = "Run compiler" }
)

-- Source
vim.keymap.set("n", "<leader>S", function()
	vim.cmd("so")
end, { desc = "Source current file" })

-- Sudo
vim.keymap.set("n", "<leader>ww", "<cmd>SudoWrite<cr><cr>", { silent = true, desc = "Save file with sudo" })
vim.keymap.set("n", "<leader>wq", "<cmd>SudoWritequit<cr>", { silent = true, desc = "Save and quit with sudo" })

-- Terminal
vim.keymap.set("n", "<leader>s|", "<cmd>vsplit | term<cr>i", { desc = "Open vertical terminal split" })
vim.keymap.set("n", "<leader>s-", "<cmd>split | term<cr>i", { desc = "Open horizontal terminal split" })
vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })
vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Move to left window" })
vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Move to window below" })
vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Move to window above" })
vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Move to right window" })
vim.keymap.set("t", "<C-_>", "<cmd>close<cr>", { desc = "Close terminal" })

-- Tmux
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to window above" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right window" })
vim.keymap.set(
	"n",
	"<leader>tm",
	"<cmd>silent !~/.config/tmux/plugins/tmux-fzf/scripts/session.sh<cr>",
	{ desc = "Find tmux session" }
)

-- Lazy
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Open lazy plugin manager" })

-- Mason
vim.keymap.set("n", "<leader>M", "<cmd>Mason<cr>", { desc = "Open mason" })

-- Word Definition
vim.api.nvim_set_keymap(
	"n",
	"<leader>k",
	":lua WordDefinition(vim.fn.expand('<cword>'))<cr>",
	{ noremap = true, silent = true, desc = "Word definition" }
)

-- Ascii
vim.keymap.set("n", "<leader>c1", ":.!toilet -w 200 -f bfraktur<cr>", { desc = "Ascii art bfraktur" })
vim.keymap.set("n", "<leader>c2", ":.!toilet -w 200 -f emboss<cr>", { desc = "Ascii art emboss" })
vim.keymap.set("n", "<leader>c3", ":.!toilet -w 200 -f emboss2<cr>", { desc = "Ascii art emboss2" })
vim.keymap.set("n", "<leader>c4", ":.!toilet -w 200 -f future<cr>", { desc = "Ascii art future" })
vim.keymap.set("n", "<leader>c5", ":.!toilet -w 200 -f pagga<cr>", { desc = "Ascii art pagga" })
vim.keymap.set("n", "<leader>c6", ":.!toilet -w 200 -f wideterm<cr>", { desc = "Ascii art wideterm" })
