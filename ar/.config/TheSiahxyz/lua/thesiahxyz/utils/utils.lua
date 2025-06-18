-- ~/.config/nvim/lua/thesiahxyz/utils/utils.lua
local M = {}

function M.print_current_file_dir()
	local dir = vim.fn.expand("%:p:h")
	if dir ~= "" then
		print(dir)
	end
end

function M.reload_module(name)
	package.loaded[name] = nil
	return require(name)
end

-- Function to reload the current Lua file
function M.reload_current_file()
	local current_file = vim.fn.expand("%:p")

	if current_file:match("%.lua$") then
		vim.cmd("luafile " .. current_file)
		print("Reloaded file: " .. current_file)
	else
		print("Current file is not a Lua file: " .. current_file)
	end
end

function M.insert_file_path()
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	require("telescope.builtin").find_files({
		cwd = "~/.config", -- Set the directory to search
		attach_mappings = function(_, map)
			map("i", "<CR>", function(prompt_bufnr)
				local selected_file = action_state.get_selected_entry(prompt_bufnr).path
				actions.close(prompt_bufnr)

				-- Replace the home directory with ~
				selected_file = selected_file:gsub(vim.fn.expand("$HOME"), "~")

				-- Ask the user if they want to insert the full path or just the file name
				local choice = vim.fn.input("Insert full path or file name? (n[ame]/p[ath]): ")
				local text_to_insert
				if choice == "p" then
					text_to_insert = selected_file
				elseif choice == "n" then
					text_to_insert = vim.fn.fnamemodify(selected_file, ":t")
				end

				-- Move the cursor back one position
				local col = vim.fn.col(".") - 1
				vim.fn.cursor(vim.fn.line("."), col)

				-- Insert the text at the cursor position
				vim.api.nvim_put({ text_to_insert }, "c", true, true)
			end)
			return true
		end,
	})
end

vim.api.nvim_set_keymap(
	"i",
	"<C-v>",
	"<cmd>lua require('thesiahxyz.utils.utils').insert_file_path()<cr>",
	{ noremap = true, silent = true }
)
function M.create_floating_scratch(content)
	-- Get editor dimensions
	local width = vim.api.nvim_get_option_value("columns", {})
	local height = vim.api.nvim_get_option_value("lines", {})

	-- Calculate the floating window size
	local win_height = math.ceil(height * 0.8) + 2 -- Adding 2 for the border
	local win_width = math.ceil(width * 0.8) + 2 -- Adding 2 for the border

	-- Calculate window's starting position
	local row = math.ceil((height - win_height) / 2)
	local col = math.ceil((width - win_width) / 2)

	-- Create a buffer and set it as a scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("filetype", "sh", { buf = buf }) -- for syntax highlighting

	-- Create the floating window with a border and set some options
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = win_width,
		height = win_height,
		border = "single", -- You can also use 'double', 'rounded', or 'solid'
	})

	-- Check if we've got content to populate the buffer with
	if content then
		vim.api.nvim_buf_set_lines(buf, 0, -1, true, content)
	else
		vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "This is a scratch buffer in a floating window." })
	end

	vim.api.nvim_set_option_value("wrap", false, { win = win })
	vim.api.nvim_set_option_value("cursorline", true, { win = win })

	-- Map 'q' to close the buffer in this window
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q!<CR>", { noremap = true, silent = true })
end

return M
