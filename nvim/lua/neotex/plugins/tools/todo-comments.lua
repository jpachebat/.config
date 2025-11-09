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
  cmd = { 'TodoTelescope', 'TodoQuickFix', 'TodoLocList', 'TodoTrouble' },
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

