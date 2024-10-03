-- markdown link text objects for i and a
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

-- Function to check if the current file is in the Obsidian repository
local function is_in_obsidian_repo()
	local current_file_path = vim.fn.expand("%:p:h")
	local user = os.getenv("USER") -- Get the current user's name from the environment variable
	local obsidian_path = "/home/" .. user .. "/Private/repos/Obsidian/"

	return string.find(current_file_path, obsidian_path) ~= nil
end

vim.cmd("set conceallevel=0")
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- this setting makes markdown auto-set the 80 text width limit when typing
-- vim.cmd('set fo+=a')
if is_in_obsidian_repo() then
	vim.bo.textwidth = 175 -- No limit for Obsidian repository
end

vim.cmd("setlocal spell spelllang=en_us")
vim.cmd("setlocal expandtab shiftwidth=4 softtabstop=4 autoindent")
vim.cmd([[
  " arrows
  iabbrev >> →
  iabbrev << ←
  iabbrev ^^ ↑
  iabbrev VV ↓
]])

vim.keymap.set("n", "<Tab>", "<Plug>Markdown_Fold", { desc = "Tab is for moving around only" })
vim.keymap.set("n", "<leader>ctd", "4wvg$y", { desc = "Copy description" })
vim.keymap.set("v", "<leader>hi", ":HeaderIncrease<CR>", { desc = "Increase header level" })

-- Nvim-markdown settings
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
vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "Markdown preview" })
vim.keymap.set(
	"n",
	"<leader>ml",
	"^I-<Space>[<Space>]<Space><Esc>^j",
	{ remap = true, silent = false, desc = "Make a line into a list" }
)

-- MarkdownClipboardImage settings
vim.keymap.set("n", "<leader>im", ":call mdip#MarkdownClipboardImage()<CR>", { desc = "Image" })

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

vim.api.nvim_buf_set_keymap(
	0,
	"v",
	"<Leader>bm",
	":<C-u>lua BoldMe()<CR>",
	{ noremap = true, silent = true, desc = "Bold selection" }
)

local wk = require("which-key")
wk.add({
	mode = { "n", "v", "x" },
	{ "<leader>ct", group = "Copy" },
	{ "<leader>i", group = "Image" },
	{ "<leader>m", group = "Markdown" },
})
