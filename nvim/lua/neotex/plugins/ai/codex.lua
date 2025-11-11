local M = {}

local codex_term
local commands_created = false

local function notify_missing_toggleterm()
  vim.notify("Codex toggle requires toggleterm.nvim", vim.log.levels.WARN)
end

local function set_buffer_name(bufnr)
  local base_name = "term://codex"
  local ok = true

  if vim.api.nvim_buf_get_name(bufnr) ~= base_name then
    ok = pcall(vim.api.nvim_buf_set_name, bufnr, base_name)
  end

  -- Fall back to a unique name if another buffer already claimed the base name.
  if not ok then
    vim.api.nvim_buf_set_name(bufnr, string.format("%s-%d", base_name, bufnr))
  end
end

local function ensure_terminal()
  if codex_term then
    return codex_term
  end

  local ok, terminal = pcall(require, "toggleterm.terminal")
  if not ok then
    notify_missing_toggleterm()
    return nil
  end

  local Terminal = terminal.Terminal

  codex_term = Terminal:new({
    cmd = "codex",
    direction = "vertical",
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    close_on_exit = false,
    hidden = true,
    on_open = function(term)
      vim.bo[term.bufnr].buflisted = false
      vim.bo[term.bufnr].buftype = "terminal"
      vim.bo[term.bufnr].bufhidden = "hide"
      set_buffer_name(term.bufnr)
      vim.cmd("startinsert!")
    end,
  })

  _G.codex_smart_toggle = function()
    codex_term:toggle()
  end

  if not commands_created then
    vim.api.nvim_create_user_command('CodexToggle', function()
      M.toggle()
    end, { desc = "Toggle Codex terminal" })

    vim.api.nvim_create_user_command('CodexOpen', function()
      M.open()
    end, { desc = "Open Codex terminal" })

    vim.api.nvim_create_user_command('CodexClose', function()
      M.close()
    end, { desc = "Close Codex terminal" })

    commands_created = true
  end

  return codex_term
end

function M.setup()
  ensure_terminal()
end

function M.toggle()
  local term = ensure_terminal()
  if term then
    term:toggle()
  end
end

function M.open()
  local term = ensure_terminal()
  if term then
    term:open()
  end
end

function M.close()
  local term = ensure_terminal()
  if term then
    term:close()
  end
end

return M
