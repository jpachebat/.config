-- Task Management with Deadlines
-- Supports format: - [ ] Task @2025-10-31

local M = {}

-- Parse task line for deadline info
local function parse_task(line)
  local task = {}

  -- Check if it's a task
  local checkbox = line:match("^%s*- %[(.?)%]")
  if not checkbox then return nil end

  task.completed = checkbox == "x" or checkbox == "X"
  task.line = line

  -- Extract task text (before deadline)
  task.text = line:match("^%s*%- %[.%] (.-)%s*@") or line:match("^%s*%- %[.%] (.+)")

  -- Extract deadline (@2025-10-31)
  local deadline = line:match("@(%d%d%d%d%-%d%d%-%d%d)")
  if deadline then
    task.deadline = deadline
    task.deadline_ts = os.time({
      year = tonumber(deadline:sub(1,4)),
      month = tonumber(deadline:sub(6,7)),
      day = tonumber(deadline:sub(9,10)),
    })
  end

  -- Extract priority
  if line:match("⏫") then task.priority = 1  -- High
  elseif line:match("🔼") then task.priority = 2  -- Medium
  elseif line:match("🔽") then task.priority = 3  -- Low
  else task.priority = 2 end  -- Default medium

  return task
end

-- Get all tasks from current buffer or vault
function M.get_all_tasks(search_vault)
  local tasks = {}
  local current_file = vim.api.nvim_buf_get_name(0)

  if search_vault then
    -- Search entire Obsidian vault
    local ok, obsidian = pcall(require, "obsidian")
    if ok then
      local client = obsidian.get_client()
      local vault_path = client.dir.filename

      -- Use ripgrep to find all tasks
      local rg_cmd = string.format(
        'rg "^\\s*- \\[.\\].*@" "%s" --with-filename --line-number',
        vault_path
      )

      local output = vim.fn.systemlist(rg_cmd)
      for _, line in ipairs(output) do
        local file, lnum, content = line:match("^(.+):(%d+):(.+)$")
        if file and content then
          local task = parse_task(content)
          if task and task.deadline then
            task.file = file
            task.lnum = tonumber(lnum)
            table.insert(tasks, task)
          end
        end
      end
    end
  else
    -- Search current buffer only
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i, line in ipairs(lines) do
      local task = parse_task(line)
      if task and task.deadline then
        task.file = current_file
        task.lnum = i
        table.insert(tasks, task)
      end
    end
  end

  return tasks
end

