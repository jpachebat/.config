local M = {}

local uv = vim.uv or vim.loop
local state_path = vim.fn.expand("~/.config/theme/current")
local state_dir = vim.fn.fnamemodify(state_path, ":h")
local watcher
local command_registered = false

local function ensure_state_file()
  if vim.fn.isdirectory(state_dir) == 0 then
    vim.fn.mkdir(state_dir, "p")
  end
  if vim.fn.filereadable(state_path) == 0 then
    vim.fn.writefile({ "light" }, state_path)
  end
end

local function normalize(mode)
  if mode == "dark" then
    return "dark"
  end
  return "light"
end

function M.read()
  if vim.fn.filereadable(state_path) == 0 then
    return "light"
  end
  local ok, lines = pcall(vim.fn.readfile, state_path)
  if not ok or not lines or #lines == 0 then
    return "light"
  end
  local value = lines[1] or "light"
  value = value:gsub("%s+", "")
  return normalize(value)
end

function M.write(mode)
  mode = normalize(mode)
  ensure_state_file()
  local ok, err = pcall(vim.fn.writefile, { mode }, state_path)
  if not ok then
    error(err)
  end
  return mode
end

function M.apply(mode)
  mode = normalize(mode)
  vim.opt.background = mode
  vim.cmd("colorscheme kanagawa")
  return mode
end

function M.sync()
  local mode = M.read()
  M.apply(mode)
  return mode
end

local function start_watcher()
  if watcher or not uv or not uv.new_fs_event then
    return
  end
  watcher = uv.new_fs_event()
  watcher:start(state_path, {}, vim.schedule_wrap(function()
    M.sync()
  end))
end

local function stop_watcher()
  if watcher then
    watcher:stop()
    watcher:close()
    watcher = nil
  end
end

local function register_command()
  if command_registered then
    return
  end
  vim.api.nvim_create_user_command("ThemeSync", function(opts)
    local arg = opts.args
    if arg == "" then
      M.sync()
      return
    end
    local mode = normalize(arg)
    local ok, err = pcall(M.write, mode)
    if not ok then
      vim.notify(string.format("ThemeSync write failed: %s", err), vim.log.levels.ERROR)
    end
    M.apply(mode)
  end, {
    nargs = "?",
    complete = function()
      return { "light", "dark" }
    end,
  })
  command_registered = true
end

function M.setup()
  ensure_state_file()
  register_command()
  M.sync()
  start_watcher()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = stop_watcher,
  })
end

return M
