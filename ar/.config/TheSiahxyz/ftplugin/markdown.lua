-- Function to check if the current file is in the Obsidian repository
local function is_in_obsidian_repo()
	local current_file_path = vim.fn.expand("%:p:h")
	local user = os.getenv("USER") -- Get the current user's name from the environment variable
	local obsidian_path = "/home/" .. user .. "/Private/repos/Obsidian/"

	return string.find(current_file_path, obsidian_path) ~= nil
end

function BoldMe()
	-- Get the start and end positions of the visual selection
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local start_line, start_col = start_pos[2], start_pos[3]
	local end_line, end_col = end_pos[2], end_pos[3]
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	if start_line == end_line then
		lines[1] = lines[1]:sub(1, start_col - 1)
			.. "**"
			.. lines[1]:sub(start_col, end_col)
			.. "**"
			.. lines[1]:sub(end_col + 1)
	else
		lines[1] = lines[1]:sub(1, start_col - 1) .. "**" .. lines[1]:sub(start_col)
		lines[#lines] = lines[#lines]:sub(1, end_col) .. "**" .. lines[#lines]:sub(end_col + 1)
	end
	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

local function MarkdownCodeBlock(outside)
	vim.cmd("call search('```', 'cb')")
	vim.cmd(outside and "normal! Vo" or "normal! j0Vo")
	vim.cmd("call search('```')")
	if not outside then
		vim.cmd("normal! k")
	end
end

-- Code block text objects
for _, mode in ipairs({ "o", "x" }) do
	for _, mapping in ipairs({
		{ "am", true },
		{ "im", false },
	}) do
		vim.keymap.set(mode, mapping[1], function()
			MarkdownCodeBlock(mapping[2])
		end, { buffer = 0 })
	end
end

-- Function to fold all headings of a specific level
local function set_foldmethod_expr()
	-- These are lazyvim.org defaults but setting them just in case a file
	-- doesn't have them set
	if vim.fn.has("nvim-0.10") == 1 then
		vim.opt.foldmethod = "expr"
		vim.wo.foldexpr = "v:lua.require'thesiahxyz.utils.markdown'.foldexpr()"
		vim.opt.foldtext = ""
	else
		vim.opt.foldmethod = "indent"
		vim.wo.foldtext = "v:lua.require'thesiahxyz.utils.markdown'.foldexpr()"
	end
	vim.opt.foldlevel = 99
end

local function fold_headings_of_level(level)
	-- Move to the top of the file
	vim.cmd("normal! gg")
	-- Get the total number of lines
	local total_lines = vim.fn.line("$")
	for line = 1, total_lines do
		-- Get the content of the current line
		local line_content = vim.fn.getline(line)
		-- "^" -> Ensures the match is at the start of the line
		-- string.rep("#", level) -> Creates a string with 'level' number of "#" characters
		-- "%s" -> Matches any whitespace character after the "#" characters
		-- So this will match `## `, `### `, `#### ` for example, which are markdown headings
		if line_content:match("^" .. string.rep("#", level) .. "%s") then
			-- Move the cursor to the current line
			vim.fn.cursor(line, 1)
			-- Fold the heading if it matches the level
			if vim.fn.foldclosed(line) == -1 then
				vim.cmd("normal! za")
			end
		end
	end
end

local function fold_markdown_headings(levels)
	set_foldmethod_expr()
	-- I save the view to know where to jump back after folding
	local saved_view = vim.fn.winsaveview()
	for _, level in ipairs(levels) do
		fold_headings_of_level(level)
	end
	vim.cmd("nohlsearch")
	-- Restore the view to jump to where I was
	vim.fn.winrestview(saved_view)
end

local function make_heading_content()
	-- Get the total number of lines in the buffer
	local total_lines = vim.api.nvim_buf_line_count(0)

	-- Iterate through all lines
	for line = 1, total_lines do
		-- Get the content of the current line
		local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
		-- Match headings with at least two '#' characters
		local heading = line_content:match("^(##+)%s(.+)")
		if heading then
			-- Extract the heading text
			local heading_text = line_content:match("^#+%s(.+)")
			if heading_text then
				-- Create the content line with markdown link syntax
				local content_line = string.format("%s [%s]()", heading, heading_text)
				-- Replace the current line with the modified content
				vim.api.nvim_buf_set_lines(0, line - 1, line, false, { content_line })
			end
		end
	end
	-- Notify the user that the headings have been updated
	vim.notify("Headings transformed into content format", vim.log.levels.INFO)
end

-- Generate/update a Markdown TOC
-- To generate the TOC I use the markdown-toc plugin
-- https://github.com/jonschlinkert/markdown-toc
-- And the markdown-toc plugin installed as a LazyExtra
-- Function to update the Markdown TOC with customizable headings
local function update_markdown_toc(heading2, heading3)
	-- local path = vim.fn.expand("%") -- Expands the current file name to a full path
	local path = vim.api.nvim_buf_get_name(0)
	local bufnr = 0 -- The current buffer number, 0 references the current active buffer
	-- Save the current view
	-- If I don't do this, my folds are lost when I run this keymap
	vim.cmd("mkview")
	-- Retrieves all lines from the current buffer
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local toc_exists = false -- Flag to check if TOC marker exists
	local frontmatter_end = 0 -- To store the end line number of frontmatter
	-- Check for frontmatter and TOC marker
	for i, line in ipairs(lines) do
		if i == 1 and line:match("^---$") then
			-- Frontmatter start detected, now find the end
			for j = i + 1, #lines do
				if lines[j]:match("^---$") then
					frontmatter_end = j
					break
				end
			end
		end
		-- Checks for the TOC marker
		if line:match("^%s*<!%-%-%s*toc%s*%-%->%s*$") then
			toc_exists = true
			break
		end
	end
	-- Inserts H2 and H3 headings and <!-- toc --> at the appropriate position
	if not toc_exists then
		local insertion_line = 1 -- Default insertion point after first line
		if frontmatter_end > 0 then
			-- Find H1 after frontmatter
			for i = frontmatter_end + 1, #lines do
				if lines[i]:match("^#%s+") then
					insertion_line = i + 1
					break
				end
			end
		else
			-- Find H1 from the beginning
			for i, line in ipairs(lines) do
				if line:match("^#%s+") then
					insertion_line = i + 1
					break
				end
			end
		end
		-- Insert the specified headings and <!-- toc --> without blank lines
		-- Insert the TOC inside a H2 and H3 heading right below the main H1 at the top lamw25wmal
		vim.api.nvim_buf_set_lines(bufnr, insertion_line, insertion_line, false, { heading2, heading3, "<!-- toc -->" })
	end
	-- Silently save the file, in case TOC is being created for the first time
	vim.cmd("silent write")
	-- Silently run markdown-toc to update the TOC without displaying command output
	-- vim.fn.system('markdown-toc -i "' .. path .. '"')
	-- I want my bulletpoints to be created only as "-" so passing that option as
	-- an argument according to the docs
	-- https://github.com/jonschlinkert/markdown-toc?tab=readme-ov-file#optionsbullets
	vim.fn.system('markdown-toc --bullets "-" -i "' .. path .. '"')
	vim.cmd("edit!") -- Reloads the file to reflect the changes made by markdown-toc
	vim.cmd("silent write") -- Silently save the file
	vim.notify("TOC updated and file saved", vim.log.levels.INFO)
	-- -- In case a cleanup is needed, leaving this old code here as a reference
	-- -- I used this code before I implemented the frontmatter check
	-- -- Moves the cursor to the top of the file
	-- vim.api.nvim_win_set_cursor(bufnr, { 1, 0 })
	-- -- Deletes leading blank lines from the top of the file
	-- while true do
	--   -- Retrieves the first line of the buffer
	--   local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
	--   -- Checks if the line is empty
	--   if line == "" then
	--     -- Deletes the line if it's empty
	--     vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, {})
	--   else
	--     -- Breaks the loop if the line is not empty, indicating content or TOC marker
	--     break
	--   end
	-- end
	-- Restore the saved view (including folds)
	vim.cmd("loadview")
