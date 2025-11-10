local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Get all files in outputs/ directory sorted by modification time
local function get_output_files(outputs_dir)
  if vim.fn.isdirectory(outputs_dir) == 0 then
    return {}
  end

  -- Find all files recursively in outputs/
  local find_command = string.format(
    "find %s -type f -exec stat -f '%%m %%N' {} \\; 2>/dev/null | sort -rn | cut -d' ' -f2-",
    vim.fn.shellescape(outputs_dir)
  )

  local handle = io.popen(find_command)
  if not handle then
    return {}
  end

  local result = handle:read("*a")
  handle:close()

  local files = {}
  for file in result:gmatch("[^\r\n]+") do
    if file and file ~= "" then
      table.insert(files, file)
    end
  end

  return files
end

-- Get file modification time for display
local function get_file_mtime_display(filepath)
  local stat = vim.loop.fs_stat(filepath)
  if not stat then
    return "Unknown"
  end

  local mtime = stat.mtime.sec
  local now = os.time()
  local diff = now - mtime

  if diff < 60 then
    return string.format("%ds ago", diff)
  elseif diff < 3600 then
    return string.format("%dm ago", math.floor(diff / 60))
  elseif diff < 86400 then
    return string.format("%dh ago", math.floor(diff / 3600))
  elseif diff < 604800 then
    return string.format("%dd ago", math.floor(diff / 86400))
  else
    return os.date("%Y-%m-%d %H:%M", mtime)
  end
end

-- Create Telescope picker for outputs/ directory
function M.show_output_logs(opts)
  opts = opts or {}

  -- Find outputs directory (check cwd first, then project root)
  local cwd = vim.fn.getcwd()
  local outputs_dir = cwd .. "/outputs"

  if vim.fn.isdirectory(outputs_dir) == 0 then
    -- Try to find project root and check there
    local root_markers = { ".git", "setup.py", "pyproject.toml", "Cargo.toml", "package.json" }
    for _, marker in ipairs(root_markers) do
      local root = vim.fn.finddir(marker, vim.fn.expand("%:p:h") .. ";")
      if root ~= "" then
        local project_root = vim.fn.fnamemodify(root, ":h")
        outputs_dir = project_root .. "/outputs"
        if vim.fn.isdirectory(outputs_dir) == 1 then
          break
        end
      end
    end
  end

  if vim.fn.isdirectory(outputs_dir) == 0 then
    vim.notify("No outputs/ directory found in project", vim.log.levels.WARN)
    return
  end

  local files = get_output_files(outputs_dir)

  if #files == 0 then
    vim.notify("No files found in outputs/", vim.log.levels.INFO)
    return
  end

  pickers.new(opts, {
    prompt_title = "Output Logs (Latest First)",
    finder = finders.new_table({
      results = files,
      entry_maker = function(file)
        local display_name = file:gsub("^" .. vim.pesc(outputs_dir) .. "/", "")
        local mtime_display = get_file_mtime_display(file)

        return {
          value = file,
          display = string.format("%-50s %s", display_name, mtime_display),
          ordinal = display_name,
          path = file,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    previewer = previewers.new_buffer_previewer({
      define_preview = function(self, entry)
        local filepath = entry.path

        -- For log files, show tail -n 200 to see latest entries
        if filepath:match("%.log$") or filepath:match("%.out$") or filepath:match("%.err$") then
          vim.fn.jobstart({ "tail", "-n", "200", filepath }, {
            stdout_buffered = true,
            on_stdout = function(_, data)
              if data then
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, data)
                vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "log")
              end
            end,
          })
        else
          -- For regular files, use standard file previewer
          conf.buffer_previewer_maker(filepath, self.state.bufnr, {
            bufname = self.state.bufname,
            winid = self.state.winid,
          })
        end
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          vim.cmd("edit " .. vim.fn.fnameescape(selection.path))
        end
      end)

      -- Add custom mapping to tail -f the log file in a terminal
      map("i", "<C-t>", function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          vim.cmd("TermExec cmd='tail -f " .. vim.fn.shellescape(selection.path) .. "'")
        end
      end)

      map("n", "<C-t>", function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          vim.cmd("TermExec cmd='tail -f " .. vim.fn.shellescape(selection.path) .. "'")
        end
      end)

      return true
    end,
  }):find()
end

return M
