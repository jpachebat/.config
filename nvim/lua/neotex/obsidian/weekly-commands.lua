local weekly = require("neotex.obsidian.weekly")
local M = {}

-- Get vault path
local function get_vault_path()
  return vim.fn.expand("~/work/notes")
end

-- Create daily note with template
local function create_daily_note(date)
  local vault = get_vault_path()
  local filepath = string.format("%s/daily/%s.md", vault, date)

  -- Check if already exists
  if vim.fn.filereadable(filepath) == 1 then
    return filepath
  end

  -- Get quote for this date
  local quote_data = weekly.get_daily_quote(date)
  local quote = quote_data[1]
  local author = quote_data[2]

  -- Read template
  local template_path = vault .. "/Templates/daily.md"
  local template_content = ""

  if vim.fn.filereadable(template_path) == 1 then
    template_content = table.concat(vim.fn.readfile(template_path), "\n")
  else
    -- Fallback template
    template_content = [[# {{date}}

> {{quote}}
> — {{author}}

## Tasks
- [ ]

## Work Log


## Quick Capture


## Perso
]]
  end

  -- Replace variables
  local content = template_content
    :gsub("{{date}}", date)
    :gsub("{{quote}}", quote)
    :gsub("{{author}}", author)

  -- Create directory if needed
  vim.fn.mkdir(vault .. "/daily", "p")

  -- Write file
  local lines = vim.split(content, "\n")
  vim.fn.writefile(lines, filepath)

  return filepath
end

-- Create weekly note with all daily notes
function M.create_weekly_note(offset)
  offset = offset or 0
  local vault = get_vault_path()
  local info = weekly.get_week_info(offset)
  local filename = weekly.get_week_filename(offset)
  local filepath = string.format("%s/weekly/%s", vault, filename)

  -- Create all daily notes for the week
  local dailies = weekly.get_week_dailies(offset)
  local daily_links = {}

  for _, day_info in ipairs(dailies) do
    -- Create the daily note file
    create_daily_note(day_info.date)
    -- Add to links list
    table.insert(daily_links, string.format("- [[%s]] - %s", day_info.date, day_info.day))
  end

  -- Check if weekly note already exists
  local exists = vim.fn.filereadable(filepath) == 1

  if not exists then
    -- Read template
    local template_path = vault .. "/Templates/weekly.md"
    local template_content = ""

    if vim.fn.filereadable(template_path) == 1 then
      template_content = table.concat(vim.fn.readfile(template_path), "\n")
    else
      -- Fallback template
      template_content = [[# Week {{week}} - {{year}} ({{start_date}} - {{end_date}})

## Weekly Objectives
- [ ]
- [ ]
- [ ]

## Daily Notes
{{daily_links}}

## Weekly Planning

### Focus Areas
- Research:
- Development:
- Admin:

### DEADLINE This Week


## Weekly Review (End of Week)

### Wins


### Challenges


### Learnings


### Next Week Priorities
]]
    end

    -- Replace variables
    local content = template_content
      :gsub("{{week}}", string.format("%02d", info.week))
      :gsub("{{year}}", tostring(info.year))
      :gsub("{{start_date}}", info.sunday)
      :gsub("{{end_date}}", info.saturday)
      :gsub("{{daily_links}}", table.concat(daily_links, "\n"))

    -- Create directory if needed
    vim.fn.mkdir(vault .. "/weekly", "p")

    -- Write file
    local lines = vim.split(content, "\n")
    vim.fn.writefile(lines, filepath)
  end

  -- Open the weekly note
  vim.cmd("edit " .. vim.fn.fnameescape(filepath))

  if not exists then
    vim.notify(string.format("Created weekly note: Week %02d, %d (with %d daily notes)", info.week, info.year, #dailies))
  end
end

-- Open this week's note
function M.open_this_week()
  M.create_weekly_note(0)
end

-- Open next week's note
function M.open_next_week()
  M.create_weekly_note(1)
end

-- Open previous week's note
function M.open_previous_week()
  M.create_weekly_note(-1)
end

return M
