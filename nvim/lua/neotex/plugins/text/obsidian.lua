local function is_daily_note(client, note)
  local folder = client.opts.daily_notes.folder
  if not folder or not note.path then
    return false
  end

  local daily_dir = client.dir / folder
  local parent = note.path:parent()
  if parent and tostring(parent) == tostring(daily_dir) then
    return true
  end

  if daily_dir.is_parent_of and daily_dir:is_parent_of(note.path) then
    return true
  end

  return false
end

local function weekday_from_id(note_id)
  if not note_id then
    return nil
  end

  local year, month, day = tostring(note_id):match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
  if not year then
    return nil
  end

  local timestamp = os.time {
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = 12,
  }

  if not timestamp then
    return nil
  end

  return os.date("%a", timestamp)
end

local function ensure_daily_heading(client, note)
  if not is_daily_note(client, note) then
    return
  end

  local weekday = weekday_from_id(note.id)
  if not weekday then
    return
  end

  local alias = nil
  if note.aliases and #note.aliases > 0 then
    alias = note.aliases[#note.aliases]
  end
  local base_title = alias and alias ~= "" and alias or note.title or tostring(note.id)
  if not base_title or base_title == "" then
    return
  end

  local bufnr = note.bufnr
  if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  local desired_heading = string.format("# %s %s", weekday, base_title)
  local start_line = 0
  if note.frontmatter_end_line and note.frontmatter_end_line > 0 then
    start_line = note.frontmatter_end_line
  end

  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  local fetch_end = math.min(total_lines, start_line + 12)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, fetch_end, false)

  for idx, line in ipairs(lines) do
    if line:match("^#%s+") then
      local header_line = start_line + idx - 1
      if line ~= desired_heading then
        vim.api.nvim_buf_set_lines(bufnr, header_line, header_line + 1, false, { desired_heading })
      end
      return
    end
  end

  local insert_line = start_line
  if lines[1] ~= nil and lines[1]:match("^%s*$") then
    insert_line = insert_line + 1
  end
  vim.api.nvim_buf_set_lines(bufnr, insert_line, insert_line, false, { desired_heading, "" })
end

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
      folder = "week",  -- Your existing daily notes folder
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
    },

    -- Templates
    templates = {
      subdir = "Templates",  -- Your existing Templates folder (capital T)
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },
    callbacks = {
      enter_note = function(client, note)
        ensure_daily_heading(client, note)
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

    -- Helper to open daily notes with arbitrary offsets (weekends included)
    local function open_daily(offset)
      local client = obsidian.get_client()
      if not client then
        vim.notify("Obsidian client is not ready", vim.log.levels.ERROR)
        return
      end
      client:daily(offset)
    end

    -- Previous/next day commands that don't skip weekends (unlike upstream defaults)
    vim.api.nvim_create_user_command("ObsidianPrevDay", function(command_opts)
      local count = command_opts.count ~= 0 and command_opts.count or 1
      open_daily(-count)
    end, {
      desc = "Open the previous daily note (weekends included)",
      count = true,
    })

    vim.api.nvim_create_user_command("ObsidianNextDay", function(command_opts)
      local count = command_opts.count ~= 0 and command_opts.count or 1
      open_daily(count)
    end, {
      desc = "Open the next daily note (weekends included)",
      count = true,
    })
  end,
}
