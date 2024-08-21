-- Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Buffers
vim.keymap.set("n", "<S-h>", "<CMD>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<CMD>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bb", "<CMD>e #<CR>", { desc = "Switch to last buffer" })
vim.keymap.set("n", "<leader>bd", "<CMD>bd!<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>bn", "<CMD>enew<CR>", { desc = "New buffer" })
vim.keymap.set("n", "[b", "<CMD>e #<CR>", { desc = "Switch to last buffer" })

-- Clear search with <ESC>
vim.keymap.set({ "i", "n" }, "<ESC>", "<CMD>noh<CR><ESC>", { desc = "Clear search highlights" })

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
		vim.cmd("!" .. cmd)
		vim.cmd("edit " .. new_filename)
	end
end, { desc = "Copy current file" })
vim.keymap.set(
	"n",
	"<leader>cP",
	':let @+ = expand("%:p")<CR>:lua print("Copied path to: " .. vim.fn.expand("%:p"))<CR>',
	{ desc = "Copy current file name and path", silent = false }
)

-- Remove
vim.keymap.set("n", "<leader>rm", function()
	local filename = vim.fn.expand("%")
	if vim.fn.filereadable(filename) == 1 then
		local confirm = vim.fn.input("Are you sure you want to delete " .. filename .. "? (y/n): ")
		if confirm:lower() == "y" then
			vim.cmd("!rm " .. filename)
			vim.cmd("bd!")
		end
	end
end, { desc = "Remove current file" })

-- Disable
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable q command" })

-- Explore
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>q", function()
	if vim.bo.filetype == "netrw" then
		vim.cmd("bd")
	end
end, { desc = "Close netrw buffer" })

-- Highlights under cursor
vim.keymap.set("n", "<leader>h", vim.show_pos, { desc = "Inspect position" })

-- Remap Default
vim.keymap.set("i", "jk", "<ESC>", { desc = "Escape to normal mode" })
vim.keymap.set("i", "<C-c>", "<ESC>", { desc = "Escape to normal mode" })
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
vim.keymap.set("n", "sl", "vg_", { desc = "Select to end of line" })
vim.keymap.set("n", "sp", "ggVGp", { desc = "Select all and paste" })
vim.keymap.set("n", "sv", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "gp", "`[v`]", { desc = "Select pasted text" })
vim.keymap.set("n", "ss", ":s/\\v", { desc = "Search and replace on line" })
vim.keymap.set("n", "SS", ":%s/\\v", { desc = "Search and replace in file" })
vim.keymap.set("v", "<leader><C-s>", ":s/\\%V", { desc = "Search only in visual selection using %V atom" })
vim.keymap.set("v", "<C-r>", '"hy:%s/\\v<C-r>h//g<left><left>', { desc = "Change selection" })

-- Check Health
vim.keymap.set("n", "<leader>ch", ":checkhealth<CR>", { desc = "Check neovim health" })

