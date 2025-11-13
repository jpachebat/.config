-----------------------------------------------------
-- Todo Popup - Project-specific todo section in floating window
--
-- This module provides a floating popup window that shows the ## todo
-- section from a configured project markdown file. The popup persists
-- across buffers and syncs changes back to the source file when closed.
--
-- Usage:
--   - Configure project file: vim.g.todo_project_file = "~/work/notes/project.md"
--   - Toggle popup: require("neotex.util.todo-popup").toggle()
--   - Set file: :TodoSetFile path/to/file.md
--   - Get current file: :TodoGetFile
-----------------------------------------------------

local M = {}

-- State management
M.state = {
  source_file = nil,      -- Path to the markdown file containing todos
  popup_buf = nil,        -- Buffer ID for the popup
  popup_win = nil,        -- Window ID for the popup
  section_start = nil,    -- Line number where ## todo section starts
  section_end = nil,      -- Line number where ## todo section ends
  original_content = nil, -- Original content for comparison
}

---Extract the ## todo section from a markdown file
---@param filepath string Path to the markdown file
---@return table|nil {start_line: number, end_line: number, lines: table}
function M.extract_todo_section(filepath)
  -- Read the file
  local file = io.open(filepath, "r")
  if not file then
    vim.notify("Could not open file: " .. filepath, vim.log.levels.ERROR)
    return nil
  end

  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()

  -- Find ## todo section (case-insensitive)
  local section_start = nil
  local section_end = nil

  for i, line in ipairs(lines) do
    -- Match ## todo (with optional spaces/case variations)
    if line:lower():match("^##%s+todo%s*$") then
      section_start = i
    elseif section_start and line:match("^##%s+") then
      -- Found next ## heading, section ends here
      section_end = i - 1
      break
    end
  end

  -- If section found but no end, it goes to end of file
  if section_start and not section_end then
    section_end = #lines
  end

  -- If section not found, return nil
  if not section_start then
    return nil
  end

  -- Extract section lines (including the ## todo header)
  local section_lines = {}
  for i = section_start, section_end do
    table.insert(section_lines, lines[i])
  end

  return {
    start_line = section_start,
    end_line = section_end,
    lines = section_lines,
  }
end

---Create the ## todo section in the file if it doesn't exist
---@param filepath string Path to the markdown file
---@return boolean success
function M.create_todo_section(filepath)
  -- Read existing content
  local file = io.open(filepath, "r")
  if not file then
    vim.notify("Could not open file: " .. filepath, vim.log.levels.ERROR)
    return false
  end

  local content = file:read("*all")
  file:close()

  -- Append ## todo section at the end
  local new_content = content
  if not content:match("\n$") then
    new_content = new_content .. "\n"
  end
  new_content = new_content .. "\n## todo\n\n"

  -- Write back
  file = io.open(filepath, "w")
  if not file then
    vim.notify("Could not write to file: " .. filepath, vim.log.levels.ERROR)
    return false
  end

  file:write(new_content)
  file:close()

  vim.notify("Created ## todo section in " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO)
  return true
end

---Create and show the floating window with todo content
---@param section_data table {start_line, end_line, lines}
function M.create_popup(section_data)
  -- Create buffer if it doesn't exist
  if not M.state.popup_buf or not vim.api.nvim_buf_is_valid(M.state.popup_buf) then
    M.state.popup_buf = vim.api.nvim_create_buf(false, true) -- not listed, scratch buffer
    vim.bo[M.state.popup_buf].buftype = "nofile"
    vim.bo[M.state.popup_buf].bufhidden = "hide"
    vim.bo[M.state.popup_buf].swapfile = false
    vim.bo[M.state.popup_buf].filetype = "markdown"
  end

  -- Set buffer content
  vim.api.nvim_buf_set_lines(M.state.popup_buf, 0, -1, false, section_data.lines)

  -- Mark buffer as unmodified
  vim.bo[M.state.popup_buf].modified = false

  -- Store section boundaries
  M.state.section_start = section_data.start_line
  M.state.section_end = section_data.end_line
  M.state.original_content = vim.deepcopy(section_data.lines)

  -- Calculate window size (80% of screen)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Window configuration
  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " Project Todo - " .. vim.fn.fnamemodify(M.state.source_file, ":t") .. " ",
    title_pos = "center",
  }

  -- Create or update window
  if M.state.popup_win and vim.api.nvim_win_is_valid(M.state.popup_win) then
    vim.api.nvim_win_set_config(M.state.popup_win, win_config)
  else
    M.state.popup_win = vim.api.nvim_open_win(M.state.popup_buf, true, win_config)
  end

  -- Set window options
  vim.wo[M.state.popup_win].wrap = true
  vim.wo[M.state.popup_win].linebreak = true
  vim.wo[M.state.popup_win].cursorline = true

  -- Set up autocmd to sync on close
  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = M.state.popup_buf,
    once = true,
    callback = function()
      M.sync_to_source()
    end,
  })

  -- Set up q to close
  vim.keymap.set("n", "q", function()
    M.close()
  end, { buffer = M.state.popup_buf, silent = true })
end

