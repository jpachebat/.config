local dailies = require("neotex.obsidian.dailies")
require("neotex.obsidian.open-app") -- Load open-app module to register command

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    -- Specify your vault location(s)
    workspaces = {
      {
        name = "work",
        path = "~/work/notes",
      },
      -- Add more vaults if needed:
      -- {
      --   name = "work",
      --   path = "~/work/notes",
      -- },
    },

    -- Completion for wiki-links and tags
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },

    -- Wiki link configuration
    wiki_link_func = function(opts)
      return require("obsidian.util").wiki_link_id_prefix(opts)
    end,

    -- Where to put new notes (in vault root)
    notes_subdir = nil,  -- Create new notes in vault root (or specify a folder)

    -- Daily notes
    daily_notes = {
      folder = "daily",  -- Daily notes now in dedicated daily/ folder
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      template = "daily.md",  -- Use daily template from Templates/ folder
    },

    -- Templates
    templates = {
      subdir = "Templates",  -- Your existing Templates folder (capital T)
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {
        -- Custom substitution for daily notes - uses the note's date, not today
        quote = function()
          local weekly = require("neotex.obsidian.weekly")
          -- Get date from current buffer filename (daily notes are named YYYY-MM-DD.md)
          local filename = vim.fn.expand("%:t:r") -- Get filename without extension
          local note_date = filename:match("^%d%d%d%d%-%d%d%-%d%d$") and filename or os.date("%Y-%m-%d")
          local quote_data = weekly.get_daily_quote(note_date)
          return quote_data[1]
        end,
        author = function()
          local weekly = require("neotex.obsidian.weekly")
          -- Get date from current buffer filename (daily notes are named YYYY-MM-DD.md)
          local filename = vim.fn.expand("%:t:r") -- Get filename without extension
          local note_date = filename:match("^%d%d%d%d%-%d%d%-%d%d$") and filename or os.date("%Y-%m-%d")
          local quote_data = weekly.get_daily_quote(note_date)
          return quote_data[2]
        end,
        -- Previous day backlink
        previous_day = function()
          local filename = vim.fn.expand("%:t:r")
          local note_date = filename:match("^%d%d%d%d%-%d%d%-%d%d$") and filename or os.date("%Y-%m-%d")
          local year, month, day = note_date:match("(%d+)-(%d+)-(%d+)")
          if year and month and day then
            local ts = os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day) })
            local prev_ts = ts - (24 * 60 * 60)
            local prev_date = os.date("%Y-%m-%d", prev_ts)
            return string.format("[[%s]]", prev_date)
          end
          return ""
        end,
        -- Next day backlink
        next_day = function()
          local filename = vim.fn.expand("%:t:r")
          local note_date = filename:match("^%d%d%d%d%-%d%d%-%d%d$") and filename or os.date("%Y-%m-%d")
          local year, month, day = note_date:match("(%d+)-(%d+)-(%d+)")
          if year and month and day then
            local ts = os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day) })
            local next_ts = ts + (24 * 60 * 60)
            local next_date = os.date("%Y-%m-%d", next_ts)
            return string.format("[[%s]]", next_date)
          end
          return ""
        end,
        -- Weekly note backlink
        weekly_note = function()
          local weekly = require("neotex.obsidian.weekly")
          local filename = vim.fn.expand("%:t:r")
          local note_date = filename:match("^%d%d%d%d%-%d%d%-%d%d$") and filename or os.date("%Y-%m-%d")

          -- Parse the date to get timestamp
          local year, month, day = note_date:match("(%d+)-(%d+)-(%d+)")
          if not (year and month and day) then
            return ""
          end

          local ts = os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day) })
          local date_table = os.date("*t", ts)

          -- Find the week offset from today
          local today = os.time()
          local days_diff = math.floor((ts - today) / (24 * 60 * 60))
          local week_offset = math.floor(days_diff / 7)

          -- Get week info for this date
          local info = weekly.get_week_info(week_offset)
          local week_filename = string.format("%d-W%02d", info.year, info.week)

          return string.format("[[%s]]", week_filename)
        end,
        -- Task date format (@YYMMDD)
        task_date = function()
          local filename = vim.fn.expand("%:t:r")
          -- Only use filename if it matches daily note pattern (YYYY-MM-DD)
          local year, month, day = filename:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
          if not (year and month and day) then
            -- No fallback to os.date() - return empty if filename doesn't match
            return ""
          end
          return string.format("@%02d%02d%02d", tonumber(year) % 100, tonumber(month), tonumber(day))
        end,
      },
    },
    callbacks = {
      enter_note = function(client, note)
        dailies.ensure_daily_heading(client, note)

        -- Apply template substitutions for daily notes if not already applied
        if dailies.is_daily_note(client, note) then
          vim.defer_fn(function()
            if note.bufnr and vim.api.nvim_buf_is_loaded(note.bufnr) then
              -- Get buffer lines
              local lines = vim.api.nvim_buf_get_lines(note.bufnr, 0, -1, false)
              local modified = false

              -- Apply substitutions
              for i, line in ipairs(lines) do
                local new_line = line

                -- Replace each substitution pattern
                for key, func in pairs(client.opts.templates.substitutions) do
                  local pattern = "{{" .. key .. "}}"
                  if new_line:find(pattern, 1, true) then
                    local value = func()
                    new_line = new_line:gsub(pattern:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"), value)
                    modified = true
                  end
                end

                if new_line ~= line then
                  lines[i] = new_line
                end
              end

              -- Update buffer if modifications were made
              if modified then
                vim.api.nvim_buf_set_lines(note.bufnr, 0, -1, false, lines)
                vim.bo[note.bufnr].modified = false  -- Mark as not modified after template substitution
              end
            end
          end, 150)
        end
      end,
    },

    -- Don't manage frontmatter
    disable_frontmatter = false,

    -- Use markdown-style links for new links
    preferred_link_style = "markdown",  -- or "wiki" for [[links]]

    -- Customize how note IDs are generated
    note_id_func = function(title)
      -- Create note IDs from title, replacing spaces with dashes
      if title ~= nil then
        return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- Use timestamp if no title provided
        return tostring(os.time())
      end
    end,

    -- Optional UI settings
    ui = {
      enable = true,
      checkboxes = {
        [" "] = { char = "☐", hl_group = "ObsidianTodo" },
        ["x"] = { char = "☑", hl_group = "ObsidianDone" },
        [">"] = { char = "▶", hl_group = "ObsidianRightArrow" },
        ["~"] = { char = "◐", hl_group = "ObsidianTilde" },
      },
      external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
      reference_text = { hl_group = "ObsidianRefText" },
      highlight_text = { hl_group = "ObsidianHighlightText" },
      tags = { hl_group = "ObsidianTag" },
    },

    -- Follow link behavior
    follow_url_func = function(url)
      vim.fn.jobstart({"open", url})  -- macOS
    end,

    -- Mappings (set to false to disable)
    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle checkbox
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
    },
  },
  config = function(_, opts)
    local obsidian = require("obsidian")
    obsidian.setup(opts)
  end,
}
