-----------------------------------------------------------
-- Treesitter Safety Guards
--
-- On Neovim 0.11 nightly builds the treesitter highlighter
-- occasionally requests extmarks with `end_col` values that
-- exceed the actual line length, which triggers the runtime
-- error: "Invalid 'end_col': out of range".
--
-- This module patches `nvim_buf_set_extmark` for the built-in
-- treesitter namespace so those coordinates get clamped to the
-- real buffer bounds before the extmark is created.
-----------------------------------------------------------

local M = {}

function M.setup()
  if vim.g.__neotex_ts_extmark_guard_applied then
    return
  end

  local api = vim.api
  local ts_ns = api.nvim_create_namespace("nvim.treesitter.highlighter")
  local orig_set_extmark = api.nvim_buf_set_extmark

  local function clamp_position(bufnr, line, col)
    if type(line) ~= "number" then
      line = 0
    end
    if type(col) ~= "number" then
      col = 0
    end

    local line_count = api.nvim_buf_line_count(bufnr)
    local max_line_index = math.max(line_count - 1, 0)
    local new_line = math.min(math.max(line, 0), max_line_index)

    local line_text = api.nvim_buf_get_lines(bufnr, new_line, new_line + 1, true)[1] or ""
    local max_col = #line_text
    local new_col = math.min(math.max(col, 0), max_col)

    return new_line, new_col
  end

  local function clamp_opts(bufnr, opts)
    if type(opts) ~= "table" then
      return nil
    end

    local end_key = opts.end_row ~= nil and "end_row"
      or opts.end_line ~= nil and "end_line"
      or nil
    local end_line = end_key and opts[end_key] or nil
    local end_col = opts.end_col
    if end_line == nil or end_col == nil then
      return nil
    end

    local line_count = api.nvim_buf_line_count(bufnr)
    local max_line_index = math.max(line_count - 1, 0)
    local new_end_line = math.min(math.max(end_line, 0), max_line_index)

    local line_text = api.nvim_buf_get_lines(bufnr, new_end_line, new_end_line + 1, true)[1] or ""
    local max_col = #line_text
    local new_end_col = math.min(math.max(end_col, 0), max_col)

    if new_end_line == end_line and new_end_col == end_col then
      return nil
    end

    local adjusted = vim.deepcopy(opts)
    adjusted[end_key] = new_end_line
    adjusted.end_col = new_end_col
    return adjusted
  end

  local function try_set(bufnr, ns_id, line, col, opts)
    local s_line, s_col = clamp_position(bufnr, line, col)
    local ok, res = pcall(orig_set_extmark, bufnr, ns_id, s_line, s_col, opts)
    return ok, res, s_line, s_col
  end

  vim.api.nvim_buf_set_extmark = function(bufnr, ns_id, line, col, opts)
    if ns_id ~= ts_ns then
      return orig_set_extmark(bufnr, ns_id, line, col, opts)
    end

    local ok, result = try_set(bufnr, ns_id, line, col, opts)
    if ok then
      return result
    end

    local err = result
    local needs_retry = type(err) == "string"
      and (err:match("end_%s*col") or err:match("end_col") or err:match("end_row") or err:match("end_line"))

    if needs_retry then
      local fixed_opts = clamp_opts(bufnr, opts)
      if fixed_opts then
        local retry_ok, retry_res = try_set(bufnr, ns_id, line, col, fixed_opts)
        if retry_ok then
          return retry_res
        end
        err = retry_res
      end
    end

    vim.schedule(function()
      vim.notify_once(
        ("Treesitter highlight extmark failed: %s"):format(err),
        vim.log.levels.DEBUG
      )
    end)
    return nil
  end

  vim.g.__neotex_ts_extmark_guard_applied = true
end

return M
