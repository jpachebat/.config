-----------------------------------------------------------
-- Todo Comments Plugin
--
-- This module configures todo-comments.nvim for enhanced TODO highlighting
-- and navigation. It provides:
-- - Syntax highlighting for TODO, DEADLINE, FIX, HACK, NOTE, WARNING etc.
-- - Integration with Telescope for searching TODOs and DEADLINEs
-- - Keymappings for navigating between TODOs
-- - Custom colors for different comment types
-- - DEADLINE keyword highlighted in bright red with calendar icon
--
-- The plugin uses treesitter for accurate comment detection across
-- many languages and formats.
-----------------------------------------------------------

return {
  'folke/todo-comments.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = { 'TodoTelescope', 'TodoQuickFix', 'TodoLocList', 'TodoTrouble', 'DeadlineTelescope', 'TasksTelescope' },
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
  },
  config = function()
    require('todo-comments').setup({
      signs = true,      -- Show icons in the signs column
      sign_priority = 8, -- Sign priority

      -- Keywords recognized as todo comments with stylized icons
      keywords = {
        FIX = {
          icon = "󰁨 ",                                -- Icon used for the sign (stylized wrench)
          color = "error",                            -- Can be a hex color, or a named color
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- Alternative keywords for the same group
        },
        TODO = { icon = "󰄬 ", color = "info" },       -- Stylized checkbox
        DEADLINE = { icon = "󱫥 ", color = "deadline", alt = { "DUE", "DUEDATE" } }, -- Stylized calendar with alert
        HACK = { icon = "󰉀 ", color = "warning" },    -- Stylized lightning bolt
        WARN = { icon = "󰀪 ", color = "warning", alt = { "WARNING" } }, -- Stylized warning triangle
        PERF = { icon = "󰓅 ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } }, -- Stylized gauge/speedometer
        NOTE = { icon = "󰍨 ", color = "hint", alt = { "INFO" } },      -- Stylized note/pin
        TEST = { icon = "󰙨 ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } }, -- Stylized test tube
      },

      -- Highlight groups (colors)
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarning", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" },
        deadline = { "DiagnosticError", "ErrorMsg", "#EF4444" }, -- Bright red for visibility
      },

      -- Patterns used to match comments
      patterns = {
        { pattern = [[(KEYWORDS)\s*:]], },   -- TODO: make this work
        { pattern = [[(KEYWORDS)\s*]], },    -- TODO make this work
        { pattern = [[^\s*(KEYWORDS):]], },  -- At the beginning of line
        { pattern = [[^\s*(KEYWORDS)\s]], }, -- At the beginning of line
      },

      -- How comments are displayed in the list
      format = {
        -- Set to nil to use default
        -- FIX = { icon = icon, color = "error" },
        -- TODO = { icon = icon, color = "info" },
        -- HACK = { icon = icon, color = "warning" },
        -- WARN = { icon = icon, color = "warning" },
        -- PERF = { icon = icon, color = "default" },
        -- NOTE = { icon = icon, color = "hint" },
        -- TEST = { icon = icon, color = "test" },
      },

      -- LSP integration
      lsp_client_names = {
        "null-ls",
      },

      -- Merge keywords from LSP diagnostics sources
      merge_keywords = true,

      -- Highlighting of the line containing the todo comment
      highlight = {
        multiline = true,         -- Enable multine todo comments
        multiline_pattern = "^.", -- Start the pattern for the multiline match
        multiline_context = 10,   -- Extra lines that will be re-evaluated

        -- Pattern to match within the comment
        pattern = [[.*<(KEYWORDS)\s*:]], -- []:

        -- Boolean or virtual text provider to use
        comments_only = true, -- Only apply to comments
      },

      -- Use built-in search
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        -- Regex that will be used to match keywords.
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
      },
    })

    -- Add Telescope integration
    local has_telescope, telescope = pcall(require, "telescope")
    if has_telescope then
      telescope.load_extension("todo-comments")
    end

    -- ============================================================================
    -- Task and Deadline parsing utilities
    -- ============================================================================

    -- Parse task with @date and optional time: @YYMMDD HH:MM or @YYYYMMDD HH:MM
    local function parse_task_datetime(raw)
      if not raw or raw == "" then
        return nil
      end

      -- Match @date followed by optional time
      -- Supports: @251120, @20251120, @251120 14:30, @20251120 14:30
      local date_part, time_part = raw:match("@(%d+)%s*(%d?%d?:?%d?%d?)")

      if not date_part then
        return nil
      end

      -- Parse date
      local year, month, day
      if #date_part == 8 then
        -- YYYYMMDD
        year = tonumber(date_part:sub(1, 4))
        month = tonumber(date_part:sub(5, 6))
        day = tonumber(date_part:sub(7, 8))
      elseif #date_part == 6 then
        -- YYMMDD
        local yy = tonumber(date_part:sub(1, 2))
        year = 2000 + yy
        month = tonumber(date_part:sub(3, 4))
        day = tonumber(date_part:sub(5, 6))
      else
        return nil
      end

      -- Validate date
      if not (year and month and day and month >= 1 and month <= 12 and day >= 1 and day <= 31) then
        return nil
      end

      -- Parse optional time
      local hour, minute = 0, 0
      local has_time = false
      if time_part and time_part ~= "" then
        local h, m = time_part:match("(%d%d?):(%d%d)")
        if h and m then
          hour = tonumber(h)
          minute = tonumber(m)
          if hour >= 0 and hour <= 23 and minute >= 0 and minute <= 59 then
            has_time = true
          else
            hour, minute = 0, 0
          end
        end
      end

      local ts = os.time({ year = year, month = month, day = day, hour = hour, min = minute, sec = 0 })
      if not ts then
        return nil
      end

      return {
        date_label = string.format("%04d-%02d-%02d", year, month, day),
        time_label = has_time and string.format("%02d:%02d", hour, minute) or nil,
        datetime_label = has_time
          and string.format("%04d-%02d-%02d %02d:%02d", year, month, day, hour, minute)
          or string.format("%04d-%02d-%02d", year, month, day),
        ts = ts,
        has_time = has_time,
      }
    end

    local function parse_deadline_date(raw)
      if not raw or raw == "" then
        return nil
      end
      local patterns = {
        { match = "(%d%d%d%d)[%-%./](%d%d)[%-%./](%d%d)", order = "ymd" }, -- 2024-03-14 or 2024/03/14
        { match = "(%d%d)[%-%./](%d%d)[%-%./](%d%d%d%d)", order = "dmy" }, -- 14-03-2024
        { match = "(%d%d%d%d)(%d%d)(%d%d)", order = "ymd" },              -- 20240314
        { match = "(%d%d)(%d%d)(%d%d)", order = "ymd_short" },            -- 250314 (YYMMDD)
      }

      for _, pattern in ipairs(patterns) do
        local a, b, c = raw:match(pattern.match)
        if a then
          local year, month, day
          if pattern.order == "ymd" then
            year, month, day = tonumber(a), tonumber(b), tonumber(c)
          elseif pattern.order == "ymd_short" then
            -- YYMMDD format: assume 20xx for years 00-99
            local yy = tonumber(a)
            year = 2000 + yy
            month, day = tonumber(b), tonumber(c)
          else
            day, month, year = tonumber(a), tonumber(b), tonumber(c)
          end
          if
            year and month and day
            and month >= 1 and month <= 12
            and day >= 1 and day <= 31
          then
            local ts = os.time({ year = year, month = month, day = day, hour = 12 })
            if ts then
              return {
                label = string.format("%04d-%02d-%02d", year, month, day),
                ts = ts,
              }
            end
          end
        end
      end

      return nil
    end

    local function relative_meta(ts, now)
      if not ts then
        return "—", "Comment"
      end
      -- Normalize both dates to midnight for accurate day comparison
      local task_date = os.date("*t", ts)
      local today_date = os.date("*t", now)

      local task_midnight = os.time({
        year = task_date.year,
        month = task_date.month,
        day = task_date.day,
        hour = 0,
        min = 0,
        sec = 0
      })

      local today_midnight = os.time({
        year = today_date.year,
        month = today_date.month,
        day = today_date.day,
        hour = 0,
        min = 0,
        sec = 0
      })

      local diff_days = math.floor((task_midnight - today_midnight) / 86400)

      if diff_days < 0 then
        return string.format("%dd", diff_days), "DiagnosticError"
      elseif diff_days == 0 then
        return "today", "DiagnosticWarn"
      elseif diff_days <= 3 then
        return string.format("+%dd", diff_days), "DiagnosticWarn"
      else
        return string.format("+%dd", diff_days), "DiagnosticHint"
      end
    end

    local function parse_cmd_args(str)
      if not str or str == "" then
        return {}
      end
      local opts = {}
      for key, value in string.gmatch(str, "(%w+)=([^%s]+)") do
        opts[key] = value
      end
      return opts
    end

    local function open_deadline_picker(user_opts)
      user_opts = user_opts or {}

      if not has_telescope then
        vim.notify("Deadline picker requires telescope.nvim", vim.log.levels.ERROR)
        return
      end

      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local entry_display = require("telescope.pickers.entry_display")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local todo_search = require("todo-comments.search")
      local Config = require("todo-comments.config")

      local search_opts = {
        keywords = "DEADLINE",
        disable_not_found_warnings = true,
      }
      local picker_opts = {}

      if user_opts.cwd and user_opts.cwd ~= "" then
        local expanded = vim.fn.expand(user_opts.cwd)
        search_opts.cwd = expanded
        picker_opts.cwd = expanded
      end

      todo_search.search(function(results)
        if not results or vim.tbl_isempty(results) then
          vim.notify("No DEADLINE entries found", vim.log.levels.INFO)
          return
        end

        local icon = (Config.options.keywords.DEADLINE or {}).icon or "󱫥"
        local icon_hl = "TodoFgDEADLINE"
        local icon_width = math.max(vim.fn.strdisplaywidth(icon), 2)
        local displayer = entry_display.create({
          separator = " ",
          items = {
            { width = icon_width },
            { width = 12 },
            { width = 8 },
            { width = 30 },
            { remaining = true },
          },
        })

        local now = os.time()
        local entries = {}

        for _, item in ipairs(results) do
          local combined = table.concat({
            item.text or "",
            item.message or "",
            item.line or "",
          }, " ")
          local parsed = parse_deadline_date(combined)
          local ts = parsed and parsed.ts or nil
          local sort_value = ts or math.huge
          local date_label = parsed and parsed.label or "No date"
          local relative_text, relative_hl = relative_meta(ts, now)
          local location = string.format("%s:%d", vim.fn.fnamemodify(item.filename, ":~:."), item.lnum)
          local preview = vim.trim(item.message ~= "" and item.message or item.text or item.line or "")
          if preview == "" then
            preview = "—"
          end

          table.insert(entries, {
            filename = item.filename,
            lnum = item.lnum,
            col = item.col,
            sort_value = sort_value,
            date_label = date_label,
            has_date = ts ~= nil,
            relative_text = relative_text,
            relative_hl = relative_hl,
            location = location,
            preview = preview,
          })
        end

        if vim.tbl_isempty(entries) then
          vim.notify("No DEADLINE entries found", vim.log.levels.INFO)
          return
        end

        table.sort(entries, function(a, b)
          if a.sort_value == b.sort_value then
            if a.filename == b.filename then
              return a.lnum < b.lnum
            end
            return a.filename < b.filename
          end
          return a.sort_value < b.sort_value
        end)

        local finder = finders.new_table({
          results = entries,
          entry_maker = function(item)
            return {
              value = item,
              display = function()
                return displayer({
                  { icon, icon_hl },
                  { item.date_label, item.has_date and icon_hl or "Comment" },
                  { item.relative_text, item.relative_hl },
                  { item.location, "Comment" },
                  { item.preview, "Normal" },
                })
              end,
              ordinal = table.concat({
                item.date_label,
                item.relative_text,
                item.location,
                item.preview,
              }, " "),
              filename = item.filename,
              lnum = item.lnum,
              col = item.col,
            }
          end,
        })

        pickers.new(picker_opts, {
          prompt_title = "Deadlines (by date)",
          finder = finder,
          sorter = conf.generic_sorter(picker_opts),
          previewer = conf.grep_previewer(picker_opts),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              if not selection or not selection.filename then
                return
              end
              vim.cmd("edit " .. vim.fn.fnameescape(selection.filename))
              vim.api.nvim_win_set_cursor(0, {
                selection.lnum,
                math.max((selection.col or 1) - 1, 0),
              })
            end)
            return true
          end,
        }):find()
      end, search_opts)
    end

    pcall(vim.api.nvim_del_user_command, "DeadlineTelescope")
    vim.api.nvim_create_user_command("DeadlineTelescope", function(cmd_opts)
      open_deadline_picker(parse_cmd_args(cmd_opts.args))
    end, {
      desc = "Search DEADLINE comments sorted by date",
      nargs = "*",
    })

    -- ============================================================================
    -- Tasks with datetime telescope picker
    -- ============================================================================

    local function open_tasks_picker(user_opts)
      user_opts = user_opts or {}

      if not has_telescope then
        vim.notify("Tasks picker requires telescope.nvim", vim.log.levels.ERROR)
        return
      end

      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local entry_display = require("telescope.pickers.entry_display")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- Use vim.fn.systemlist instead of io.popen for better compatibility
      local cwd = user_opts.cwd and vim.fn.expand(user_opts.cwd) or vim.fn.getcwd()

      local cmd = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "^\\s*[*-]\\s*\\[[x ]\\]",  -- Support both * and - for tasks
        cwd
      }

      local output = vim.fn.systemlist(cmd)

      if vim.v.shell_error ~= 0 then
        vim.notify("Failed to search for tasks: " .. (output[1] or "unknown error"), vim.log.levels.ERROR)
        return
      end

      local results = {}
      local total_tasks = 0
      local tasks_with_date = 0

      for _, line in ipairs(output) do
        local filename, lnum, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
        if filename and lnum and text then
          total_tasks = total_tasks + 1
          -- Skip completed tasks [x]
          local is_completed = text:match("%[x%]") ~= nil
          if not is_completed then
            -- Check if task has @date
            local datetime_info = parse_task_datetime(text)
            if datetime_info then
              tasks_with_date = tasks_with_date + 1
            end
            -- Include all tasks (with or without date)
            table.insert(results, {
              filename = filename,
              lnum = tonumber(lnum),
              col = tonumber(col),
              text = text,
              datetime_info = datetime_info,  -- nil if no date
            })
          end
        end
      end

      if vim.tbl_isempty(results) then
        vim.notify(
          string.format("No incomplete tasks found (found %d tasks total)", total_tasks),
          vim.log.levels.INFO
        )
        return
      end

      local icon = "󰄬"
      local icon_hl = "TodoFgTODO"
      local icon_width = 2
      local displayer = entry_display.create({
        separator = " ",
        items = {
          { width = icon_width },
          { width = 16 },
          { width = 8 },
          { width = 30 },
          { remaining = true },
        },
      })

      local now = os.time()
      local entries = {}

      for _, item in ipairs(results) do
        local has_date = item.datetime_info ~= nil
        local ts = has_date and item.datetime_info.ts or nil
        -- Tasks with date sort first, then by timestamp
        -- Tasks without date sort last (math.huge * 2)
        local sort_value = ts or (math.huge * 2)

        local datetime_label = has_date and item.datetime_info.datetime_label or "—"
        local relative_text, relative_hl
        if has_date then
          relative_text, relative_hl = relative_meta(ts, now)
        else
          relative_text = "no date"
          relative_hl = "Comment"
        end

        local location = string.format("%s:%d", vim.fn.fnamemodify(item.filename, ":~:."), item.lnum)

        -- Extract task text (remove checkbox and @date, support both - and *)
        local task_text = item.text:gsub("^%s*[*%-]%s*%[[ ]%]%s*", ""):gsub("@%d+%s*%d*:?%d*", "")
        task_text = vim.trim(task_text)
        if task_text == "" then
          task_text = "—"
        end

        table.insert(entries, {
          filename = item.filename,
          lnum = item.lnum,
          col = item.col,
          sort_value = sort_value,
          datetime_label = datetime_label,
          relative_text = relative_text,
          relative_hl = relative_hl,
          location = location,
          task_text = task_text,
          has_date = has_date,
        })
      end

      -- Sort by datetime
      table.sort(entries, function(a, b)
        if a.sort_value == b.sort_value then
          if a.filename == b.filename then
            return a.lnum < b.lnum
          end
          return a.filename < b.filename
        end
        return a.sort_value < b.sort_value
      end)

      local finder = finders.new_table({
        results = entries,
        entry_maker = function(item)
          return {
            value = item,
            display = function()
              -- Dimmed icon and text for tasks without date
              local display_icon = item.has_date and icon or "○"
              local display_icon_hl = item.has_date and icon_hl or "Comment"
              local display_text_hl = item.has_date and "Normal" or "Comment"
              local display_date_hl = item.has_date and icon_hl or "Comment"

              return displayer({
                { display_icon, display_icon_hl },
                { item.datetime_label, display_date_hl },
                { item.relative_text, item.relative_hl },
                { item.location, "Comment" },
                { item.task_text, display_text_hl },
              })
            end,
            ordinal = table.concat({
              item.datetime_label,
              item.relative_text,
              item.location,
              item.task_text,
            }, " "),
            filename = item.filename,
            lnum = item.lnum,
            col = item.col,
          }
        end,
      })

      pickers.new(user_opts, {
        prompt_title = string.format("Tasks (%d with date, %d total)", tasks_with_date, #entries),
        finder = finder,
        sorter = conf.generic_sorter(user_opts),
        previewer = conf.grep_previewer(user_opts),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if not selection or not selection.filename then
              return
            end
            -- Use edit! to avoid E37 error when buffer has unsaved changes
            vim.cmd("edit! " .. vim.fn.fnameescape(selection.filename))
            vim.api.nvim_win_set_cursor(0, {
              selection.lnum,
              math.max((selection.col or 1) - 1, 0),
            })
          end)
          return true
        end,
      }):find()
    end

    pcall(vim.api.nvim_del_user_command, "TasksTelescope")
    vim.api.nvim_create_user_command("TasksTelescope", function(cmd_opts)
      open_tasks_picker(parse_cmd_args(cmd_opts.args))
    end, {
      desc = "Search tasks with @date sorted by datetime",
      nargs = "*",
    })

    -- Add which-key mappings using modern API
    local has_which_key, which_key = pcall(require, "which-key")
    if has_which_key then
      which_key.add({
        -- Add to FIND group
        { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "todos (all)", icon = "󰄬" },

        -- NOTE: All TODO/DEADLINE mappings are now in which-key.lua
        -- <leader>td - Search deadlines
        -- <leader>tt - Search all todos
        -- <leader>fd - Find deadlines (in find group)
        -- <leader>ft - Find all todos (in find group)
      })
    end
  end,
}
