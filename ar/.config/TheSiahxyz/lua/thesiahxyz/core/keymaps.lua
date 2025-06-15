-- Ascii
vim.keymap.set("n", "<leader>a1", ":.!toilet -w 200 -f bfraktur<cr>", { desc = "Ascii art bfraktur" })
vim.keymap.set("n", "<leader>a2", ":.!toilet -w 200 -f emboss<cr>", { desc = "Ascii art emboss" })
vim.keymap.set("n", "<leader>a3", ":.!toilet -w 200 -f emboss2<cr>", { desc = "Ascii art emboss2" })
vim.keymap.set("n", "<leader>a4", ":.!toilet -w 200 -f future<cr>", { desc = "Ascii art future" })
vim.keymap.set("n", "<leader>a5", ":.!toilet -w 200 -f pagga<cr>", { desc = "Ascii art pagga" })
vim.keymap.set("n", "<leader>a6", ":.!toilet -w 200 -f wideterm<cr>", { desc = "Ascii art wideterm" })
vim.keymap.set("n", "<leader>a7", ":.!figlet -w 200 -f standard<cr>", { desc = "Ascii art standard" })
vim.keymap.set("n", "<leader>a8", ":.!figlet -w 200 -f slant<cr>", { desc = "Ascii art slant" })
vim.keymap.set("n", "<leader>a9", ":.!figlet -w 200 -f big<cr>", { desc = "Ascii art big" })
vim.keymap.set("n", "<leader>a0", ":.!figlet -w 200 -f shadow<cr>", { desc = "Ascii art shadow" })

