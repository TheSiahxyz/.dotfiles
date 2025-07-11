local function augroup(name)
	return vim.api.nvim_create_augroup("TheSiahxyz_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd
local home = os.getenv("HOME")

-- Change the color of symlink files to distinguish between directory and symlink files
autocmd("FileType", {
	group = augroup("highlight_linked_files"),
	pattern = "netrw",
	callback = function()
		vim.cmd("highlight NetrwSymlink guifg=#689D6A ctermfg=214")
	end,
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("check_time"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Resize splits if window got resized
autocmd({ "VimResized" }, {
	group = augroup("window_config"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- Go to last loc when opening a buffer
autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].TheSiahxyz_last_loc then
			return
		end
		vim.b[buf].TheSiahxyz_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"checkhealth",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"Lazy",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"PlenaryTestPopup",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"terminal",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<Cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})
autocmd("FileType", {
	group = augroup("q_as_bd"),
	pattern = "netrw",
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", function()
			vim.cmd("bd")
		end, { buffer = event.buf, silent = true })
	end,
})

-- Make it easier to close man-files when opened inline
autocmd("FileType", {
	group = augroup("man_close"),
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- Fix conceallevel for json files
autocmd({ "FileType" }, {
	group = augroup("json_config"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
	group = augroup("create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- Automatically delete all trailing whitespace and newlines at end of file on save
local file_save = augroup("file_save")
autocmd("BufWritePre", {
	group = file_save,
	pattern = "*",
	callback = function()
		local cursor_pos = vim.api.nvim_win_get_cursor(0)
		vim.cmd([[ %s/\s\+$//e ]]) -- Remove trailing spaces
		vim.cmd([[ %s/\n\+\%$//e ]]) -- Remove trailing newlines
		local line_count = vim.api.nvim_buf_line_count(0)
		local line = math.min(cursor_pos[1], line_count)
		local col = cursor_pos[2]
		-- Optional: clamp column if line got shorter
		local line_text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
		col = math.min(col, #line_text)
		vim.api.nvim_win_set_cursor(0, { line, col })
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

-- Go to insert mode in terminal
local win_enter = augroup("win_enter")
autocmd("WinEnter", {
	group = win_enter,
	callback = function()
		if vim.bo.buftype == "terminal" then
			vim.cmd("startinsert")
		end
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
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		client:exec_cmd(params, { bufnr = 0 })
	end
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
		vim.keymap.set("n", "<leader>lo", function()
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
		vim.keymap.set("n", "<leader>lh", function()
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
        write !sudo tee % 2>/dev/null
        edit!
    ]])
end, {})
vim.api.nvim_create_user_command("SudoWritequit", function()
	vim.cmd([[
        write !sudo tee % 2>/dev/null
        edit!
        quit!
    ]])
end, {})

-- Markdown for specific files and directories
autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "/tmp/calcurse*", "~/.calcurse/notes/*" },
	command = "set filetype=markdown",
})

-- Groff for specific file extensions
autocmd({ "BufRead", "BufNewFile" }, {
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
autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.tex" },
	command = "set filetype=tex",
})

-- When shortcut files are updated, renew bash and lf configs with new material:
autocmd("BufWritePost", {
	group = augroup("bookmarks"),
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

-- Source lfrc if it's edited
local lf_config = augroup("lf_config")
autocmd("BufWritePost", {
	group = lf_config,
	pattern = { "lfrc" },
	callback = function()
		vim.cmd("silent !source ~/.config/lf/lfrc")
	end,
})

-- Set vimwiki's index filetype to vimwiki instead of markdown
local vimwiki_config = augroup("vimwiki_config")
autocmd({ "BufRead", "BufNewFile" }, {
	group = vimwiki_config,
	pattern = vim.fn.expand("~/.local/share/vimwiki") .. "/**/*.md",
	callback = function(args)
		vim.bo[args.buf].filetype = "vimwiki"
	end,
})

-- Run xrdb whenever Xdefaults or Xresources are updated.
local x_config = augroup("x_config")
autocmd({ "BufRead", "BufNewFile" }, {
	group = x_config,
	pattern = { "Xresources", "Xdefaults", "xresources", "xdefaults" },
	callback = function()
		vim.bo.filetype = "xdefaults"
	end,
})
autocmd("BufWritePost", {
	group = x_config,
	pattern = { "Xresources", "Xdefaults", "xresources", "xdefaults" },
	callback = function()
		vim.cmd("silent !xrdb %")
	end,
})

-- Recompile suckless programs on config edit.
local suckless_config = vim.api.nvim_create_augroup("suckless_config", { clear = true })
autocmd("BufWritePost", {
	group = suckless_config,
	pattern = home .. "/.local/src/suckless/dmenu/config.def.h",
	callback = function()
		vim.cmd("silent !cd " .. home .. "/.local/src/suckless/dmenu/ && sudo make clean install && rm -f config.h")
	end,
})

autocmd("BufWritePost", {
	group = suckless_config,
	pattern = home .. "/.local/src/suckless/dwmblocks/config.def.h",
	callback = function()
		vim.cmd(
			"silent !cd "
				.. home
				.. "/.local/src/suckless/dwmblocks/ && sudo make clean install && rm -f config.h && { killall -q dwmblocks; setsid -f dwmblocks; }"
		)
	end,
})

autocmd("BufWritePost", {
	group = suckless_config,
	pattern = home .. "/.local/src/suckless/slock/config.def.h",
	callback = function()
		vim.cmd("silent !cd " .. home .. "/.local/src/suckless/slock/ && sudo make clean install && rm -f config.h")
	end,
})

local suckless_keys = augroup("suckless_keys")
autocmd("BufWritePost", {
	group = suckless_keys,
	pattern = { home .. "/.local/src/suckless/dwm/config.def.h", home .. "/.local/src/suckless/st/config.def.h" },
	callback = function()
		local choice = vim.fn.confirm("Extract key bindings?", "&Yes\n&No", 2)
		if choice == 1 then
			vim.cmd("silent !" .. home .. "/.local/bin/extractkeys")
		end
	end,
})

autocmd("BufWritePost", {
	group = augroup("suckless_doc"),
	pattern = home .. "/.local/src/suckless/dwm/thesiah-default.mom",
	callback = function()
		vim.cmd("silent !cd " .. home .. "/.local/src/suckless/dwm/ && rm -f thesiah.mom")
	end,
})

autocmd({ "BufRead", "BufEnter" }, {
	pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
	callback = function()
		local suckless_path = vim.fn.expand("~/.local/src/suckless"):gsub("/+$", "")
		local file_path = vim.fn.expand("%:p"):gsub("/+$", "")
		if file_path:sub(1, #suckless_path) == suckless_path then
			vim.b.autoformat = false
		end
	end,
})
