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
}
