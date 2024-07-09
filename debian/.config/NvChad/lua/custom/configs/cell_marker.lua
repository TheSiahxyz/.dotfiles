local M = {}

M.get_commenter = function()
  local commenter = { python = "# ", lua = "-- ", julia = "# ", fennel = ";; ", scala = "// ", r = "# " }
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if ft == nil or ft == "" then
    return commenter["python"]
  elseif commenter[ft] == nil then
    return commenter["python"]
  end

  return commenter[ft]
end

local CELL_MARKER = M.get_commenter() .. "%%"
vim.api.nvim_set_hl(0, "CellMarkerHl", { default = true, bg = "#c5c5c5", fg = "#111111" })

M.miniai_spec = function(mode)
  local start_line = vim.fn.search("^" .. CELL_MARKER, "bcnW")

  if start_line == 0 then
    start_line = 1
  else
    if mode == "i" then
      start_line = start_line + 1
    end
  end

  local end_line = vim.fn.search("^" .. CELL_MARKER, "nW") - 1
  if end_line == -1 then
    end_line = vim.fn.line "$"
  end

  local last_col = math.max(vim.fn.getline(end_line):len(), 1)

  local from = { line = start_line, col = 1 }
  local to = { line = end_line, col = last_col }

  return { from = from, to = to }
end

M.show_cell_markers = function()
  require("mini.hipatterns").enable(0, {
    highlighters = {
      marker = { pattern = "^" .. M.get_commenter() .. "%%%%", group = "CellMarkerHl" },
    },
  })
end

M.select_cell = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_row = vim.api.nvim_win_get_cursor(0)[1]
  local current_col = vim.api.nvim_win_get_cursor(0)[2]

  local start_line = nil
  local end_line = nil

  for line = current_row, 1, -1 do
    local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    if line_content:find("^" .. CELL_MARKER) then
      start_line = line
      break
    end
  end
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for line = current_row + 1, line_count do
    local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    if line_content:find("^" .. CELL_MARKER) then
      end_line = line
      break
    end
  end

  if not start_line then
    start_line = 1
  end
  if not end_line then
    end_line = line_count
  end
  return current_row, current_col, start_line, end_line
end

M.execute_cell = function()
  local current_row, current_col, start_line, end_line = M.select_cell()
  if start_line and end_line then
    vim.fn.setpos("'<", { 0, start_line + 1, 0, 0 })
    vim.fn.setpos("'>", { 0, end_line - 1, 0, 0 })
    require("iron.core").visual_send()
    vim.api.nvim_win_set_cursor(0, { current_row, current_col })
  end
end

M.delete_cell = function()
  local _, _, start_line, end_line = M.select_cell()
  if start_line and end_line then
    local rows_to_select = end_line - start_line - 1
    vim.api.nvim_win_set_cursor(0, { start_line, 0 })
    vim.cmd("normal!V " .. rows_to_select .. "j")
    vim.cmd "normal!d"
    vim.cmd "normal!k"
  end
end

M.navigate_cell = function(up)
  local is_up = up or false
  local _, _, start_line, end_line = M.select_cell()
  if is_up and start_line ~= 1 then
    vim.api.nvim_win_set_cursor(0, { start_line - 1, 0 })
  elseif end_line then
    local bufnr = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if end_line ~= line_count then
      vim.api.nvim_win_set_cursor(0, { end_line + 1, 0 })
      _, _, start_line, end_line = M.select_cell()
      vim.api.nvim_win_set_cursor(0, { end_line - 1, 0 })
    end
  end
end

M.move_cell = function(dir)
  local search_res
  local result
  if dir == "d" then
    search_res = vim.fn.search("^" .. CELL_MARKER, "W")
    if search_res == 0 then
      result = "last"
    end
  else
    search_res = vim.fn.search("^" .. CELL_MARKER, "bW")
    if search_res == 0 then
      result = "first"
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
    end
  end

  return result
end

M.insert_cell_before = function(content)
  content = content or CELL_MARKER
  local cell_object = M.miniai_spec "a"
  vim.api.nvim_buf_set_lines(0, cell_object.from.line - 1, cell_object.from.line - 1, false, { content, "" })
  M.move_cell "u"
end

M.insert_cell_after = function(content)
  content = content or CELL_MARKER
  vim.print(content)
  local cell_object = M.miniai_spec "a"
  vim.api.nvim_buf_set_lines(0, cell_object.to.line, cell_object.to.line, false, { content, "" })
  M.move_cell "d"
end

M.insert_markdown_cell = function()
  M.insert_cell_after(CELL_MARKER .. " [markdown]")
end

return M