end

-- Show LSP diagnostics (inlay hints) in a hover window / popup lamw26wmal
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	pattern = "markdown",
	callback = function()
		vim.diagnostic.open_float(nil, {
			focus = false,
			border = "rounded",
		})
	end,
})

-- FileType autocmd for markdown files
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "mdx", "mdown", "mkd", "mkdn", "mdwn" },
	callback = function()
		-- Local settings
		vim.bo.textwidth = is_in_obsidian_repo() and 80 or 175
		vim.opt_local.autoindent = true
		vim.opt_local.conceallevel = 0
		vim.opt_local.expandtab = true
		vim.opt_local.softtabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.spell = true
		vim.opt_local.spelllang = { "en", "ko", "cjk" }
		vim.opt_local.spellsuggest = { "best", "9" }

		local arrows = { [">>"] = "→", ["<<"] = "←", ["^^"] = "↑", ["VV"] = "↓" }
		for key, val in pairs(arrows) do
			vim.cmd(string.format("iabbrev %s %s", key, val))
		end
	end,
})

-- this setting makes markdown auto-set the 80 text width limit when typing
-- vim.cmd('set fo+=a')
if is_in_obsidian_repo() then
	vim.bo.textwidth = 175 -- No limit for Obsidian repository
end

-- Makrdown.nvim settings
local markdown_settings = {
	auto_insert_bullets = 0,
	autowrite = 1,
	conceal = 0,
	conceal_code_blocks = 0,
	folding_disabled = 0,
	folding_level = 2,
	folding_style_pythonic = 1,
	follow_anchor = 1,
	new_list_item_indent = 0,
	no_extensions_in_markdown = 1,
	no_default_key_mappings = 1,
	toc_autofit = 1,
}

