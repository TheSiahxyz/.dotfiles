local function augroup(name)
	return vim.api.nvim_create_augroup("TheSiahxyz_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

-- Change the color of symlink files to distinguish between directory and symlink files
local highlight_linked_files = augroup("suckless_keys")
autocmd("FileType", {
	group = highlight_linked_files,
	pattern = "netrw",
	callback = function()
		vim.cmd("highlight NetrwSymlink guifg=#689D6A ctermfg=214")
	end,
})

-- Check if we need to reload the file when it changed
local check_time = augroup("suckless_keys")
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = check_time,
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Highlight on yank
local highlight_yank = augroup("suckless_keys")
autocmd("TextYankPost", {
	group = highlight_yank,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- resize splits if window got resized
local window_config = augroup("suckless_keys")
autocmd({ "VimResized" }, {
	group = window_config,
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last loc when opening a buffer
local last_loc = augroup("suckless_keys")
autocmd("BufReadPost", {
	group = last_loc,
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].thesiahxyz_last_loc then
			return
		end
		vim.b[buf].thesiahxyz_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with <q>
local close_with_q = augroup("suckless_keys")
autocmd("FileType", {
	group = close_with_q,
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"notify",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- Make it easier to close man-files when opened inline
local man_close = augroup("suckless_keys")
autocmd("FileType", {
	group = man_close,
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- Wrap and check for spell in text filetypes
local wrap_ft = augroup("suckless_keys")
autocmd("FileType", {
	group = wrap_ft,
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Fix conceallevel for json files
local json_config = augroup("suckless_keys")
autocmd({ "FileType" }, {
	group = json_config,
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
local create_dir = augroup("suckless_keys")
autocmd({ "BufWritePre" }, {
	group = create_dir,
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Automatically delete all trailing whitespace and newlines at end of file on save
local file_save = augroup("suckless_keys")
autocmd("BufWritePre", {
	group = file_save,
	pattern = "*",
	callback = function()
		-- Remove trailing spaces
		vim.cmd([[ %s/\s\+$//e ]])
		-- Remove trailing newlines
		vim.cmd([[ %s/\n\+\%$//e ]])
	end,
})

-- Add a trailing newline for C files
autocmd("BufWritePre", {
	group = file_save,
	pattern = "*.[ch]",
	callback = function()
		vim.cmd([[ %s/\%$/\r/e ]])
	end,
})

-- Correct email signature delimiter in neomutt files
autocmd("BufWritePre", {
	group = file_save,
	pattern = "*neomutt*",
	callback = function()
		vim.cmd([[ %s/^--$/-- /e ]])
	end,
})

local function organize_imports()
	local params = {
		command = "pyright.organizeimports",
		arguments = { vim.uri_from_bufnr(0) },
	}
	vim.lsp.buf.execute_command(params)
end

autocmd("LspAttach", {
	group = augroup("lsp_attach"),
	callback = function(e)
		local client = vim.lsp.get_client_by_id(e.data.client_id)
		if client and client.name == "pyright" then
			vim.api.nvim_create_user_command(
				"PyrightOrganizeImports",
				organize_imports,
				{ desc = "Organize imports (lsp)" }
			)
		end
		vim.keymap.set("n", "gD", function()
			vim.lsp.buf.definition()
		end, { buffer = e.buf, desc = "Go to definition (lsp)" })
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover()
		end, { buffer = e.buf, desc = "Go to keywords (lsp)" })
		vim.keymap.set("n", "<leader>ls", function()
			vim.lsp.buf.workspace_symbol()
		end, { buffer = e.buf, desc = "Workspace symbol (lsp)" })
		vim.keymap.set("n", "<leader>ld", function()
			vim.diagnostic.open_float()
		end, { buffer = e.buf, desc = "Open diagnostic" })
		vim.keymap.set("n", "<leader>lc", function()
			vim.lsp.buf.code_action()
		end, { buffer = e.buf, desc = "Code action (lsp)" })
		vim.keymap.set("n", "<leader>lr", function()
			vim.lsp.buf.references()
		end, { buffer = e.buf, desc = "References (lsp)" })
		vim.keymap.set("n", "<leader>ln", function()
			vim.lsp.buf.rename()
		end, { buffer = e.buf, desc = "Rename (lsp)" })
		vim.keymap.set("i", "<leader>lh", function()
			vim.lsp.buf.signature_help()
		end, { buffer = e.buf, desc = "Signature help (lsp)" })
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.goto_next()
		end, { buffer = e.buf, desc = "Next diagnostic" })
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.goto_prev()
		end, { buffer = e.buf, desc = "Previous diagnostic" })
	end,
})

-- Save file as sudo on files that require root permission
vim.api.nvim_create_user_command("SudoWrite", function()
	vim.cmd([[
        write !sudo tee % >/dev/null
        edit!
    ]])
end, {})
vim.api.nvim_create_user_command("SudoWritequit", function()
	vim.cmd([[
        write !sudo tee % >/dev/null
        edit!
        quit!
    ]])
end, {})

-- Enable Goyo by default for mutt writing
local goyo_config = augroup("suckless_keys")
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = goyo_config,
	pattern = "/tmp/neomutt*",
	callback = function()
		vim.g.goyo_width = 80
		vim.cmd([[
            Goyo
            set bg=light
            set linebreak
            set wrap
            set textwidth=0
            set wrapmargin=0
            colorscheme seoul256
        ]])
		vim.api.nvim_buf_set_keymap(
			0,
			"n",
			"<leader>gx",
			":Goyo|x!<CR>",
			{ noremap = true, silent = true, desc = "Goyo quit" }
		)
		vim.api.nvim_buf_set_keymap(
			0,
			"n",
			"<leader>gq",
			":Goyo|q!<CR>",
			{ noremap = true, silent = true, desc = "Goyo abort" }
		)
	end,
})

-- Vimwiki
-- Ensure files are read with the desired filetype
vim.g.vimwiki_ext2syntax = {
	[".Rmd"] = "markdown",
	[".rmd"] = "markdown",
	[".md"] = "markdown",
	[".markdown"] = "markdown",
	[".mdown"] = "markdown",
}
-- Set up Vimwiki list
vim.g.vimwiki_list = { {
	path = vim.fn.expand("~/.local/share/vimwiki"),
	syntax = "markdown",
	ext = ".md",
} }

-- Markdown for specific files and directories
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "/tmp/calcurse*", "~/.calcurse/notes/*" },
	command = "set filetype=markdown",
})

-- Groff for specific file extensions
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.ms", "*.me", "*.mom", "*.man" },
	callback = function()
		vim.cmd([[
            set columns=90
			set filetype=groff
			set linebreak
			set textwidth=0
			set wrap
			set wrapmargin=0
		]])
	end,
})

-- TeX for .tex files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.tex" },
	command = "set filetype=tex",
})

-- When shortcut files are updated, renew bash and lf configs with new material:
local bookmarks = augroup("suckless_keys")
vim.api.nvim_create_autocmd("BufWritePost", {
	group = bookmarks,
	pattern = { "bm-files", "bm-dirs" },
	callback = function()
		-- Execute the 'shortcuts' shell command
		local result = vim.fn.system("shortcuts")
		-- Display an error message only if the 'shortcuts' command fails
		if vim.v.shell_error ~= 0 then
			-- Display an error message if the 'shortcuts' command fails
			vim.api.nvim_echo({ { "failed to update shortcuts: " .. result, "ErrorMsg" } }, true, {})
		end
	end,
})

-- Run xrdb whenever Xdefaults or Xresources are updated.
local x_config = augroup("suckless_keys")
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = x_config,
	pattern = { "Xresources", "Xdefaults", "xresources", "xdefaults" },
	callback = function()
		vim.bo.filetype = "xdefaults"
	end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
	group = x_config,
	pattern = { "Xresources", "Xdefaults", "xresources", "xdefaults" },
	callback = function()
		vim.cmd("silent !xrdb %")
	end,
})

-- Recompile dwmblocks on config edit.
local home = os.getenv("HOME") -- Gets the home directory
local suckless_config = augroup("suckless_keys")
vim.api.nvim_create_autocmd("BufWritePost", {
	group = suckless_config,
	pattern = home .. "/.local/src/suckless/dmenu/config.h",
	callback = function()
		vim.cmd("silent !cd " .. home .. "/.local/src/suckless/dmenu/ && sudo make install")
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = suckless_config,
	pattern = home .. "/.local/src/suckless/dwmblocks/config.h",
	callback = function()
		vim.cmd(
			"silent !cd "
				.. home
				.. "/.local/src/suckless/dwmblocks/ && sudo make install && { killall -q dwmblocks; setsid -f dwmblocks; }"
		)
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = suckless_config,
	pattern = home .. "/.local/src/suckless/slock/config.h",
	callback = function()
		vim.cmd("silent !cd " .. home .. "/.local/src/suckless/slock/ && sudo make install")
	end,
})

local suckless_keys = augroup("suckless_keys")
vim.api.nvim_create_autocmd("BufWritePost", {
	group = suckless_keys,
	pattern = home .. "/.local/src/suckless/dwm/config.h",
	callback = function()
		vim.cmd("silent !" .. home .. "/.local/bin/extractkeys")
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = suckless_keys,
	pattern = home .. "/.local/src/suckless/st/config.h",
	callback = function()
		vim.cmd("silent !" .. home .. "/.local/bin/extractkeys")
	end,
})

local suckless_doc = augroup("suckless_keys")
vim.api.nvim_create_autocmd("BufWritePost", {
	group = suckless_doc,
	pattern = home .. "/.local/src/suckless/dwm/thesiah-default.mom",
	callback = function()
		vim.cmd("silent !cd " .. home .. "/.local/src/suckless/dwm/ && rm -f thesiah.mom")
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufEnter" }, {
	pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
	callback = function()
		local suckless_path = vim.fn.expand("~/.local/src/suckless"):gsub("/+$", "")
		local file_path = vim.fn.expand("%:p"):gsub("/+$", "")
		if file_path:sub(1, #suckless_path) == suckless_path then
			vim.b.autoformat = false
		end
	end,
})
