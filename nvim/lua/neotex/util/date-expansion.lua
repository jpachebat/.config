-----------------------------------------------------------
-- Date expansion utility
-- Replaces @+N or @-N with absolute date @YYMMDD
-----------------------------------------------------------

local M = {}

-- Expand @+N or @-N to absolute date under cursor
function M.expand_relative_date()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  -- Find @+N or @-N pattern around cursor
  local before = line:sub(1, col + 1)
  local after = line:sub(col + 2)

  -- Match pattern at cursor position
  local prefix, relative_days = before:match("(.-)@([%+%-]%d+)$")

  if not relative_days then
    vim.notify("No @+N or @-N pattern found at cursor", vim.log.levels.WARN)
    return
  end

  -- Calculate target date
  local days_offset = tonumber(relative_days)
  local now = os.time()
  local target_ts = now + (days_offset * 24 * 60 * 60)
  local target_date = os.date("*t", target_ts)

  -- Format as YYMMDD
  local absolute_date = string.format("@%02d%02d%02d",
    target_date.year % 100,
    target_date.month,
    target_date.day
  )

  -- Replace in line
  local new_line = prefix .. absolute_date .. after
  vim.api.nvim_set_current_line(new_line)

  -- Move cursor to end of inserted date
  vim.api.nvim_win_set_cursor(0, {vim.api.nvim_win_get_cursor(0)[1], #prefix + #absolute_date - 1})

  -- Show confirmation
  local display_date = string.format("%04d-%02d-%02d", target_date.year, target_date.month, target_date.day)
  vim.notify(string.format("Expanded @%s → %s (%s)", relative_days, absolute_date, display_date), vim.log.levels.INFO)
end

return M
