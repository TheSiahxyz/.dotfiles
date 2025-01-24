local api = vim.api
local ch = require("thesiahxyz.utils.cheatsheet.init")
local state = ch.state

local ascii = {
	"                                      ",
	"                                      ",
	"█▀▀ █░█ █▀▀ ▄▀█ ▀█▀ █▀ █░█ █▀▀ █▀▀ ▀█▀",
	"█▄▄ █▀█ ██▄ █▀█ ░█░ ▄█ █▀█ ██▄ ██▄ ░█░",
	"                                      ",
	"                                      ",
}

return function(buf, win, action)
	action = action or "open"

	local ns = api.nvim_create_namespace("thesiah_cheatsheet")

	if action == "open" then
		state.mappings_tb = ch.organize_mappings()

		buf = buf or api.nvim_create_buf(false, true)
		win = win or api.nvim_get_current_win()

		api.nvim_set_current_win(win)

		-- Calculate maximum widths for lhs and rhs
		local lhs_max_width, rhs_max_width = 0, 0
		for _, section in pairs(state.mappings_tb) do
			for _, mapping in ipairs(section) do
				lhs_max_width = math.max(lhs_max_width, vim.fn.strdisplaywidth(mapping[1]))
				rhs_max_width = math.max(rhs_max_width, vim.fn.strdisplaywidth(mapping[2]))
			end
		end

		local total_width = lhs_max_width + rhs_max_width + 6 -- Add spacing for readability
		local center_offset = math.floor((total_width - vim.fn.strdisplaywidth(ascii[1])) / 2)

		-- Align ASCII art to the center
		local ascii_header = vim.tbl_values(ascii)
		for i, line in ipairs(ascii_header) do
			ascii_header[i] = string.rep(" ", center_offset) .. line
		end

		-- Center-align the title
		local title = "Cheatsheet"
		local title_padding = math.floor((total_width - vim.fn.strdisplaywidth(title)) / 2)
		local title_line = string.rep(" ", title_padding) .. title

		-- Prepare buffer lines
		local lines = {}
		for _, line in ipairs(ascii_header) do
			table.insert(lines, line)
		end
		table.insert(lines, "") -- Blank line after ASCII art
		table.insert(lines, title_line)
		table.insert(lines, "") -- Blank line after title

		-- Add mappings grouped by section
		for section_name, mappings in pairs(state.mappings_tb) do
			-- Center-align the section name
			local section_padding = math.floor((total_width - vim.fn.strdisplaywidth(section_name)) / 2)
			table.insert(lines, string.rep(" ", section_padding) .. section_name) -- Section header

			-- Add mappings aligned to lhs and rhs
			for _, mapping in ipairs(mappings) do
				local lhs = mapping[1]
				local rhs = mapping[2]
				local lhs_padding = string.rep(" ", lhs_max_width - vim.fn.strdisplaywidth(lhs))
				local rhs_padding = string.rep(" ", rhs_max_width - vim.fn.strdisplaywidth(rhs))
				table.insert(lines, lhs .. lhs_padding .. "  " .. rhs_padding .. rhs)
			end
			table.insert(lines, "") -- Blank line after each section
		end

		-- Set lines into the buffer
		api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		-- Highlight ASCII art and title
		for i = 1, #ascii_header do
			api.nvim_buf_add_highlight(buf, ns, "ThesiahAsciiHeader", i - 1, 0, -1)
		end
		api.nvim_buf_add_highlight(buf, ns, "Title", #ascii + 1, 0, -1)

		-- Highlight section headers
		local current_line = #ascii + 3 -- Adjust for blank lines and title
		for section_name, mappings in pairs(state.mappings_tb) do
			api.nvim_buf_add_highlight(buf, ns, "ThesiahSection", current_line, 0, -1)
			current_line = current_line + #mappings + 2 -- Count section header, mappings, and blank line
		end

		-- Configure the buffer
		vim.bo[buf].modifiable = false
		vim.bo[buf].readonly = false
		vim.bo[buf].buftype = ""
		vim.bo[buf].buflisted = true
		vim.bo[buf].filetype = "cheatsheet"

		-- Set up autocmds for the cheatsheet
		ch.autocmds(buf, win)

		-- Focus on the cheatsheet buffer
		api.nvim_set_current_buf(buf)
	end
end