---Sync popup content back to source file
function M.sync_to_source()
  if not M.state.popup_buf or not vim.api.nvim_buf_is_valid(M.state.popup_buf) then
    return
  end

  -- Get popup content
  local popup_lines = vim.api.nvim_buf_get_lines(M.state.popup_buf, 0, -1, false)

  -- Check if content changed
  local changed = false
  if #popup_lines ~= #M.state.original_content then
    changed = true
  else
    for i, line in ipairs(popup_lines) do
      if line ~= M.state.original_content[i] then
        changed = true
        break
      end
    end
  end

  if not changed then
    return
  end

  -- Read source file
  local source_file = vim.fn.expand(M.state.source_file)
  local file = io.open(source_file, "r")
  if not file then
    vim.notify("Could not open source file for writing", vim.log.levels.ERROR)
    return
  end

  local all_lines = {}
  for line in file:lines() do
    table.insert(all_lines, line)
  end
  file:close()

  -- Replace section
  local new_lines = {}

  -- Lines before section
  for i = 1, M.state.section_start - 1 do
    table.insert(new_lines, all_lines[i])
  end

  -- New section content
  for _, line in ipairs(popup_lines) do
    table.insert(new_lines, line)
  end

  -- Lines after section
  for i = M.state.section_end + 1, #all_lines do
    table.insert(new_lines, all_lines[i])
  end

  -- Write back to file
  file = io.open(source_file, "w")
  if not file then
    vim.notify("Could not write to source file", vim.log.levels.ERROR)
    return
  end

  file:write(table.concat(new_lines, "\n") .. "\n")
  file:close()

  vim.notify("Todo section synced to " .. vim.fn.fnamemodify(source_file, ":t"), vim.log.levels.INFO)
end

---Check if popup is currently open
---@return boolean
function M.is_open()
  return M.state.popup_win and vim.api.nvim_win_is_valid(M.state.popup_win)
end

---Close the popup window
function M.close()
  if M.state.popup_win and vim.api.nvim_win_is_valid(M.state.popup_win) then
    -- Sync before closing
    M.sync_to_source()
    vim.api.nvim_win_close(M.state.popup_win, true)
    M.state.popup_win = nil
  end
end

---Prompt user to select a project file with Telescope
function M.prompt_select_file()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not available", vim.log.levels.ERROR)
    return
  end

  -- Find markdown files
  telescope.find_files({
    prompt_title = "Select Project Todo File",
    cwd = vim.fn.expand("~"),
    find_command = { "rg", "--files", "--type", "md" },
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- Override default select action
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if selection then
          local filepath = selection.path or selection[1]
          M.set_file(filepath)
          -- Open popup with selected file
          vim.schedule(function()
            M.open()
          end)
        end
      end)

      return true
    end,
  })
end

---Open the popup window
function M.open()
  -- Get configured project file
  local project_file = vim.g.todo_project_file
  if not project_file or project_file == "" then
    -- No file configured, prompt user to select one
    M.prompt_select_file()
    return
  end

  -- Expand path
  project_file = vim.fn.expand(project_file)
  M.state.source_file = project_file

  -- Check if file exists
  if vim.fn.filereadable(project_file) == 0 then
    vim.notify("Project file does not exist: " .. project_file, vim.log.levels.ERROR)
    return
  end

  -- Extract section
  local section_data = M.extract_todo_section(project_file)

  -- If section doesn't exist, create it
  if not section_data then
    if M.create_todo_section(project_file) then
      -- Re-extract after creation
      section_data = M.extract_todo_section(project_file)
      if not section_data then
        vim.notify("Failed to create todo section", vim.log.levels.ERROR)
        return
      end
    else
      return
    end
  end

  -- Create popup
  M.create_popup(section_data)
end

---Toggle the popup window
function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

---Set the project file path
---@param filepath string Path to the project markdown file
function M.set_file(filepath)
  if not filepath or filepath == "" then
    vim.notify("Please provide a file path", vim.log.levels.WARN)
    return
  end

  local expanded = vim.fn.expand(filepath)
  if vim.fn.filereadable(expanded) == 0 then
    vim.notify("File does not exist: " .. expanded, vim.log.levels.ERROR)
    return
  end

  vim.g.todo_project_file = expanded
  vim.notify("Todo project file set to: " .. vim.fn.fnamemodify(expanded, ":~"), vim.log.levels.INFO)

  -- Close popup if open (will need to reopen with new file)
  if M.is_open() then
    M.close()
  end
end

---Get the current project file path
function M.get_file()
  local project_file = vim.g.todo_project_file
  if not project_file or project_file == "" then
    vim.notify("No project file configured", vim.log.levels.WARN)
    return
  end

  vim.notify("Current project file: " .. vim.fn.fnamemodify(vim.fn.expand(project_file), ":~"), vim.log.levels.INFO)
  return project_file
end

---Setup function to create commands
function M.setup()
  -- Create user commands
  vim.api.nvim_create_user_command("TodoPopup", function()
    M.toggle()
  end, {
    desc = "Toggle project todo popup window",
  })

  vim.api.nvim_create_user_command("TodoSetFile", function(opts)
    M.set_file(opts.args)
  end, {
    nargs = 1,
    complete = "file",
    desc = "Set the project todo file path",
  })

  vim.api.nvim_create_user_command("TodoGetFile", function()
    M.get_file()
  end, {
    desc = "Show current project todo file path",
  })
end

-- Auto-setup when module is loaded
M.setup()

return M