-- Buffers
vim.keymap.set({ "n", "v", "x", "t" }, "<A-x>", "<cmd>bd!<cr>", { desc = "Delete buffer" })
vim.keymap.set({ "i", "n", "t" }, "<C-p>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set({ "i", "n", "t" }, "<C-n>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set({ "n", "t" }, "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set({ "n", "t" }, "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader><leader>", "<cmd>e #<cr>", { desc = "Switch to last buffer" })
vim.keymap.set({ "n", "v", "x", "t" }, "<leader>bd", "<cmd>:bd<cr>", { desc = "Close buffer" })
vim.keymap.set({ "n", "v", "x", "t" }, "<leader>BD", "<cmd>:bd!<cr>", { desc = "Force close buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "Open new buffer" })
vim.keymap.set("n", "<leader>bc", "<cmd>e!<cr>", { desc = "Clear edit" })
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save current buffer" })
vim.keymap.set({ "n", "v" }, "<leader>wq", "<cmd>wq<cr>", { desc = "Save current buffer and quit" })
vim.keymap.set({ "n", "v" }, "<leader>WQ", "<cmd>wqa<cr>", { desc = "Save all buffers and quit" })
vim.keymap.set({ "n", "v" }, "<leader>qq", "<cmd>q!<cr>", { desc = "Force quit" })
vim.keymap.set({ "n", "v" }, "<leader>QQ", "<cmd>qa!<cr>", { desc = "Force quit all" })
vim.keymap.set("n", "<leader>rn", function()
	local current_name = vim.fn.expand("%:p") -- Get the full path of the current file
	local directory = vim.fn.expand("%:p:h") -- Get the directory of the current file
	local new_name = vim.fn.input("New filename: ", directory .. "/") -- Prompt for the new name
	if new_name == "" or new_name == current_name then
		return -- Do nothing if no input or name hasn't changed
	end
	vim.cmd("silent !mv " .. vim.fn.shellescape(current_name) .. " " .. vim.fn.shellescape(new_name))
	vim.cmd("edit " .. vim.fn.fnameescape(new_name))
	vim.cmd("bdelete " .. vim.fn.bufnr(current_name))
end, { noremap = true, silent = true, desc = "Rename file" })
vim.keymap.set("n", "<leader>ms", function()
	vim.cmd("new | put=execute('messages') | setlocal buftype=nofile")
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local filtered_lines = {}
	for _, line in ipairs(lines) do
		local trimmed_line = line:match("^%s*(.-)%s*$") -- Remove leading and trailing whitespace
		if trimmed_line ~= "" then
			table.insert(filtered_lines, trimmed_line) -- Only add non-empty lines
		end
	end
	vim.fn.setreg('"', table.concat(filtered_lines, "\n"))
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, filtered_lines)
	vim.keymap.set("n", "q", function()
		vim.api.nvim_buf_delete(buf, { force = true })
	end, { buffer = buf, desc = "Close message buffer" })
end, { desc = "Open messages, trim, and copy content" })

-- Cd
vim.keymap.set("n", "gcd", ":cd %:p:h<cr>:pwd<cr>", { desc = "Go to current file path" })
vim.keymap.set("n", "gcD", function()
	local realpath = vim.fn.systemlist("readlink -f " .. vim.fn.shellescape(vim.fn.expand("%:p")))[1]
	vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.fnamemodify(realpath, ":h")))
	vim.cmd("pwd")
end, { desc = "Go to real path of current file" })
vim.keymap.set("n", "gc.", ":cd ..<cr>:pwd<cr>", { desc = "Go to current file path" })

-- Check health
vim.keymap.set("n", "<leader>ch", ":checkhealth<cr>", { desc = "Check neovim health" })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear search highlights" })

-- Clear search / diff update / redraw
vim.keymap.set(
	"n",
	"<leader>R",
	"<cmd>nohlsearch<bar>diffupdate<bar>normal! <C-l><cr>",
	{ desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- Copy
vim.keymap.set("n", "<leader>cp", function()
	local filepath = vim.fn.expand("%") -- Get the current filepath
	local filename = vim.fn.expand("%:t") -- Get the current filename
	local file_root = vim.fn.expand("%:r") -- Get the file root (without extension)
	local file_ext = vim.fn.expand("%:e") -- Get the file extension
	local new_filename = file_root .. "_copied" -- Start with the base for new filename
	local num = 1
	while vim.fn.filereadable(new_filename .. "." .. file_ext) == 1 do
		new_filename = file_root .. "_copied_" .. num
		num = num + 1
	end
	new_filename = new_filename .. "." .. file_ext
	local cmd = "cp " .. filepath .. " " .. new_filename

	-- Wrap input in pcall to handle Ctrl-c interruptions
	local ok, confirm = pcall(vim.fn.input, 'Do you want to copy "' .. filename .. '"? (y/n): ')

	-- If interrupted (Ctrl-c), return silently
	if not ok or confirm == nil or confirm == "" then
		return
	end

	-- Handle positive confirmation
	if confirm:lower() == "y" or confirm:lower() == "yes" then
		vim.cmd("silent !" .. cmd)
		vim.cmd("silent edit " .. new_filename)
	end
end, { silent = true, desc = "Copy current file" })
vim.keymap.set(
	"n",
	"<leader>cP",
	':let @+ = expand("%:p")<cr>:lua print("Copied path to: " .. vim.fn.expand("%:p"))<cr>',
	{ desc = "Copy current file name and path" }
)

-- Cut, Yank & Paste
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader><C-y>", ":%y<cr>", { desc = "Yank current file to clipboard" })
vim.keymap.set({ "n", "v", "x" }, "<leader>pp", [["+p]], { desc = "Paste from clipboard after cursor" })
vim.keymap.set({ "n", "v", "x" }, "<leader>PP", [["+P]], { desc = "Paste from clipboard before cursor" })
vim.keymap.set({ "n", "v", "x" }, "<leader>pP", [["_dP]], { desc = "Paste over and preserve clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>dd", [["+d]], { desc = "Delete and yank to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>DD", [["_d]], { desc = "Delete without storing in clipboard" })
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

-- Disable
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable q command" })

-- Explore
vim.keymap.set("n", "<leader>ex", vim.cmd.Ex, { desc = "Open explorer" })
vim.keymap.set("n", "<leader>es", vim.cmd.Sex, { desc = "Open explorer (horizontal split)" })
vim.keymap.set("n", "<leader>ev", vim.cmd.Vex, { desc = "Open explorer (vertical split)" })
vim.keymap.set("n", "<leader>qe", function()
	if vim.bo.filetype == "netrw" then
		vim.cmd("bd")
	end
end, { desc = "Close explorer (netrw)" })

-- Fix List & Trouble
vim.keymap.set("n", "[o", "<cmd>lprev<cr>zz", { desc = "Previous location" })
vim.keymap.set("n", "]o", "<cmd>lnext<cr>zz", { desc = "Next location" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>zz", { desc = "Previous quickfix" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix" })
vim.keymap.set(
	"n",
	"<leader>rw",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Search and replace word under cursor" }
)
vim.keymap.set("n", "<leader>oo", "<cmd>lopen<cr>", { desc = "Open location list" })
vim.keymap.set("n", "<leader>oq", "<cmd>copen<cr>", { desc = "Open quickfix list" })

-- Formats
vim.keymap.set("n", "<leader>cF", vim.lsp.buf.format, { desc = "Format buffer by default lsp" })

-- Full path
vim.keymap.set("n", "<leader>zf", function()
	local word = vim.fn.expand("<cWORD>") -- Get full text under the cursor (handles paths with slashes)
	if word:match("%$") then
		local expanded_path = vim.fn.expand(word)
		if expanded_path ~= word then
			vim.cmd("normal! ciW" .. expanded_path) -- Replace entire word under cursor
		end
	end
end, { desc = "Expand and replace path under cursor" })

-- Git
-- create repository
vim.keymap.set("n", "<leader>gR", function()
	-- Check if GitHub CLI is installed
	local gh_installed = vim.fn.system("command -v gh")
	if gh_installed == "" then
		print("GitHub CLI is not installed. Please install it using 'brew install gh'.")
		return
	end
	-- Get the current working directory and extract the repository name
	local cwd = vim.fn.getcwd()
	local repo_name = vim.fn.fnamemodify(cwd, ":t")
	if repo_name == "" then
		print("Failed to extract repository name from the current directory.")
		return
	end
	-- Display the message and ask for confirmation
	local confirmation = vim.fn.input('The name of the repo will be: "' .. repo_name .. '"\nType "yes" to continue: ')
	if confirmation:lower() ~= "yes" then
		print("Operation canceled.")
		return
	end
	-- Check if the repository already exists on GitHub
	local check_repo_command =
		string.format("gh repo view %s/%s", vim.fn.system("gh api user --jq '.login'"):gsub("%s+", ""), repo_name)
	local check_repo_result = vim.fn.systemlist(check_repo_command)
	if not string.find(table.concat(check_repo_result), "Could not resolve to a Repository") then
		print("Repository '" .. repo_name .. "' already exists on GitHub.")
		return
	end
	-- Prompt for repository type
	local repo_type = vim.fn.input("Enter the repository type (private/public): "):lower()
	if repo_type ~= "private" and repo_type ~= "public" then
		print("Invalid repository type. Please enter 'private' or 'public'.")
		return
	end
	-- Set the repository type flag
	local repo_type_flag = repo_type == "private" and "--private" or "--public"
	-- Initialize the git repository and create the GitHub repository
	local init_command = string.format("cd %s && git init", vim.fn.shellescape(cwd))
	vim.fn.system(init_command)
	local create_command =
		string.format("cd %s && gh repo create %s %s --source=.", vim.fn.shellescape(cwd), repo_name, repo_type_flag)
	local create_result = vim.fn.system(create_command)
	-- Print the result of the repository creation command
	if string.find(create_result, "https://github.com") then
		print("Repository '" .. repo_name .. "' created successfully.")
	else
		print("Failed to create the repository: " .. create_result)
	end
end, { desc = "Create GitHub repository" })
-- open repository
local function open_github_link(use_root)
	-- Get the full path of the current file
	local file_path = vim.fn.expand("%:p")
	if file_path == "" then
		print("No file is currently open")
		return
	end

	-- Get the Git repository root
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if not git_root or git_root == "" then
		print("Could not determine the root directory for the GitHub repository")
		return
	end

	-- Get the origin URL of the repository
	local origin_url = vim.fn.systemlist("git config --get remote.origin.url")[1]
	if not origin_url or origin_url == "" then
		print("Could not determine the origin URL for the GitHub repository")
		return
	end

	-- Get the current branch name
	local branch_name = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
	if not branch_name or branch_name == "" then
		print("Could not determine the current branch name")
		return
	end

	-- Convert the origin URL to a GitHub HTTPS URL
	local repo_url = origin_url:gsub("git@github.com:", "https://github.com/"):gsub("%.git$", "")

	local github_url
	if use_root then
		-- Use the root repository URL
		github_url = repo_url
	else
		-- Generate the link for the current file
		local relative_path = file_path:sub(#git_root + 2) -- Extract the relative path
		github_url = repo_url .. "/blob/" .. branch_name .. "/" .. relative_path
	end

	-- Open the URL in the default browser
	local command = "xdg-open " .. vim.fn.shellescape(github_url)
	vim.fn.system(command)

	-- Print the opened URL
	print("Opened GitHub link: " .. github_url)
end

-- Keybinding for opening the current file link
vim.keymap.set("n", "<leader>go", function()
	open_github_link(false) -- Use the current file link
end, { desc = "Open GitHub link for the current file" })

-- Keybinding for opening the repository root link
vim.keymap.set("n", "<leader>gO", function()
	open_github_link(true) -- Use the root repository URL
end, { desc = "Open GitHub repository root" })

-- paste a github link and add it in this format
vim.keymap.set({ "n", "v", "i" }, "<M-;>", function()
	-- Insert the text in the desired format
	vim.cmd('normal! a[](){:target="_blank"} ')
	vim.cmd("normal! F(pv2F/lyF[p")
	-- Leave me in normal mode or command mode
	vim.cmd("stopinsert")
end, { desc = "Paste github link" })

-- Health
vim.keymap.set("n", "<leader>ch", ":checkhealth<cr>", { desc = "Check neovim health" })

-- Highlights under cursor
vim.keymap.set("n", "<leader>ip", vim.show_pos, { desc = "Inspect position" })

-- Keywordprg
vim.keymap.set("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Look up keyword" })

-- Lines
-- vim.keymap.set("n", "<A-,>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
-- vim.keymap.set("n", "<A-.>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set(
	"i",
	"<A-,>",
	"<esc><cmd>m .-2<cr>==gi",
	{ noremap = true, silent = true, desc = "Move line up in insert mode" }
)
vim.keymap.set(
	"i",
	"<A-.>",
	"<esc><cmd>m .+1<cr>==gi",
	{ noremap = true, silent = true, desc = "Move line down in insert mode" }
)
vim.keymap.set("v", "<C-,>", ":m '<-2<cr>gv=gv", { desc = "Move selected lines up" })
vim.keymap.set("v", "<C-.>", ":m '>+1<cr>gv=gv", { desc = "Move selected lines down" })

-- Markdown
vim.keymap.set({ "n", "v" }, "gk", function()
	-- `?` - Start a search backwards from the current cursor position.
	-- `^` - Match the beginning of a line.
	-- `##` - Match 2 ## symbols
	-- `\\+` - Match one or more occurrences of prev element (#)
	-- `\\s` - Match exactly one whitespace character following the hashes
	-- `.*` - Match any characters (except newline) following the space
	-- `$` - Match extends to end of line
	vim.cmd("silent! ?^##\\+\\s.*$")
	-- Clear the search highlight
	vim.cmd("nohlsearch")
end, { desc = "Go to previous markdown header" })
vim.keymap.set({ "n", "v" }, "gj", function()
	-- `/` - Start a search forwards from the current cursor position.
	-- `^` - Match the beginning of a line.
	-- `##` - Match 2 ## symbols
	-- `\\+` - Match one or more occurrences of prev element (#)
	-- `\\s` - Match exactly one whitespace character following the hashes
	-- `.*` - Match any characters (except newline) following the space
	-- `$` - Match extends to end of line
	vim.cmd("silent! /^##\\+\\s.*$")
	-- Clear the search highlight
	vim.cmd("nohlsearch")
end, { desc = "Go to next markdown header" })

-- Marks
vim.keymap.set("n", "<leader>mD", function()
	-- Delete all marks in the current buffer
	vim.cmd("delmarks!")
	print("All marks deleted.")
end, { desc = "Delete all marks" })

-- Ownerships
vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<cr>", { silent = true, desc = "Make file executable" })

-- Remap Default
vim.keymap.set("i", "jk", "<esc>", { noremap = true, silent = true, desc = "Escape to normal mode" })
vim.keymap.set("i", "<C-c>", "<esc>", { noremap = true, silent = true, desc = "Escape to normal mode" })
vim.keymap.set("i", "<C-a>", "<home>", { noremap = true, silent = true, desc = "Insert at beginning of line" })
vim.keymap.set("i", "<C-e>", "<end>", { noremap = true, silent = true, desc = "Move to end of line" })
vim.keymap.set("i", "<C-h>", "<left>", { noremap = true, silent = true, desc = "Move left" })
vim.keymap.set("i", "<C-l>", "<right>", { noremap = true, silent = true, desc = "Move right" })
vim.keymap.set("i", "<C-j>", "<down>", { noremap = true, silent = true, desc = "Move down" })
vim.keymap.set("i", "<C-k>", "<up>", { noremap = true, silent = true, desc = "Move up" })
vim.keymap.set("i", "<C-b>", "<up><end><cr>", { noremap = true, silent = true, desc = "New line above" })
vim.keymap.set("i", "<C-f>", "<end><cr>", { noremap = true, silent = true, desc = "New line below" })
vim.keymap.set("n", "<C-c>", ":", { noremap = true, desc = "Enter command mode" })
vim.keymap.set("n", "J", "mzJ`z", { noremap = true, desc = "Join lines and keep cursor position" })
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
local scroll_percentage = 0.50
vim.keymap.set("n", "<C-d>", function()
	local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
	vim.cmd("normal! " .. lines .. "jzz")
end, { noremap = true, silent = true, desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", function()
	local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
	vim.cmd("normal! " .. lines .. "kzz")
end, { noremap = true, silent = true, desc = "Scroll up and center" })
-- vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll down and center" })
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll up and center" })
vim.keymap.set("n", "<C-b>", "<C-b>zz", { noremap = true, silent = true, desc = "Page up and center" })
vim.keymap.set("n", "<C-f>", "<C-f>zz", { noremap = true, silent = true, desc = "Page down and center" })
vim.keymap.set("n", "{", "{zz", { noremap = true, silent = true, desc = "Move to previous paragraph and center" })
vim.keymap.set("n", "}", "}zz", { noremap = true, silent = true, desc = "Move to next paragraph and center" })
vim.keymap.set("n", "G", "Gzz", { noremap = true, silent = true, desc = "Go to bottom of file and center" })
vim.keymap.set("n", "gg", "ggzz", { noremap = true, silent = true, desc = "Go to top of file and center" })
vim.keymap.set("n", "gd", "gdzz", { noremap = true, silent = true, desc = "Go to definition and center" })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { noremap = true, silent = true, desc = "Jump forward in jumplist and center" })
vim.keymap.set(
	"n",
	"<C-o>",
	"<C-o>zz",
	{ noremap = true, silent = true, desc = "Jump backward in jumplist and center" }
)
vim.keymap.set(
	"n",
	"%",
	"%zz",
	{ noremap = true, silent = true, desc = "Jump to matching pair (e.g. brackets) and center" }
)
vim.keymap.set(
	"n",
	"*",
	"*zz",
	{ noremap = true, silent = true, desc = "Search for next occurrence of word under cursor and center" }
)
vim.keymap.set(
	"n",
	"#",
	"#zz",
	{ noremap = true, silent = true, desc = "Search for previous occurrence of word under cursor and center" }
)

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

-- Remove
local function delete_current_file()
	local filepath = vim.fn.expand("%:p")
	local filename = vim.fn.expand("%:t") -- Get the current filename
	if filepath and filepath ~= "" then
		-- Check if trash utility is installed
		if vim.fn.executable("trash") == 0 then
			vim.api.nvim_echo({
				{ "- Trash utility not installed. Make sure to install it first\n", "ErrorMsg" },
				{ "- Install `trash-cli`\n", nil },
			}, false, {})
			return
		end
		-- Prompt for confirmation before deleting the file
		vim.ui.input({
			prompt = 'Do you want to delete "' .. filename .. '"? (y/n): ',
		}, function(input)
			if input == nil then
				return
			end

			if input:lower() == "y" or input:lower() == "yes" then
				-- Delete the file using trash app
				local success, _ = pcall(function()
					vim.fn.system({ "trash", vim.fn.fnameescape(filepath) })
				end)
				if success then
					vim.api.nvim_echo({
						{ "File deleted from disk:\n", "Normal" },
						{ filepath, "Normal" },
					}, false, {})
					-- Close the buffer after deleting the file
					vim.cmd("bd!")
				else
					vim.api.nvim_echo({
						{ "Failed to delete file:\n", "ErrorMsg" },
						{ filepath, "ErrorMsg" },
					}, false, {})
				end
			else
				vim.api.nvim_echo({
					{ "File deletion canceled.", "Normal" },
				}, false, {})
			end
		end)
	else
		vim.api.nvim_echo({
			{ "No file to delete", "WarningMsg" },
		}, false, {})
	end
end

vim.keymap.set("n", "<leader>rm", function()
	delete_current_file()
end, { desc = "Remove current file" })

-- Scripts
vim.keymap.set("n", "<leader>rr", function()
	vim.cmd("w")
	vim.cmd("split | resize 10 | terminal compiler " .. vim.fn.expand("%:p"))
end, { noremap = true, silent = true, desc = "Run compiler interactively" })
vim.api.nvim_set_keymap(
	"n",
	"<leader>RR",
	":!opout <C-r>%<cr><cr>",
	{ noremap = true, silent = true, desc = "Docs viewer" }
)

-- Source
-- source nvim config
vim.keymap.set("n", "<leader>SO", function()
	vim.cmd("so")
end, { desc = "Source current file" })
-- reload zsh configuration by sourcing ~/.config/zsh/.zshrc in a separate shell
vim.keymap.set("n", "<leader>SZ", function()
	-- Define the command to source zshrc
	local command = "source ~/.config/zsh/.zshrc"
	-- Execute the command in a new Zsh shell
	local full_command = "zsh -c '" .. command .. "'"
	-- Run the command and capture the output
	local output = vim.fn.system(full_command)
	-- Check the exit status of the command
	local exit_code = vim.v.shell_error
	if exit_code == 0 then
		vim.api.nvim_echo({ { "Successfully sourced ~/.config/zsh/.zshrc", "NormalMsg" } }, false, {})
	else
		vim.api.nvim_echo({
			{ "Failed to source ~/.config/zsh/.zshrc:", "ErrorMsg" },
			{ output, "ErrorMsg" },
		}, false, {})
	end
end, { desc = "Source zshrc" })
-- source shortcuts from bm-files and bm-folders
local shortcuts_file = vim.fn.expand("~/.config/nvim/shortcuts.lua")
local file = io.open(shortcuts_file, "r")
if file then
	file:close()
	vim.cmd("silent! source " .. shortcuts_file)
end

-- Spell
vim.keymap.set("n", "zp", function()
	vim.opt.spelllang = { "en", "ko", "cjk" }
	vim.cmd("echo 'Spell language set to English, Korean, and CJK'")
end, { desc = "Spelling language English, Korean, and CJK" })
-- repeat the replacement done by |z=| for all matches with the replaced word in the current window.
vim.keymap.set("n", "z.", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":spellr\n", true, false, true), "m", true)
end, { desc = "Spelling repeat" })

-- Sudo
vim.keymap.set("n", "<leader>SW", "<cmd>SudoWrite<cr><cr>", { silent = true, desc = "Save file with sudo" })
vim.keymap.set("n", "<leader>SWQ", "<cmd>SudoWritequit<cr>", { silent = true, desc = "Save and quit with sudo" })

-- Surround
vim.keymap.set("n", "sau", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Adjust for 0-index in Lua
	-- This makes the `s` optional so it matches both http and https
	local pattern = "https?://[^ ,;'\"<>%s)]*"
	-- Find the starting and ending positions of the URL
	local s, e = string.find(line, pattern)
	while s and e do
		if s <= col and e >= col then
			-- When the cursor is within the URL
			local url = string.sub(line, s, e)
			-- Update the line with backticks around the URL
			local new_line = string.sub(line, 1, s - 1) .. "`" .. url .. "`" .. string.sub(line, e + 1)
			vim.api.nvim_set_current_line(new_line)
			vim.cmd("silent write")
			return
		end
		-- Find the next URL in the line
		s, e = string.find(line, pattern, e + 1)
		-- Save the file to update trouble list
	end
	print("No URL found under cursor")
end, { desc = "Add surrounding to URL" })
vim.keymap.set("v", "<leader>bl", function()
	-- Get the selected text range
	local start_row, start_col = unpack(vim.fn.getpos("'<"), 2, 3)
	local end_row, end_col = unpack(vim.fn.getpos("'>"), 2, 3)
	-- Get the selected lines
	local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
	local selected_text = table.concat(lines, "\n"):sub(start_col, #lines == 1 and end_col or -1)
	if selected_text:match("^%*%*.*%*%*$") then
		vim.notify("Text already bold", vim.log.levels.INFO)
	else
		vim.cmd("normal 2gsa*")
	end
end, { desc = "Bold current selection" })
vim.keymap.set("n", "gbd", function()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local current_buffer = vim.api.nvim_get_current_buf()
	local start_row = cursor_pos[1] - 1
	local col = cursor_pos[2]
	-- Get the current line
	local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
	-- Check if the cursor is on an asterisk
	if line:sub(col + 1, col + 1):match("%*") then
		vim.notify("Cursor is on an asterisk, run inside the bold text", vim.log.levels.WARN)
		return
	end
	-- Search for '**' to the left of the cursor position
	local left_text = line:sub(1, col)
	local bold_start = left_text:reverse():find("%*%*")
	if bold_start then
		bold_start = col - bold_start
	end
	-- Search for '**' to the right of the cursor position and in following lines
	local right_text = line:sub(col + 1)
	local bold_end = right_text:find("%*%*")
	local end_row = start_row
	while not bold_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
		end_row = end_row + 1
		local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
		if next_line == "" then
			break
		end
		right_text = right_text .. "\n" .. next_line
		bold_end = right_text:find("%*%*")
	end
	if bold_end then
		bold_end = col + bold_end
	end
	-- Remove '**' markers if found, otherwise bold the word
	if bold_start and bold_end then
		-- Extract lines
		local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
		local text = table.concat(text_lines, "\n")
		-- Calculate positions to correctly remove '**'
		-- vim.notify("bold_start: " .. bold_start .. ", bold_end: " .. bold_end)
		local new_text = text:sub(1, bold_start - 1) .. text:sub(bold_start + 2, bold_end - 1) .. text:sub(bold_end + 2)
		local new_lines = vim.split(new_text, "\n")
		-- Set new lines in buffer
		vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
	-- vim.notify("Unbolded text", vim.log.levels.INFO)
	else
		-- Bold the word at the cursor position if no bold markers are found
		local before = line:sub(1, col)
		local after = line:sub(col + 1)
		local inside_surround = before:match("%*%*[^%*]*$") and after:match("^[^%*]*%*%*")
		if inside_surround then
			vim.cmd("normal gsd*.")
		else
			vim.cmd("normal viw")
			vim.cmd("normal 2gsa*")
		end
		vim.notify("Bolded current word", vim.log.levels.INFO)
	end
end, { desc = "Toggle bold" })

-- Tab
vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "]]<tab>", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "[[<tab>", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>n", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><tab>p", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
vim.keymap.set("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Terminal
vim.keymap.set("n", "<leader>te", "<cmd>term<cr>", { desc = "Open terminal" })
vim.keymap.set("n", "<leader>t-", "<cmd>sp term://zsh | startinsert<cr>", { desc = "Split terminal (horizontal)" })
vim.keymap.set("n", "<leader>t|", "<cmd>vsp term://zsh | startinsert<cr>", { desc = "Split terminal (vertical)" })
vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })
vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Move to left window" })
vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Move to window below" })
vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Move to window above" })
vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Move to right window" })
vim.keymap.set("t", "<C-Space>l", "clear<cr>", { silent = true, desc = "Clear terminal" })
vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>iexit<cr>", { desc = "Close terminal" })
vim.keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Close terminal" })
vim.keymap.set("t", "<C-_>", "<cmd>close<cr>", { desc = "Close terminal" })

-- Tmux
if vim.env.TMUX then
	vim.keymap.set(
		"n",
		"<leader>tm",
		"<cmd>silent !~/.config/tmux/plugins/tmux-fzf/scripts/session.sh<cr>",
		{ desc = "Find tmux session" }
	)
	vim.keymap.set("n", "<leader>RS", function()
		vim.fn.system("restartnvim")
	end, { noremap = true, silent = true, desc = "Restart nvim (tmux)" })
end

-- Todo
-- detect todos and toggle between ":" and ";", or show a message if not found
-- this is to "mark them as done"
vim.keymap.set("n", "<leader>td", function()
	-- Get the current line
	local current_line = vim.fn.getline(".")
	-- Get the current line number
	local line_number = vim.fn.line(".")
	if string.find(current_line, "TODO:") then
		-- Replace the first occurrence of ":" with ";"
		local new_line = current_line:gsub("TODO:", "TODO;")
		-- Set the modified line
		vim.fn.setline(line_number, new_line)
	elseif string.find(current_line, "TODO;") then
		-- Replace the first occurrence of ";" with ":"
		local new_line = current_line:gsub("TODO;", "TODO:")
		-- Set the modified line
		vim.fn.setline(line_number, new_line)
	else
		vim.cmd("echo 'todo item not detected'")
	end
end, { desc = "Toggle TODO item done or not" })

-- Windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to window above" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move to right window" })
-- vim.keymap.set("n", "<C-up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
-- vim.keymap.set("n", "<C-down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
-- vim.keymap.set("n", "<C-left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
-- vim.keymap.set("n", "<C-right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

function WordDefinition(input)
	-- Function to run the dict command and return its output
	local function get_output(word)
		local escaped_word = vim.fn.shellescape(word)
		return vim.fn.system("dict " .. escaped_word)
	end

	-- Function to process the word for singular/plural handling
	local function get_definition(word)
		-- Attempt to derive the singular form
		local singular = word
		if word:sub(-2) == "es" then
			singular = word:sub(1, -3) -- Remove 'es'
		elseif word:sub(-1) == "s" then
			singular = word:sub(1, -2) -- Remove 's'
		end

		-- Fetch output for both singular and original word
		local singular_output = get_output(singular)
		local original_output = get_output(word)

		-- Determine which output to prioritize
		if singular ~= word and not vim.startswith(singular_output, "No definitions found") then
			return singular_output -- Use singular if valid and different
		else
			return original_output -- Otherwise, use the original word
		end
	end

	-- Get the definition and output for the word
	local output = get_definition(input)

	-- Create a new buffer and display the result
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(output, "\n"))
end
vim.api.nvim_set_keymap(
	"n",
	"<leader>k",
	":lua WordDefinition(vim.fn.expand('<cword>'))<cr>",
	{ noremap = true, silent = true, desc = "Word definition" }
)

-- Lazy
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Open lazy plugin manager" })

-- Mason
vim.keymap.set("n", "<leader>M", "<cmd>Mason<cr>", { desc = "Open mason" })
