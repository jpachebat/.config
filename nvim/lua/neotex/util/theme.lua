local M = {}

local uv = vim.uv or vim.loop
local state_path = vim.fn.expand("~/.config/theme/current")
local state_dir = vim.fn.fnamemodify(state_path, ":h")
local watcher
local command_registered = false
local macos_timer
local last_macos_theme = nil

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

-- Detect macOS system theme
local function get_macos_theme()
  -- Check if we're on macOS
  if vim.fn.has("mac") == 0 then
    return nil
  end

  -- Run macOS command to get system theme
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  if not handle then
    return nil
  end

  local result = handle:read("*a")
  handle:close()

  -- If result contains "Dark", system is in dark mode
  if result and result:match("Dark") then
    return "dark"
  end

  -- Otherwise, light mode
  return "light"
end

-- Sync with macOS system theme
local function sync_with_macos()
  local macos_theme = get_macos_theme()

  if not macos_theme then
    return -- Not on macOS or detection failed
  end

  -- Only update if theme changed
  if macos_theme ~= last_macos_theme then
    last_macos_theme = macos_theme
    M.write(macos_theme)
    -- Note: The file watcher will automatically call M.sync() and apply the theme
  end
end

-- Start periodic macOS theme checking
local function start_macos_sync()
  if not uv or not uv.new_timer then
    return
  end

  if vim.fn.has("mac") == 0 then
    return -- Only on macOS
  end

  -- Initial sync
  sync_with_macos()

  -- Check every 3 seconds for macOS theme changes
  macos_timer = uv.new_timer()
  macos_timer:start(3000, 3000, vim.schedule_wrap(function()
    sync_with_macos()
  end))
end

-- Stop macOS theme checking
local function stop_macos_sync()
  if macos_timer then
    macos_timer:stop()
    macos_timer:close()
    macos_timer = nil
  end
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
  -- Set background first
  vim.opt.background = mode
  -- Force reload kanagawa colorscheme
  vim.cmd("colorscheme kanagawa")
  -- Ensure background sticks (some plugins reset it)
  vim.opt.background = mode
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

  -- Watch for manual :ThemeSync commands
  start_watcher()

  -- Run :ThemeSync after everything loads
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      -- Sync with macOS theme
      if vim.fn.has("mac") == 1 then
        local macos_theme = get_macos_theme()
        if macos_theme then
          M.write(macos_theme)
        end
      end
      -- Apply the theme
      M.sync()
    end,
  })

  -- Cleanup on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = stop_watcher,
  })
end

return M
