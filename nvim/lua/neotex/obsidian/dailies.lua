local M = {}

local SECONDS_PER_DAY = 24 * 60 * 60

local function ensure_client(opts)
  opts = opts or {}

  if opts.ensure_loaded ~= false then
    local ok_lazy, lazy = pcall(require, "lazy")
    if ok_lazy then
      pcall(lazy.load, lazy, { plugins = { "obsidian.nvim" }, wait = true })
    end
  end

  local ok_obsidian, obsidian = pcall(require, "obsidian")
  if not ok_obsidian then
    vim.notify("obsidian.nvim is not available", vim.log.levels.ERROR)
    return nil
  end

  local ok_client, client = pcall(obsidian.get_client)
  if not ok_client or not client then
    vim.notify("Obsidian client is not ready", vim.log.levels.ERROR)
    return nil
  end

  return client
end

function M.is_daily_note(client, note)
  if not client or not note then
    return false
  end

  local folder = client.opts and client.opts.daily_notes and client.opts.daily_notes.folder
  if not folder or not note.path then
    return false
  end

  local daily_dir = client.dir / folder
  local parent = note.path:parent()
  if parent and tostring(parent) == tostring(daily_dir) then
    return true
  end

  if daily_dir.is_parent_of and daily_dir:is_parent_of(note.path) then
    return true
  end

  return false
end

function M.note_id_to_timestamp(note_id)
  if not note_id then
    return nil
  end

  local year, month, day = tostring(note_id):match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
  if not year then
    return nil
  end

  return os.time {
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = 12,
  }
end

function M.weekday_from_id(note_id)
  local timestamp = M.note_id_to_timestamp(note_id)
  if not timestamp then
    return nil
  end
  return os.date("%a", timestamp)
end

function M.ensure_daily_heading(client, note)
  if not M.is_daily_note(client, note) then
    return
  end

  local weekday = M.weekday_from_id(note and note.id)
  if not weekday then
    return
  end

  local alias = nil
  if note.aliases and #note.aliases > 0 then
    alias = note.aliases[#note.aliases]
  end
  local base_title = alias and alias ~= "" and alias or note.title or tostring(note.id)
  if not base_title or base_title == "" then
    return
  end

  -- Remove weekday from base_title if it already starts with it
  -- This prevents "Wed Wed Wed..." bug on repeated opens
  local weekday_pattern = "^" .. weekday .. "%s+"
  base_title = base_title:gsub(weekday_pattern, "")

  local bufnr = note.bufnr
  if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  local desired_heading = string.format("# %s %s", weekday, base_title)
  local start_line = 0
  if note.frontmatter_end_line and note.frontmatter_end_line > 0 then
    start_line = note.frontmatter_end_line
  end

  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  local fetch_end = math.min(total_lines, start_line + 12)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, fetch_end, false)

  for idx, line in ipairs(lines) do
    if line:match("^#%s+") then
      local header_line = start_line + idx - 1
      if line ~= desired_heading then
        vim.api.nvim_buf_set_lines(bufnr, header_line, header_line + 1, false, { desired_heading })
      end
      return
    end
  end

  local insert_line = start_line
  if lines[1] ~= nil and lines[1]:match("^%s*$") then
    insert_line = insert_line + 1
  end
  vim.api.nvim_buf_set_lines(bufnr, insert_line, insert_line, false, { desired_heading, "" })
end

function M.open_daily(offset, opts)
  opts = opts or {}
  offset = offset or 0

  local client = ensure_client(opts)
  if not client then
    return
  end

  local note
  if opts.ignore_current ~= true then
    local current_note = client:current_note()
    if current_note and M.is_daily_note(client, current_note) then
      local timestamp = M.note_id_to_timestamp(current_note.id)
      if timestamp then
        note = client:_daily(timestamp + (offset * SECONDS_PER_DAY))
      end
    end
  end

  if not note then
    note = client:daily(offset)
  end

  if note then
    client:open_note(note)
  else
    vim.notify("Unable to open requested daily note", vim.log.levels.WARN)
  end
end

return M
