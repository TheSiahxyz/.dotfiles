-- Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Go to Previous Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Go to Next Buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Last Buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Last Buffer" })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear Search Highlights" })

-- Disable
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Q Command" })

-- Explore
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open File Explorer" })

-- Highlights under cursor
vim.keymap.set("n", "<leader>h", vim.show_pos, { desc = "Inspect Position" })

-- Remap Default
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape to Normal Mode" })
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape to Normal Mode" })
vim.keymap.set("i", "<C-i>", "<ESC>I", { desc = "Insert at Beginning of Line" })
vim.keymap.set("i", "<C-a>", "<End>", { desc = "Move to End of Line" })
vim.keymap.set("i", "<C-h>", "<Left>", { desc = "Move Left" })
vim.keymap.set("i", "<C-l>", "<Right>", { desc = "Move Right" })
vim.keymap.set("i", "<C-j>", "<Down>", { desc = "Move Down" })
vim.keymap.set("i", "<C-k>", "<Up>", { desc = "Move Up" })
vim.keymap.set("n", "<C-c>", ":", { desc = "Enter Command Mode" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join Lines and Keep Cursor Position" })
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result and Center" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result in Visual Mode" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result in Operator-Pending Mode" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Previous Search Result and Center" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Previous Search Result in Visual Mode" })
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Previous Search Result in Operator-Pending Mode" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete Character Without Yanking" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down and Center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up and Center" })
vim.keymap.set("n", "<C-b>", "<C-b>zz", { desc = "Page Up and Center" })
vim.keymap.set("n", "<C-f>", "<C-f>zz", { desc = "Page Down and Center" })
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Move Down (Visual Line)" })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Move Down (Visual Line)" })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Move Up (Visual Line)" })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Move Up (Visual Line)" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent Left and Stay in Visual Mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Right and Stay in Visual Mode" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Line Down in Visual Mode" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Line Up in Visual Mode" })

-- Check Health
vim.keymap.set("n", "<leader>ch", ":checkhealth<cr>", { desc = "Check Neovim Health" })

-- Compiler
vim.api.nvim_set_keymap("n", "<leader>rr", ':w!<CR>:!compiler "%:p"<CR>', { noremap = true, silent = true, desc = "Run Compiler" })

-- Cut, Yank & Paste
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to Clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank Line to Clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>dy", [["_d"+y]], { desc = "Delete and Yank to Clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>dd", [["_d]], { desc = "Delete Without Saving to Clipboard" })
vim.keymap.set("n", "<leader>D", [["_D]], { desc = "Delete Line Without Saving to Clipboard" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste Over and Preserve Clipboard" })

-- Diagnostic
local diagnostic_goto = function(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Go to Previous Diagnostic" })
vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Go to Next Diagnostic" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Go to Previous Error" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Go to Next Error" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Go to Previous Warning" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Go to Next Warning" })
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Open Diagnostic Message" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Add Diagnostics to Location List" })

-- Files
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "Open New Buffer" })

-- Fix List & Trouble
vim.keymap.set("n", "[l", "<cmd>lprev<CR>zz", { desc = "Go to Previous Location List Item" })
vim.keymap.set("n", "]l", "<cmd>lnext<CR>zz", { desc = "Go to Next Location List Item" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "Go to Previous Quickfix Item" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Go to Next Quickfix Item" })
vim.keymap.set("n", "<leader>/", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search and Replace Word Under Cursor" })
vim.keymap.set("n", "<leader>ol", "<cmd>lopen<cr>", { desc = "Open Location List" })
vim.keymap.set("n", "<leader>oq", "<cmd>copen<cr>", { desc = "Open Quickfix List" })

-- Formats
vim.keymap.set("n", "<leader>cF", vim.lsp.buf.format, { desc = "Format Buffer" })

-- Health
vim.keymap.set("n", "<leader>ch", ":checkhealth<cr>", { desc = "Check Neovim Health" })

-- Keywordprg
vim.keymap.set("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Look Up Keyword" })

-- Lines
vim.keymap.set("n", "<A-,>", "<cmd>m .-2<cr>==", { desc = "Move Line Up" })
vim.keymap.set("n", "<A-.>", "<cmd>m .+1<cr>==", { desc = "Move Line Down" })
vim.keymap.set("i", "<A-,>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Line Up in Insert Mode" })
vim.keymap.set("i", "<A-.>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Line Down in Insert Mode" })
vim.keymap.set("v", "<A-,>", ":m '<-2<cr>gv=gv", { desc = "Move Selected Lines Up" })
vim.keymap.set("v", "<A-.>", ":m '>+1<cr>gv=gv", { desc = "Move Selected Lines Down" })


-- Ownerships
vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make File Executable" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Source
vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end, { desc = "Source Current File" })

-- Sudo
vim.keymap.set("n", "<leader>ww", "<cmd>SudoWrite<cr><cr>", { silent = true, desc = "Save File with Sudo" })
vim.keymap.set("n", "<leader>wq", "<cmd>SudoWritequit<cr>", { silent = true, desc = "Save and Quit with Sudo" })

-- Terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Escape Terminal Mode" })
vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Move to Left Window" })
vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Move to Window Below" })
vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Move to Window Above" })
vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Move to Right Window" })
vim.keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Close Terminal" })
vim.keymap.set("t", "<c-_>", "<cmd>close<cr>", { desc = "Close Terminal" })

-- Tmux
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to Left Window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to Window Below" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to Window Above" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to Right Window" })
-- vim.keymap.set("n", "<C-h>", "<C-w>h", { remap = true, desc = "" })
-- vim.keymap.set("n", "<C-j>", "<C-w>j", { remap = true, desc = "" })
-- vim.keymap.set("n", "<C-k>", "<C-w>k", { remap = true, desc = "" })
-- vim.keymap.set("n", "<C-l>", "<C-w>l", { remap = true, desc = "" })
vim.keymap.set("n", "<leader>tf", "<cmd>silent !~/.config/tmux/plugins/tmux-fzf/scripts/session.sh<CR>", { desc = "Switch Tmux Session" })

-- Lazy
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Open Lazy Plugin Manager" })

-- Mason
vim.keymap.set("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Open Mason" })

-- Word Definition
vim.api.nvim_set_keymap(
	"n",
	"<leader>gd",
	":lua WordDefinition(vim.fn.expand('<cword>'))<CR>",
	{ noremap = true, silent = true, desc = "Get Word Definition" }
)