-- Cut, Yank & Paste
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader><C-y>", ":%y<CR>", { desc = "Yank current file to clipboard" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over and preserve clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["+d]], { desc = "Delete and yank to clipboard" })
vim.keymap.set("n", "<leader>D", [["+D]], { desc = "Delete line without saving to clipboard" })
vim.keymap.set("n", "<leader><C-d>", ":%d_<CR>", { desc = "Delete all to black hole register" })

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
vim.keymap.set("n", "<leader>fn", "<CMD>enew<CR>", { desc = "Open new buffer" })

-- Fix List & Trouble
vim.keymap.set("n", "[l", "<CMD>lprev<CR>zz", { desc = "Previous location list item" })
vim.keymap.set("n", "]l", "<CMD>lnext<CR>zz", { desc = "Next location list item" })
vim.keymap.set("n", "[q", "<CMD>cprev<CR>zz", { desc = "Previous quickfix item" })
vim.keymap.set("n", "]q", "<CMD>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set(
	"n",
	"<leader>/",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Search and replace word under cursor" }
)
vim.keymap.set("n", "<leader>ol", "<CMD>lopen<CR>", { desc = "Open location list" })
vim.keymap.set("n", "<leader>oq", "<CMD>copen<CR>", { desc = "Open quickfix list" })

-- Formats
vim.keymap.set("n", "<leader>cF", vim.lsp.buf.format, { desc = "Format buffer by default lsp" })

-- Health
vim.keymap.set("n", "<leader>ch", ":checkhealth<CR>", { desc = "Check neovim health" })

-- Keywordprg
vim.keymap.set("n", "<leader>K", "<CMD>norm! K<CR>", { desc = "Look up keyword" })

-- Lines
vim.keymap.set("n", "<A-,>", "<CMD>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<A-.>", "<CMD>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("i", "<A-,>", "<ESC><CMD>m .-2<CR>==gi", { desc = "Move line up in insert mode" })
vim.keymap.set("i", "<A-.>", "<ESC><CMD>m .+1<CR>==gi", { desc = "Move line down in insert mode" })
vim.keymap.set("v", "<A-,>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })
vim.keymap.set("v", "<A-.>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })

-- Ownerships
vim.keymap.set("n", "<leader>cx", "<CMD>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<CMD>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<CMD>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<CMD>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<CMD>vertical resize +2<CR>", { desc = "Increase window width" })

-- Scripts
vim.api.nvim_set_keymap(
	"n",
	"<leader>rr",
	':w!<CR>:!compiler "%:p"<CR>',
	{ noremap = true, silent = true, desc = "Run compiler" }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>op",
	":!output <C-r>%<CR><CR>",
	{ noremap = true, silent = true, desc = "Run compiler" }
)

-- Source
vim.keymap.set("n", "<leader>.", function()
	vim.cmd("so")
end, { desc = "Source current file" })

-- Sudo
vim.keymap.set("n", "<leader>ww", "<CMD>SudoWrite<CR><CR>", { silent = true, desc = "Save file with sudo" })
vim.keymap.set("n", "<leader>wq", "<CMD>SudoWritequit<CR>", { silent = true, desc = "Save and quit with sudo" })

-- Terminal
vim.keymap.set("n", "<leader>s|", "<CMD>vsplit | term<CR>i", { desc = "Open vertical terminal split" })
vim.keymap.set("n", "<leader>s-", "<CMD>split | term<CR>i", { desc = "Open horizontal terminal split" })
vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Escape terminal mode" })
vim.keymap.set("t", "<C-h>", "<CMD>wincmd h<CR>", { desc = "Move to left window" })
vim.keymap.set("t", "<C-j>", "<CMD>wincmd j<CR>", { desc = "Move to window below" })
vim.keymap.set("t", "<C-k>", "<CMD>wincmd k<CR>", { desc = "Move to window above" })
vim.keymap.set("t", "<C-l>", "<CMD>wincmd l<CR>", { desc = "Move to right window" })
vim.keymap.set("t", "<C-/>", "<CMD>close<CR>", { desc = "Close terminal" })

-- Tmux
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to window above" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right window" })
vim.keymap.set(
	"n",
	"<leader>tm",
	"<CMD>silent !~/.config/tmux/plugins/tmux-fzf/scripts/session.sh<CR>",
	{ desc = "Find tmux session" }
)

-- Lazy
vim.keymap.set("n", "<leader>lz", "<CMD>Lazy<CR>", { desc = "Open lazy plugin manager" })

-- Mason
vim.keymap.set("n", "<leader>ms", "<CMD>Mason<CR>", { desc = "Open mason" })

-- Word Definition
vim.api.nvim_set_keymap(
	"n",
	"<leader>k",
	":lua WordDefinition(vim.fn.expand('<cword>'))<CR>",
	{ noremap = true, silent = true, desc = "Word definition" }
)

-- Ascii
vim.keymap.set("n", "<leader>c1", ":.!toilet -w 200 -f bfraktur<CR>", { desc = "Ascii art bfraktur" })
vim.keymap.set("n", "<leader>c2", ":.!toilet -w 200 -f emboss<CR>", { desc = "Ascii art emboss" })
vim.keymap.set("n", "<leader>c3", ":.!toilet -w 200 -f emboss2<CR>", { desc = "Ascii art emboss2" })
vim.keymap.set("n", "<leader>c4", ":.!toilet -w 200 -f future<CR>", { desc = "Ascii art future" })
vim.keymap.set("n", "<leader>c5", ":.!toilet -w 200 -f pagga<CR>", { desc = "Ascii art pagga" })
vim.keymap.set("n", "<leader>c6", ":.!toilet -w 200 -f wideterm<CR>", { desc = "Ascii art wideterm" })
