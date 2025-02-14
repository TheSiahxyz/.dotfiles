local function augroup(name)
	return vim.api.nvim_create_augroup("TheSiahxyz_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

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

-- resize splits if window got resized
autocmd({ "VimResized" }, {
	group = augroup("window_config"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
	group = augroup("last_loc"),
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
autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"checkhealth",
		"help",
		"lspinfo",
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
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
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

-- Start insert mode in terminal
autocmd("TermOpen", {
	group = augroup("terminal"),
	pattern = "*",
	callback = function()
		vim.cmd("startinsert")
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

-- Wrap and check for spell in text filetypes
autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
		vim.opt_local.spelllang = { "en", "cjk" }
		vim.opt_local.spellsuggest = { "best", "9" }
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
vim.api.nvim_create_autocmd("BufWritePost", {
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
vim.api.nvim_create_autocmd("BufWritePost", {
	group = lf_config,
	pattern = { "lfrc" },
	callback = function()
		vim.cmd("silent !source ~/.config/lf/lfrc")
	end,
})

-- Run xrdb whenever Xdefaults or Xresources are updated.
local x_config = augroup("x_config")
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

-- Recompile suckless programs on config edit.
local home = os.getenv("HOME")
local suckless_config = vim.api.nvim_create_augroup("suckless_config", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
	group = suckless_config,
	pattern = home .. "/.local/src/suckless/dmenu/config.def.h",
	callback = function()
		vim.cmd("silent !cd " .. home .. "/.local/src/suckless/dmenu/ && sudo make install")
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = suckless_config,
	pattern = home .. "/.local/src/suckless/dwmblocks/config.def.h",
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
	pattern = home .. "/.local/src/suckless/slock/config.def.h",
	callback = function()
		vim.cmd("silent !cd " .. home .. "/.local/src/suckless/slock/ && sudo make install")
	end,
})

local suckless_keys = augroup("suckless_keys")
vim.api.nvim_create_autocmd("BufWritePost", {
	group = suckless_keys,
	pattern = home .. "/.local/src/suckless/dwm/config.def.h",
	callback = function()
		vim.cmd("silent !" .. home .. "/.local/bin/extractkeys")
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = suckless_keys,
	pattern = home .. "/.local/src/suckless/st/config.def.h",
	callback = function()
		vim.cmd("silent !" .. home .. "/.local/bin/extractkeys")
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = augroup("suckless_doc"),
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
