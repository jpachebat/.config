local M = {}

-- Open vertical split with the same file, positioned at the end of ## todo section
function M.open_todo_split()
  local current_file = vim.api.nvim_buf_get_name(0)

  if current_file == "" then
    vim.notify("No file open", vim.log.levels.WARN)
    return
  end

  -- Read current buffer content
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Find ## todo section (case-insensitive)
  local todo_start = nil
  local todo_end = nil

  for i, line in ipairs(lines) do
    if line:lower():match("^##%s+todo%s*$") then
      todo_start = i
    elseif todo_start and line:match("^##%s+") then
      -- Found next section of same level, end of todo section
      todo_end = i - 1
      break
    end
  end

  -- If found todo section but no end, end is last line
  if todo_start and not todo_end then
    todo_end = #lines
  end

  if not todo_start then
    vim.notify("No '## todo' section found in current file", vim.log.levels.WARN)
    return
  end

  -- Open vertical split
  vim.cmd("vsplit " .. vim.fn.fnameescape(current_file))

  -- Move to end of todo section
  vim.api.nvim_win_set_cursor(0, {todo_end, 0})

  -- Center the view
  vim.cmd("normal! zz")

  -- Optional: Enter insert mode at end of line to add new todo
  vim.cmd("normal! A")
end

return M
