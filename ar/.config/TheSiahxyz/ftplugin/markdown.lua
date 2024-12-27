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

-- Generate/update a Markdown TOC
-- To generate the TOC I use the markdown-toc plugin
-- https://github.com/jonschlinkert/markdown-toc
-- And the markdown-toc plugin installed as a LazyExtra
-- Function to update the Markdown TOC with customizable headings
local function update_markdown_toc(heading2, heading3)
	local path = vim.fn.expand("%") -- Expands the current file name to a full path
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
	-- vim.fn.system("markdown-toc -i " .. path)
	-- I want my bulletpoints to be created only as "-" so passing that option as
	-- an argument according to the docs
	-- https://github.com/jonschlinkert/markdown-toc?tab=readme-ov-file#optionsbullets
	vim.fn.system('markdown-toc --bullets "-" -i ' .. path)
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
-- this setting makes markdown auto-set the 80 text width limit when typing
-- vim.cmd('set fo+=a')
if is_in_obsidian_repo() then
	vim.bo.textwidth = 175 -- No limit for Obsidian repository
end

vim.cmd("set conceallevel=0")
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

vim.cmd("setlocal spell spelllang=en_us")
vim.cmd("setlocal expandtab shiftwidth=4 softtabstop=4 autoindent")
vim.cmd([[
  " arrows
  iabbrev >> →
  iabbrev << ←
  iabbrev ^^ ↑
  iabbrev VV ↓
]])

-- Makrdown.nvim settings
vim.g.vim_markdown_folding_disabled = 0
vim.g.vim_markdown_folding_style_pythonic = 1
vim.g.vim_markdown_folding_level = 2
vim.g.vim_markdown_toc_autofit = 1
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_conceal_code_blocks = 0
vim.g.vim_markdown_no_extensions_in_markdown = 1
vim.g.vim_markdown_autowrite = 1
vim.g.vim_markdown_follow_anchor = 1
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0

-- MarkdownPreview settings
-- Get the BROWSER environment variable
local browser = os.getenv("BROWSER")
vim.g.mkdp_browser = browser or "/usr/bin/firefox"
vim.g.mkdp_echo_preview_url = 0

-- Save the cursor position globally to access it across different mappings
_G.saved_positions = {}

local wk = require("which-key")
wk.add({
	mode = { "n", "v", "x" },
	{ "<leader>ct", group = "Copy" },
	{ "<leader>i", group = "Image" },
	{ "<leader>m", group = "Markdown" },
})

-- bold
vim.api.nvim_buf_set_keymap(
	0,
	"v",
	"<Leader>mb",
	":<C-u>lua BoldMe()<CR>",
	{ noremap = true, silent = true, desc = "Bold selection" }
)

-- copy
vim.keymap.set("n", "<leader>mcd", "4wvg$y", { desc = "Copy description" })

-- increase
vim.keymap.set("v", "<leader>mhi", ":HeaderIncrease<CR>", { desc = "Increase header level" })

-- line to list
vim.keymap.set(
	"n",
	"<leader>ml",
	"^I-<Space>[<Space>]<Space><Esc>^j",
	{ remap = true, silent = false, desc = "Make a line into a list" }
)

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
