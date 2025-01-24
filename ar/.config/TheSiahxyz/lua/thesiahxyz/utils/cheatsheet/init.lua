local M = {}
local api = vim.api
local config = require("thesiahxyz.utils.cheatsheet") -- Load cheatsheet options

local function capitalize(str)
	return (str:gsub("^%l", string.upper))
end

M.get_mappings = function(mappings, tb_to_add)
	local excluded_groups = config.cheatsheet.excluded_groups

	for _, v in ipairs(mappings) do
		local desc = v.desc

		if not desc or (select(2, desc:gsub("%S+", "")) <= 1) or string.find(desc, "\n") then
			goto continue
		end

		local heading = desc:match("%S+") -- Get first word
		heading = (v.mode ~= "n" and heading .. " (" .. v.mode .. ")") or heading

		if
			vim.tbl_contains(excluded_groups, heading)
			or vim.tbl_contains(excluded_groups, desc:match("%S+"))
			or string.find(v.lhs, "<Plug>")
		then
			goto continue
		end

		heading = capitalize(heading)

		if not tb_to_add[heading] then
			tb_to_add[heading] = {}
		end

		local keybind = string.sub(v.lhs, 1, 1) == " " and "<leader> +" .. v.lhs or v.lhs

		desc = v.desc:match("%s(.+)") -- Remove first word from description
		desc = capitalize(desc)

		table.insert(tb_to_add[heading], { desc, keybind })

		::continue::
	end
end

M.organize_mappings = function()
	local tb_to_add = {}
	local modes = { "n", "i", "v", "t" }

	for _, mode in ipairs(modes) do
		local keymaps = api.nvim_get_keymap(mode)
		M.get_mappings(keymaps, tb_to_add)

		local bufkeymaps = api.nvim_buf_get_keymap(0, mode)
		M.get_mappings(bufkeymaps, tb_to_add)
	end

	return tb_to_add
end

M.rand_hlgroup = function()
	local hlgroups = {
		"blue",
		"red",
		"green",
		"yellow",
		"orange",
		"baby_pink",
		"purple",
		"white",
		"cyan",
		"vibrant_green",
		"teal",
	}

	return "ThesiahHead" .. hlgroups[math.random(1, #hlgroups)]
end

M.autocmds = function(buf, win)
	-- Set buffer options to make it searchable and navigable
	vim.bo[buf].buflisted = true
	vim.bo[buf].buftype = "" -- Treat it as a regular buffer
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false -- Prevent accidental edits
	vim.bo[buf].readonly = false -- Enable navigation and search
	vim.bo[buf].filetype = "cheatsheet" -- Optional, to customize behavior

	-- Create autocmd group for cheatsheet
	local group_id = api.nvim_create_augroup("ThesiahCheatsheet", { clear = true })

	-- Clean up when buffer is closed
	api.nvim_create_autocmd("BufWinLeave", {
		group = group_id,
		buffer = buf,
		callback = function()
			vim.g.thesiah_cheatsheet_displayed = false
			api.nvim_del_augroup_by_id(group_id)
		end,
	})

	-- Keymaps for cheatsheet buffer
	vim.keymap.set("n", "q", function()
		api.nvim_buf_delete(buf, { force = true })
	end, { buffer = buf })

	vim.keymap.set("n", "<ESC>", function()
		api.nvim_buf_delete(buf, { force = true })
	end, { buffer = buf })
end

M.state = {
	mappings_tb = {},
}

return M