for key, value in pairs(markdown_settings) do
	vim.g["vim_markdown_" .. key] = value
end

-- MarkdownPreview settings
-- Get the BROWSER environment variable
local markdown_preview_settings = {
	browser = os.getenv("BROWSER") or "/usr/bin/firefox",
	echo_preview_url = 0,
}

for key, value in pairs(markdown_preview_settings) do
	vim.g["mkdp_" .. key] = value
end

-- Save the cursor position globally to access it across different mappings
_G.saved_positions = {}

local wk = require("which-key")
wk.add({
	mode = { "n", "v", "x" },
	{ "<leader>ct", group = "Copy" },
	{ "<leader>i", group = "Image" },
	{ "<leader>m", group = "Markdown" },
	{ "<leader>mh", group = "Headings" },
})

-- bold
vim.api.nvim_buf_set_keymap(
	0,
	"v",
	"<leader>mb",
	":<C-u>lua BoldMe()<CR>",
	{ noremap = true, silent = true, desc = "Bold selection" }
)

-- copy
vim.keymap.set("n", "<leader>mcd", "4wvg$y", { desc = "Copy description" })

-- heading
vim.keymap.set("n", "<leader>mhi", function()
	-- Save the current cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	-- I'm using [[ ]] to escape the special characters in a command
	vim.cmd([[:g/\(^$\n\s*#\+\s.*\n^$\)/ .+1 s/^#\+\s/#&/]])
	-- Restore the cursor position
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	-- Clear search highlight
	vim.cmd("nohlsearch")
end, { desc = "Increase headings without confirmation" })

vim.keymap.set("n", "<leader>mhd", function()
	-- Save the current cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	-- I'm using [[ ]] to escape the special characters in a command
	vim.cmd([[:g/^\s*#\{2,}\s/ s/^#\(#\+\s.*\)/\1/]])
	-- Restore the cursor position
	vim.api.nvim_win_set_cursor(0, cursor_pos)
	-- Clear search highlight
	vim.cmd("nohlsearch")
end, { desc = "Decrease headings without confirmation" })

local function make_heading_content()
	-- Get the total number of lines in the buffer
	local total_lines = vim.api.nvim_buf_line_count(0)

	-- Iterate through all lines
	for line = 1, total_lines do
		-- Get the content of the current line
		local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
		-- Match headings with at least two '#' characters
		local heading = line_content:match("^(##+)%s(.+)")
		if heading then
			-- Extract the heading text
			local heading_text = line_content:match("^#+%s(.+)")
			if heading_text then
				-- Create the content line with markdown link syntax
				local content_line = string.format("%s [%s]()", heading, heading_text)
				-- Replace the current line with the modified content
				vim.api.nvim_buf_set_lines(0, line - 1, line, false, { content_line })
			end
		end
	end
	-- Notify the user that the headings have been updated
	vim.notify("Headings transformed into content format", vim.log.levels.INFO)
end
vim.keymap.set("n", "<leader>mhl", make_heading_content, { desc = "Make heading content" })

-- line to list
vim.keymap.set(
	"n",
	"<leader>ml",
	"^I-<Space>[<Space>]<Space><Esc>^j",
	{ remap = true, silent = false, desc = "Make a line into a list" }
)

-- folding
-- Keymap for unfolding markdown headings of level 2 or above
-- Changed all the markdown folding and unfolding keymaps from <leader>mfj to
-- zj, zk, zl, z; and zu respectively lamw25wmal
vim.keymap.set("n", "zu", function()
	-- vim.keymap.set("n", "<leader>mfu", function()
	-- Reloads the file to reflect the changes
	vim.cmd("edit!")
	vim.cmd("normal! zR") -- Unfold all headings
end, { desc = "Unfold all headings level 2 or above" })

-- gk jummps to the markdown heading above and then folds it
-- zi by default toggles folding, but I don't need it lamw25wmal
vim.keymap.set("n", "zh", function()
	-- Difference between normal and normal!
	-- - `normal` executes the command and respects any mappings that might be defined.
	-- - `normal!` executes the command in a "raw" mode, ignoring any mappings.
	vim.cmd("normal gk")
	-- This is to fold the line under the cursor
	vim.cmd("normal! za")
end, { desc = "Fold the heading cursor currently on" })

-- Keymap for folding markdown headings of level 1 or above
vim.keymap.set("n", "zj", function()
	-- vim.keymap.set("n", "<leader>mfj", function()
	-- Reloads the file to refresh folds, otherwise you have to re-open neovim
	vim.cmd("edit!")
	-- Unfold everything first or I had issues
	vim.cmd("normal! zR")
	fold_markdown_headings({ 6, 5, 4, 3, 2, 1 })
end, { desc = "Fold all headings level 1 or above" })

-- Keymap for folding markdown headings of level 2 or above
-- I know, it reads like "madafaka" but "k" for me means "2"
vim.keymap.set("n", "zk", function()
	-- vim.keymap.set("n", "<leader>mfk", function()
	-- Reloads the file to refresh folds, otherwise you have to re-open neovim
	vim.cmd("edit!")
	-- Unfold everything first or I had issues
	vim.cmd("normal! zR")
	fold_markdown_headings({ 6, 5, 4, 3, 2 })
end, { desc = "Fold all headings level 2 or above" })

-- Keymap for folding markdown headings of level 3 or above
vim.keymap.set("n", "zl", function()
	-- vim.keymap.set("n", "<leader>mfl", function()
	-- Reloads the file to refresh folds, otherwise you have to re-open neovim
	vim.cmd("edit!")
	-- Unfold everything first or I had issues
	vim.cmd("normal! zR")
	fold_markdown_headings({ 6, 5, 4, 3 })
end, { desc = "Fold all headings level 3 or above" })

-- Keymap for folding markdown headings of level 4 or above
vim.keymap.set("n", "z;", function()
	-- vim.keymap.set("n", "<leader>mf;", function()
	-- Reloads the file to refresh folds, otherwise you have to re-open neovim
	vim.cmd("edit!")
	-- Unfold everything first or I had issues
	vim.cmd("normal! zR")
	fold_markdown_headings({ 6, 5, 4 })
end, { desc = "Fold all headings level 4 or above" })

-- link text objects for i and a
vim.keymap.set(
	{ "o", "x" },
	"il",
	"<cmd>lua require('various-textobjs').mdlink('inner')<CR>",
	{ buffer = true, desc = "Link" }
)
vim.keymap.set(
	{ "o", "x" },
	"al",
	"<cmd>lua require('various-textobjs').mdlink('outer')<CR>",
	{ buffer = true, desc = "Link" }
)

-- preview
vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "Markdown preview" })

-- traversal
vim.keymap.set("n", "<Tab>", "<Plug>Markdown_Fold", { desc = "Tab is for moving around only" })

vim.keymap.set("n", "]]", "<Plug>Markdown_MoveToNextHeader", { desc = "Go to next header" })
vim.keymap.set("n", "[[", "<Plug>Markdown_MoveToPreviousHeader", { desc = "Go to previous header. Contrast with ]c" })
vim.keymap.set("n", "][", "<Plug>Markdown_MoveToNextSiblingHeader", { desc = "Go to next sibling header if any" })
vim.keymap.set(
	"n",
	"[]",
	"<Plug>Markdown_MoveToPreviousSiblingHeader",
	{ desc = "Go to previous sibling header if any" }
)
vim.keymap.set("n", "]c", "<Plug>Markdown_MoveToCurHeader", { desc = "Go to Current header" })
vim.keymap.set("n", "]u", "<Plug>Markdown_MoveToParentHeader", { desc = "Go to parent header (Up)" })
vim.keymap.set("n", "<C-]>", "<Plug>Markdown_Checkbox", { desc = "Toggle checkboxes" })
vim.keymap.set("n", "Tab", "<Plug>Markdown_Fold", { desc = "Fold headers/lists" })
vim.keymap.set("n", "Return", "<Plug>Markdown_FollowLink", { desc = "Follow links" })
vim.keymap.set("i", "Tab", "<Plug>Markdown_Jump", { desc = "Indent new bullets, jump through empty fields in links" })
vim.keymap.set({ "i", "v" }, "<C-\\>", "<Plug>Markdown_CreateLink", { desc = "Create new links" })
vim.keymap.set("i", "<C-o>", "<Plug>Markdown_NewLineAbove", { desc = "New line above, overrides default" })
vim.keymap.set("i", "<C-b>", "<Plug>Markdown_NewLineBelow", { desc = "New line below, overrides default" })
vim.keymap.set("i", "Return", "<Plug>Markdown_NewLineBelow", { desc = "New line below, overrides default" })
-- jump to the first line of the TOC
vim.keymap.set("n", "<leader>mm", function()
	-- Save the current cursor position
	_G.saved_positions["toc_return"] = vim.api.nvim_win_get_cursor(0)
	-- Perform a silent search for the <!-- toc --> marker and move the cursor two lines below it
	vim.cmd("silent! /<!-- toc -->\\n\\n\\zs.*")
	-- Clear the search highlight without showing the "search hit BOTTOM, continuing at TOP" message
	vim.cmd("nohlsearch")
	-- Retrieve the current cursor position (after moving to the TOC)
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local row = cursor_pos[1]
	-- local col = cursor_pos[2]
	-- Move the cursor to column 15 (starts counting at 0)
	-- I like just going down on the TOC and press gd to go to a section
	vim.api.nvim_win_set_cursor(0, { row, 14 })
end, { desc = "Jump to the first line of the TOC" })
-- return to the previously saved cursor position
vim.keymap.set("n", "<leader>mn", function()
	local pos = _G.saved_positions["toc_return"]
	if pos then
		vim.api.nvim_win_set_cursor(0, pos)
	end
end, { desc = "Return to position before jumping" })

-- TOC (english)
vim.keymap.set("n", "<leader>mt", function()
	update_markdown_toc("## Contents", "### Table of contents")
end, { desc = "Insert/update Markdown TOC (English)" })