-- Show tasks with deadlines in Telescope
function M.show_tasks_telescope(opts)
  opts = opts or {}
  local search_vault = opts.vault or false

  local tasks = M.get_all_tasks(search_vault)

  -- Sort by deadline
  table.sort(tasks, function(a, b)
    if not a.deadline_ts then return false end
    if not b.deadline_ts then return true end
    return a.deadline_ts < b.deadline_ts
  end)

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local today = os.time()

  pickers.new(opts, {
    prompt_title = search_vault and "All Tasks (Vault)" or "Tasks (Current File)",
    finder = finders.new_table({
      results = tasks,
      entry_maker = function(task)
        -- Calculate days until deadline
        local days_diff = math.floor((task.deadline_ts - today) / 86400)
        local status_str = ""
        local hl_group = "Normal"

        if task.completed then
          status_str = "✓ "
          hl_group = "Comment"
        elseif days_diff < 0 then
          status_str = string.format("⚠ OVERDUE (%d days) ", -days_diff)
          hl_group = "Error"
        elseif days_diff == 0 then
          status_str = "⏰ TODAY "
          hl_group = "WarningMsg"
        elseif days_diff <= 3 then
          status_str = string.format("%d days ", days_diff)
          hl_group = "WarningMsg"
        else
          status_str = string.format("%d days ", days_diff)
          hl_group = "Normal"
        end

        local priority_str = ""
        if task.priority == 1 then priority_str = "⏫ "
        elseif task.priority == 3 then priority_str = "🔽 " end

        local display = string.format(
          "%s%s%s - %s",
          status_str,
          priority_str,
          task.deadline,
          task.text
        )

        return {
          value = task,
          display = display,
          ordinal = task.text .. " " .. task.deadline,
          filename = task.file,
          lnum = task.lnum,
          hl_group = hl_group,
        }
      end,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("edit " .. vim.fn.fnameescape(selection.filename))
          vim.api.nvim_win_set_cursor(0, {selection.lnum, 0})
        end
      end)
      return true
    end,
  }):find()
end

-- Parse intelligent date input (Todoist-style)
local function parse_date_input(input)
  input = input:lower():gsub("^%s+", ""):gsub("%s+$", "")

  -- Handle relative days: +7, +1
  if input:match("^%+%d+$") then
    local days = tonumber(input:sub(2))
    return os.time() + (days * 86400)
  end

  -- Handle short format: 251031 or 51031 -> 2025-10-31
  if input:match("^%d%d%d%d%d%d$") then
    local yy, mm, dd = input:match("^(%d%d)(%d%d)(%d%d)$")
    return os.time({year = 2000 + tonumber(yy), month = tonumber(mm), day = tonumber(dd)})
  end

  -- Natural language dates
  local now = os.date("*t")
  local today_start = os.time({year = now.year, month = now.month, day = now.day, hour = 0, min = 0, sec = 0})

  -- Today, tod
  if input:match("^tod") then
    return today_start
  end

  -- Tomorrow, tom, tmr
  if input:match("^tom") or input:match("^tmr") then
    return today_start + 86400
  end

  -- Yesterday
  if input:match("^yes") then
    return today_start - 86400
  end

  -- Next week
  if input:match("next%s+week") then
    return today_start + (7 * 86400)
  end

  -- This/next [weekday]
  local weekday_map = {
    monday = 1, mon = 1,
    tuesday = 2, tue = 2, tues = 2,
    wednesday = 3, wed = 3,
    thursday = 4, thu = 4, thur = 4, thurs = 4,
    friday = 5, fri = 5,
    saturday = 6, sat = 6,
    sunday = 7, sun = 7,
  }

  for name, target_day in pairs(weekday_map) do
    if input:match(name) then
      local current_day = tonumber(os.date("%w"))  -- 0 = Sunday
      if current_day == 0 then current_day = 7 end  -- Convert to 1-7 (Mon-Sun)

      local days_ahead = target_day - current_day
      if days_ahead <= 0 then days_ahead = days_ahead + 7 end  -- Next occurrence

      -- If "next" is specified, add another week
      if input:match("^next") then
        days_ahead = days_ahead + 7
      end

      return today_start + (days_ahead * 86400)
    end
  end

  -- Next month
  if input:match("next%s+month") then
    local next_month = os.date("*t", today_start)
    next_month.month = next_month.month + 1
    if next_month.month > 12 then
      next_month.month = 1
      next_month.year = next_month.year + 1
    end
    return os.time(next_month)
  end

  -- Full format: YYYY-MM-DD or YYYYMMDD
  local yyyy, mm, dd = input:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
  if yyyy then
    return os.time({year = tonumber(yyyy), month = tonumber(mm), day = tonumber(dd)})
  end

  local ymd = input:match("^(%d%d%d%d%d%d%d%d)$")
  if ymd then
    yyyy, mm, dd = ymd:sub(1,4), ymd:sub(5,6), ymd:sub(7,8)
    return os.time({year = tonumber(yyyy), month = tonumber(mm), day = tonumber(dd)})
  end

  return nil
end

-- Insert task with deadline template
function M.insert_task_with_deadline()
  local input = vim.fn.input("Deadline (tomorrow, mon, +7, 251031): ")
  if input == "" then return end

  local deadline_ts = parse_date_input(input)
  if not deadline_ts then
    vim.notify("Invalid date format: " .. input, vim.log.levels.ERROR)
    return
  end

  local date = os.date("%Y-%m-%d", deadline_ts)

  local priority = vim.fn.input("Priority (1=high, 2=med, 3=low): ")
  local priority_icon = ""
  if priority == "1" then priority_icon = " ⏫"
  elseif priority == "3" then priority_icon = " 🔽" end

  local task_text = vim.fn.input("Task: ")
  if task_text == "" then return end

  local task_line = string.format("- [ ] %s @%s%s", task_text, date, priority_icon)

  -- Insert at cursor
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, {task_line})

  -- Move cursor to next line
  vim.api.nvim_win_set_cursor(0, {row + 1, 0})
end

-- Quick insert task (no priority prompt)
function M.quick_insert_task()
  local input = vim.fn.input("Quick task (tomorrow/mon/+7/251031): ")
  if input == "" then return end

  -- Check if input contains a date, otherwise assume it's just task text
  local parts = vim.split(input, " ", {trimempty = true})
  local date_input = parts[#parts]  -- Last word might be date
  local deadline_ts = parse_date_input(date_input)

  local task_text, date_str
  if deadline_ts then
    -- Last word was a date
    table.remove(parts, #parts)
    task_text = table.concat(parts, " ")
    date_str = os.date("%Y-%m-%d", deadline_ts)
  else
    -- No date found, default to today
    task_text = input
    date_str = os.date("%Y-%m-%d")
  end

  if task_text == "" then return end

  local task_line = string.format("- [ ] %s @%s", task_text, date_str)

  -- Insert at cursor
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, {task_line})
  vim.api.nvim_win_set_cursor(0, {row + 1, 0})
end

return M
