-- neotex.plugins.editor.which-key
-- Keybinding configuration and display using which-key.nvim v3 API

--[[ WHICH-KEY MAPPINGS - COMPLETE REFERENCE
-----------------------------------------------------------

This module configures which-key.nvim using the modern v3 API with icon support.
All mappings are organized alphabetically by leader letter and use `cond` functions
for filetype-specific features instead of autocmds.

The configuration provides:
- Helper functions for filetype detection
- All mappings grouped by letter with conditional visibility
- Clean separation of concerns without autocmd pollution

----------------------------------------------------------------------------------
TOP-LEVEL MAPPINGS (<leader>)                   | DESCRIPTION
----------------------------------------------------------------------------------
<leader>c - Create vertical split               | Split window vertically
<leader>C - Create horizontal split             | Split window horizontally
<leader>d - Save and delete buffer              | Save file and close buffer
<leader>D - Insert timestamp                    | Insert current date/time (Mon YYYY-MM-DD HH:MM)
<leader>e - Toggle Neo-tree explorer            | Open/close visual file tree (sidebar)
<leader>E - Open oil.nvim explorer              | Edit filesystem like text buffer
<leader>k - Kill/close split                    | Close current split window
<leader>o - Show document outline               | Show file outline/sections (any file type)
<leader>O - Obsidian notes                      | Markdown: Daily notes, search, templates
<leader>q - Save all and quit                   | Save all files and exit Neovim
<leader>u - Open Telescope undo                 | Show undo history with preview
<leader>v - Terminal management                 | Access terminals 1-5, horizontal/vertical splits
<leader>w - Write all files                     | Save all open files

[Additional documentation continues as before...]
]]

-- Import notification module for TTS toggle functionality
local notify = require('neotex.util.notifications')

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = {
    'echasnovski/mini.nvim',
  },
  opts = {
    preset = "classic",
    delay = function(ctx)
      return ctx.plugin and 0 or 200
    end,
    show_help = false,    -- Remove bottom help/status bar
    show_keys = false,    -- Remove key hints
    win = {
      border = "rounded",
      padding = { 1, 2 },
      title = false,
      title_pos = "center",
      zindex = 1000,
      wo = {
        winblend = 10,
      },
      bo = {
        filetype = "which_key",
        buftype = "nofile",
      },
    },
    icons = {
      breadcrumb = "",
      separator = "",
      group = "",
      mappings = false,  -- Disable all built-in icons
    },
    layout = {
      width = { min = 20, max = 50 },
      height = { min = 4, max = 25 },
      spacing = 3,
      align = "left",
    },
    keys = {
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },
    sort = { "local", "order", "group", "alphanum", "mod" },
    disable = {
      bt = { "help", "quickfix", "terminal", "prompt" },
      ft = { "neo-tree" }
    },
    triggers = {
      { "<leader>", mode = { "n", "v" } }
    }
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- ============================================================================
    -- GLOBAL FUNCTIONS
    -- ============================================================================

    -- RunModelChecker: Find and run dev_cli.py for model checking
    _G.RunModelChecker = function()
      -- Try to find dev_cli.py in the current project or its parent
      local current_dir = vim.fn.getcwd()
      local dev_cli_path = nil

      -- Check current directory
      if vim.fn.filereadable(current_dir .. "/Code/dev_cli.py") == 1 then
        dev_cli_path = current_dir .. "/Code/dev_cli.py"
      -- Check if we're in a worktree and look in parent
      elseif current_dir:match("-feature-") or current_dir:match("-bugfix-") or current_dir:match("-refactor-") then
        local parent = current_dir:match("(.*/[^/]+)%-[^/]+%-[^/]+$")
        if parent and vim.fn.filereadable(parent .. "/Code/dev_cli.py") == 1 then
          dev_cli_path = parent .. "/Code/dev_cli.py"
        end
      -- Fallback to known ModelChecker location
      elseif vim.fn.filereadable("/home/benjamin/Documents/Philosophy/Projects/ModelChecker/Code/dev_cli.py") == 1 then
        dev_cli_path = "/home/benjamin/Documents/Philosophy/Projects/ModelChecker/Code/dev_cli.py"
      end

      if dev_cli_path then
        local file = vim.fn.expand("%:p:r") .. ".py"
        vim.cmd(string.format("TermExec cmd='%s %s'", dev_cli_path, file))
      else
        vim.notify("Could not find Code/dev_cli.py in project", vim.log.levels.ERROR)
      end
    end

    -- ============================================================================
    -- HELPER FUNCTIONS FOR FILETYPE DETECTION
    -- ============================================================================

    -- Toggle TTS_ENABLED in the project-specific config file
    -- @param config_path string Path to the tts-config.sh file
    -- @return success boolean True if toggle succeeded
    -- @return message string Success message ("TTS enabled" or "TTS disabled")
    -- @return error string Error message if success is false
    local function toggle_tts_config(config_path)
      -- Validate file exists (redundant check, but safe)
      if vim.fn.filereadable(config_path) ~= 1 then
        return false, nil, "Config file not readable: " .. config_path
      end

      -- Read file with error handling
      local ok, lines = pcall(vim.fn.readfile, config_path)
      if not ok then
        return false, nil, "Failed to read config: " .. tostring(lines)
      end

      -- Find and toggle TTS_ENABLED
      local modified = false
      local message
      for i, line in ipairs(lines) do
        if line:match("^TTS_ENABLED=") then
          if line:match("=true$") then
            lines[i] = "TTS_ENABLED=false"
            message = "TTS disabled"
          else
            lines[i] = "TTS_ENABLED=true"
            message = "TTS enabled"
          end
          modified = true
          break
        end
      end

      if not modified then
        return false, nil, "TTS_ENABLED not found in config file"
      end

      -- Write file with error handling
      local write_ok, write_err = pcall(vim.fn.writefile, lines, config_path)
      if not write_ok then
        return false, nil, "Failed to write config: " .. tostring(write_err)
      end

      return true, message, nil
    end

    local function is_latex()
      return vim.tbl_contains({ "tex", "latex", "bib", "cls", "sty" }, vim.bo.filetype)
    end

    local function is_python()
      return vim.bo.filetype == "python"
    end

    local function is_markdown()
      return vim.tbl_contains({ "markdown", "md" }, vim.bo.filetype)
    end

    local function is_lectic()
      return vim.tbl_contains({ "lec", "markdown", "md" }, vim.bo.filetype)
    end

    local function is_jupyter()
      return vim.bo.filetype == "ipynb"
    end

    local function is_jupyter_or_python()
      return vim.bo.filetype == "ipynb" or vim.bo.filetype == "python"
    end

    local function is_lean()
      return vim.bo.filetype == "lean"
    end

    local function is_pandoc_compatible()
      return vim.tbl_contains({ "markdown", "md", "tex", "latex", "org", "rst", "html", "docx" }, vim.bo.filetype)
    end

    local function is_mail()
      return vim.bo.filetype == "mail"
    end

    -- Himalaya disabled
    -- local function is_himalaya_list()
    --   return vim.bo.filetype == "himalaya-list"
    -- end

    -- local function is_himalaya_email()
    --   return vim.bo.filetype == "himalaya-email"
    -- end

    -- ============================================================================
    -- TOP-LEVEL SINGLE KEY MAPPINGS
    -- ============================================================================

    wk.add({
      { "<leader>c", "<cmd>vert sb<CR>", desc = "create vertical split" },
      { "<leader>C", "<cmd>split<CR>", desc = "create horizontal split" },
      { "<leader>d", "<cmd>update! | lua Snacks.bufdelete()<CR>", desc = "delete buffer" },
      { "<leader>D", function() vim.api.nvim_put({os.date("%a %Y-%m-%d %H:%M")}, "c", true, true) end, desc = "insert timestamp" },
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "explorer (neo-tree)" },
      { "<leader>E", "<cmd>Oil<CR>", desc = "explorer (oil)" },
      { "<leader>k", "<cmd>close<CR>", desc = "kill split" },
      { "<leader>o", function()
        -- Try LSP document symbols first, fallback to treesitter
        local has_lsp = #vim.lsp.get_active_clients({ bufnr = 0 }) > 0
        if has_lsp then
          require('telescope.builtin').lsp_document_symbols()
        else
          require('telescope.builtin').treesitter()
        end
      end, desc = "outline" },
      { "<leader>q", "<cmd>wa! | qa!<CR>", desc = "quit" },
      { "<leader>u", "<cmd>Telescope undo<CR>", desc = "undo" },
      { "<leader>v", group = "terminals" },
      { "<leader>v1", "<cmd>lua switch_terminal(1)<CR>", desc = "terminal 1" },
      { "<leader>v2", "<cmd>lua switch_terminal(2)<CR>", desc = "terminal 2" },
      { "<leader>v3", "<cmd>lua switch_terminal(3)<CR>", desc = "terminal 3" },
      { "<leader>v4", "<cmd>lua switch_terminal(4)<CR>", desc = "terminal 4" },
      { "<leader>v5", "<cmd>lua switch_terminal(5)<CR>", desc = "terminal 5" },
      { "<leader>vh", function() require("toggleterm.terminal").Terminal:new({ direction = "horizontal" }):toggle() end, desc = "horizontal split" },
      { "<leader>vv", function() require("toggleterm.terminal").Terminal:new({ direction = "vertical" }):toggle() end, desc = "vertical split" },
      { "<leader>w", "<cmd>wa!<CR>", desc = "write" },
      { "<leader>z", "<cmd>Snacks zen<CR>", desc = "zen mode" },
    })

    -- Global AI toggles are now in keymaps.lua for centralized management

    -- ============================================================================
    -- <leader>a - AI/ASSISTANT GROUP
    -- ============================================================================

    wk.add({
      { "<leader>a", group = "ai", mode = { "n", "v" } },

      -- Claude AI commands
      { "<leader>aT", function() require("neotex.plugins.ai.claude").smart_toggle() end, desc = "toggle claude", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>ClaudeCommands<CR>", desc = "claude commands" },
      { "<leader>ac",
        function() require("neotex.plugins.ai.claude.core.visual").send_visual_to_claude_with_prompt() end,
        desc = "send selection to claude with prompt",
        mode = { "v" }
      },
      { "<leader>as", function() require("neotex.plugins.ai.claude").resume_session() end, desc = "claude sessions" },
      { "<leader>av", "<cmd>ClaudeSessions<CR>", desc = "view worktrees" },
      { "<leader>aw", "<cmd>ClaudeWorktree<CR>", desc = "create worktree" },
      { "<leader>ar", "<cmd>ClaudeRestoreWorktree<CR>", desc = "restore closed worktree" },

      -- Avante AI commands
      { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "avante ask" },
      { "<leader>ae", "<cmd>AvanteEdit<CR>", desc = "avante edit", mode = { "v" } },
      { "<leader>ap", "<cmd>AvanteProvider<CR>", desc = "avante provider" },
      { "<leader>am", "<cmd>AvanteModel<CR>", desc = "avante model" },
      { "<leader>ax", "<cmd>MCPHubOpen<CR>", desc = "mcp hub" },

      -- Codex CLI terminal
      { "<leader>aX", function() require("neotex.plugins.ai.codex").toggle() end, desc = "toggle codex", mode = { "n", "v" } },

      -- ChatGPT commands
      { "<leader>ag", "<cmd>ChatGPT<CR>", desc = "chatgpt" },
      { "<leader>aG", "<cmd>ChatGPTActAs<CR>", desc = "chatgpt act as" },
      { "<leader>ai", "<cmd>ChatGPTEditWithInstructions<CR>", desc = "edit with instructions", mode = { "v" } },

      -- OpenAI CLI terminal (aichat)
      { "<leader>ao", function() require("neotex.plugins.ai.openai-cli").toggle() end, desc = "openai terminal" },

      -- Lectic actions (only for .lec and .md files)
      { "<leader>al", "<cmd>Lectic<CR>", desc = "lectic run", cond = is_lectic },
      { "<leader>al", "<cmd>LecticSubmitSelection<CR>", desc = "lectic selection", mode = { "v" }, cond = is_lectic },
      { "<leader>an", "<cmd>LecticCreateFile<CR>", desc = "new lectic file", cond = is_lectic },
      { "<leader>aP", "<cmd>LecticSelectProvider<CR>", desc = "provider select", cond = is_lectic },

      -- TTS toggle - project-specific only
      { "<leader>at", function()
        local config_path = vim.fn.getcwd() .. "/.claude/tts/tts-config.sh"

        if vim.fn.filereadable(config_path) ~= 1 then
          notify.editor(
            "No TTS config found. Use <leader>ac to create project-specific config.",
            notify.categories.ERROR,
            { project_root = vim.fn.getcwd() }
          )
          return
        end

        local success, message, error = toggle_tts_config(config_path)

        if success then
          notify.editor(
            message,
            notify.categories.USER_ACTION,
            { config_path = config_path }
          )
        else
          notify.editor(
            "Failed to toggle TTS: " .. error,
            notify.categories.ERROR,
            { config_path = config_path }
          )
        end
      end, desc = "toggle tts" },

      -- Yolo mode toggle - enables/disables --dangerously-skip-permissions flag
      { "<leader>ay", function()
        local config_path = vim.fn.expand("~/.config/nvim/lua/neotex/plugins/ai/claudecode.lua")

        if vim.fn.filereadable(config_path) ~= 1 then
          notify.editor(
            "Claude Code config not found",
            notify.categories.ERROR,
            { config_path = config_path }
          )
          return
        end

        local lines = vim.fn.readfile(config_path)
        local modified = false
        local yolo_enabled = false

        for i, line in ipairs(lines) do
          if line:match('%s*command = "claude') then
            if line:match('--dangerously%-skip%-permissions') then
              -- Disable yolo mode
              lines[i] = '    command = "claude",'
              yolo_enabled = false
            else
              -- Enable yolo mode
              lines[i] = '    command = "claude --dangerously-skip-permissions",'
              yolo_enabled = true
            end
            modified = true
            break
          end
        end

        if not modified then
          notify.editor(
            "Could not find command line in config",
            notify.categories.ERROR,
            { config_path = config_path }
          )
          return
        end

        local write_ok = pcall(vim.fn.writefile, lines, config_path)
        if not write_ok then
          notify.editor(
            "Failed to write config file",
            notify.categories.ERROR,
            { config_path = config_path }
          )
          return
        end

        notify.editor(
          yolo_enabled and "Yolo mode enabled (restart required)" or "Yolo mode disabled (restart required)",
          notify.categories.USER_ACTION,
          { config_path = config_path, yolo_enabled = yolo_enabled }
        )
      end, desc = "toggle yolo mode" },
    })

    -- ============================================================================
    -- <leader>f - FIND GROUP
    -- ============================================================================

    wk.add({
      { "<leader>f", group = "find", mode = { "n", "v" } },
      { "<leader>fa", "<cmd>lua require('telescope.builtin').find_files({ no_ignore = true, hidden = true, search_dirs = { '~/' } })<CR>", desc = "all files" },
      { "<leader>fb", "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<CR>", desc = "buffers" },
      { "<leader>fc", "<cmd>Telescope bibtex format_string=\\citet{%s}<CR>", desc = "citations" },
      { "<leader>fd", "<cmd>DeadlineTelescope<CR>", desc = "deadlines (by date)" },
      { "<leader>fe", function()
          require("telescope").extensions.file_browser.file_browser({
            path = vim.fn.expand("%:p:h"),
            select_buffer = true,
          })
        end,
        desc = "file browser" },
      { "<leader>ff", "<cmd>Telescope live_grep theme=ivy<CR>", desc = "project" },
      { "<leader>fl", "<cmd>Telescope resume<CR>", desc = "last search" },
      { "<leader>fo", function() require('neotex.telescope.logs').show_output_logs() end, desc = "output logs" },
      { "<leader>fp", "<cmd>lua require('neotex.util.misc').copy_buffer_path()<CR>", desc = "copy buffer path" },
      { "<leader>fq", "<cmd>Telescope quickfix<CR>", desc = "quickfix" },
      { "<leader>fg", "<cmd>Telescope git_commits<CR>", desc = "git history" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "help" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "keymaps" },
      { "<leader>fr", "<cmd>Telescope registers<CR>", desc = "registers" },
      { "<leader>fs", "<cmd>Telescope grep_string<CR>", desc = "string", mode = { "n", "v" } },
      { "<leader>fw", "<cmd>lua SearchWordUnderCursor()<CR>", desc = "word", mode = { "n", "v" } },
      { "<leader>fy", function() _G.YankyTelescopeHistory() end, desc = "yanks", mode = { "n", "v" } },
    })

    -- ============================================================================
    -- <leader>g - GIT GROUP
    -- ============================================================================

    wk.add({
      { "<leader>g", group = "git", mode = { "n", "v" } },
      { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "branches" },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gd", "<cmd>Gitsigns diffthis HEAD<CR>", desc = "diff HEAD" },
      -- { "<leader>gf", "<cmd>Telescope git_worktree create_git_worktree<CR>", desc = "new feature" },
      { "<leader>gg", function() require("snacks").lazygit() end, desc = "lazygit" },
      { "<leader>gh", "<cmd>Gitsigns prev_hunk<CR>", desc = "prev hunk" },
      { "<leader>gj", "<cmd>Gitsigns next_hunk<CR>", desc = "next hunk" },
      { "<leader>gl", "<cmd>Gitsigns blame_line<CR>", desc = "line blame", mode = { "n", "v" } },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", desc = "preview hunk" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
      { "<leader>gt", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "toggle blame" },
    })

    -- ============================================================================
    -- <leader>h - HELP GROUP
    -- ============================================================================

    wk.add({
      { "<leader>h", group = "help" },
      { "<leader>ha", "<cmd>Telescope autocommands<CR>", desc = "autocommands" },
      { "<leader>hc", "<cmd>Telescope commands<CR>", desc = "commands" },
      { "<leader>hh", "<cmd>Telescope help_tags<CR>", desc = "help tags" },
      { "<leader>hH", "<cmd>Telescope highlights<CR>", desc = "highlights" },
      { "<leader>hk", "<cmd>Telescope keymaps<CR>", desc = "keymaps" },
      { "<leader>hl", "<cmd>LspInfo<CR>", desc = "lsp info" },
      { "<leader>hL", "<cmd>Lazy<CR>", desc = "lazy plugin manager" },
      { "<leader>hm", "<cmd>Telescope man_pages<CR>", desc = "man pages" },
      { "<leader>hM", "<cmd>Mason<CR>", desc = "mason lsp installer" },
      { "<leader>hn", "<cmd>NullLsInfo<CR>", desc = "null-ls info" },
      { "<leader>hN", function() require("wezterm").switch_tab.relative(-1) end, desc = "wezterm prev" },
      { "<leader>ho", "<cmd>Telescope vim_options<CR>", desc = "vim options" },
      { "<leader>hP", function() require("wezterm").switch_tab.relative(1) end, desc = "wezterm next" },
      { "<leader>hr", "<cmd>Telescope reloader<CR>", desc = "reload modules" },
      { "<leader>ht", "<cmd>TSPlaygroundToggle<CR>", desc = "treesitter playground" },
      { "<leader>hT", function()
        local wezterm = require("wezterm")
        local count = vim.v.count
        if count > 0 then
          wezterm.switch_tab.index(count - 1) -- WezTerm uses 0-based indexing
        else
          vim.notify("Use count to specify tab (e.g., 2<leader>hT for tab 2)", vim.log.levels.INFO)
        end
      end, desc = "wezterm tab N" },
    })

    -- ============================================================================
    -- <leader>i - LSP & LINT GROUP
    -- ============================================================================

    wk.add({
      { "<leader>i", group = "lsp", mode = { "n", "v" } },
      { "<leader>ib", "<cmd>Telescope diagnostics bufnr=0<CR>", desc = "buffer diagnostics" },
      { "<leader>iB", "<cmd>LintToggle buffer<CR>", desc = "toggle buffer linting" },
      { "<leader>ic", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "code action", mode = { "n", "v" } },
      { "<leader>id", "<cmd>Telescope lsp_definitions<CR>", desc = "definition" },
      { "<leader>iD", "<cmd>lua vim.lsp.buf.declaration()<CR>", desc = "declaration" },
      { "<leader>ig", "<cmd>LintToggle<CR>", desc = "toggle global linting" },
      { "<leader>ih", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "help" },
      { "<leader>ii", "<cmd>Telescope lsp_implementations<CR>", desc = "implementations" },
      { "<leader>il", "<cmd>lua vim.diagnostic.open_float()<CR>", desc = "line diagnostics" },
      { "<leader>iL", function() require("lint").try_lint() end, desc = "lint file" },
      { "<leader>in", "<cmd>lua vim.diagnostic.goto_next()<CR>", desc = "next diagnostic" },
      { "<leader>ip", "<cmd>lua vim.diagnostic.goto_prev()<CR>", desc = "previous diagnostic" },
      { "<leader>ir", "<cmd>Telescope lsp_references<CR>", desc = "references" },
      { "<leader>iR", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "rename" },
      { "<leader>is", "<cmd>LspRestart<CR>", desc = "restart lsp" },
      { "<leader>it", function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
          vim.cmd('LspStop')
          require('neotex.util.notifications').lsp('LSP stopped', require('neotex.util.notifications').categories.USER_ACTION)
        else
          vim.cmd('LspStart')
          require('neotex.util.notifications').lsp('LSP started', require('neotex.util.notifications').categories.USER_ACTION)
        end
      end, desc = "toggle lsp" },
      { "<leader>iy", "<cmd>lua CopyDiagnosticsToClipboard()<CR>", desc = "copy diagnostics" },
    })

    -- ============================================================================
    -- <leader>j - JUPYTER GROUP
    -- ============================================================================

    wk.add({
      -- Group header (dynamic, only shows for jupyter files)
      { "<leader>j", group = function() return is_jupyter() and "jupyter" or nil end, cond = is_jupyter },

      -- Jupyter-specific mappings
      { "<leader>ja", "<cmd>lua require('notebook-navigator').run_all_cells()<CR>", desc = "run all cells", cond = is_jupyter },
      { "<leader>jb", "<cmd>lua require('notebook-navigator').run_cells_below()<CR>", desc = "run cells below", cond = is_jupyter },
      { "<leader>jc", "<cmd>lua require('notebook-navigator').comment_cell()<CR>", desc = "comment cell", cond = is_jupyter },
      { "<leader>jd", "<cmd>lua require('notebook-navigator').merge_cell('d')<CR>", desc = "merge with cell below", cond = is_jupyter },
      { "<leader>je", "<cmd>lua require('notebook-navigator').run_cell()<CR>", desc = "execute cell", cond = is_jupyter },
      { "<leader>jf", "<cmd>lua require('iron.core').send(nil, vim.fn.readfile(vim.fn.expand('%')))<CR>", desc = "send file to REPL", cond = is_jupyter },
      { "<leader>ji", "<cmd>lua require('iron.core').repl_for('python')<CR>", desc = "start IPython REPL", cond = is_jupyter },
      { "<leader>jj", "<cmd>lua require('notebook-navigator').move_cell('d')<CR>", desc = "next cell", cond = is_jupyter },
      { "<leader>jk", "<cmd>lua require('notebook-navigator').move_cell('u')<CR>", desc = "previous cell", cond = is_jupyter },
      { "<leader>jl", "<cmd>lua require('iron.core').send_line()<CR>", desc = "send line to REPL", cond = is_jupyter },
      { "<leader>jn", "<cmd>lua require('notebook-navigator').run_and_move()<CR>", desc = "execute and next", cond = is_jupyter },
      { "<leader>jo", "<cmd>lua require('neotex.util.diagnostics').add_jupyter_cell_with_closing()<CR>", desc = "insert cell below", cond = is_jupyter },
      { "<leader>jO", "<cmd>lua require('notebook-navigator').add_cell_above()<CR>", desc = "insert cell above", cond = is_jupyter },
      { "<leader>jq", "<cmd>lua require('iron.core').close_repl()<CR>", desc = "exit REPL", cond = is_jupyter },
      { "<leader>jr", "<cmd>lua require('iron.core').send(nil, string.char(12))<CR>", desc = "clear REPL", cond = is_jupyter },
      { "<leader>js", "<cmd>lua require('notebook-navigator').split_cell()<CR>", desc = "split cell", cond = is_jupyter },
      { "<leader>jt", "<cmd>lua require('iron.core').run_motion('send_motion')<CR>", desc = "send motion to REPL", cond = is_jupyter },
      { "<leader>ju", "<cmd>lua require('notebook-navigator').merge_cell('u')<CR>", desc = "merge with cell above", cond = is_jupyter },
      { "<leader>jv", "<cmd>lua require('iron.core').visual_send()<CR>", desc = "send visual selection to REPL", mode = { "n", "v" }, cond = is_jupyter_or_python },
    })

    -- ============================================================================
    -- <leader>l - LATEX GROUP
    -- ============================================================================

    wk.add({
      -- Group header (dynamic, only shows for LaTeX files)
      { "<leader>l", group = function() return is_latex() and "latex" or nil end, cond = is_latex },

      -- LaTeX-specific mappings
      { "<leader>la", "<cmd>lua PdfAnnots()<CR>", desc = "annotate", cond = is_latex },
      { "<leader>lb", "<cmd>terminal bibexport -o %:p:r.bib %:p:r.aux<CR>", desc = "bib export", cond = is_latex },
      { "<leader>lc", "<cmd>VimtexCompile<CR>", desc = "compile", cond = is_latex },
      { "<leader>le", "<cmd>VimtexErrors<CR>", desc = "errors", cond = is_latex },
      { "<leader>lf", "<cmd>terminal latexindent -w %:p:r.tex<CR>", desc = "format", cond = is_latex },
      { "<leader>lg", "<cmd>e ~/.config/nvim/templates/Glossary.tex<CR>", desc = "glossary", cond = is_latex },
      { "<leader>li", "<cmd>VimtexTocOpen<CR>", desc = "index", cond = is_latex },
      { "<leader>lk", "<cmd>VimtexClean<CR>", desc = "kill aux", cond = is_latex },
      { "<leader>lm", "<plug>(vimtex-context-menu)", desc = "menu", cond = is_latex },
      { "<leader>lv", "<cmd>VimtexView<CR>", desc = "view", cond = is_latex },
      { "<leader>lw", "<cmd>VimtexCountWords!<CR>", desc = "word count", cond = is_latex },
      { "<leader>lx", "<cmd>:VimtexClearCache All<CR>", desc = "clear cache", cond = is_latex },
    })

    -- <leader>m - Available for future use (mail removed)

    -- ============================================================================
    -- <leader>n - NIXOS GROUP
    -- ============================================================================

    wk.add({
      { "<leader>n", group = "nixos" },
      { "<leader>nd", "<cmd>TermExec cmd='nix develop'<CR><C-w>j", desc = "develop" },
      { "<leader>nf", "<cmd>TermExec cmd='sudo nixos-rebuild switch --flake ~/.dotfiles/'<CR><C-w>l", desc = "rebuild flake" },
      { "<leader>ng", "<cmd>TermExec cmd='nix-collect-garbage --delete-older-than 15d'<CR><C-w>j", desc = "garbage" },
      { "<leader>nh", "<cmd>TermExec cmd='home-manager switch --flake ~/.dotfiles/'<CR><C-w>l", desc = "home-manager" },
      { "<leader>nm", "<cmd>TermExec cmd='brave https://mynixos.com' open=0<CR>", desc = "my-nixos" },
      { "<leader>np", "<cmd>TermExec cmd='brave https://search.nixos.org/packages' open=0<CR>", desc = "packages" },
      { "<leader>nr", "<cmd>TermExec cmd='~/.dotfiles/update.sh'<CR><C-w>l", desc = "rebuild nix" },
      { "<leader>nu", "<cmd>TermExec cmd='nix flake update'<CR><C-w>j", desc = "update" },
    })

    -- ============================================================================
    -- <leader>O - OBSIDIAN GROUP
    -- ============================================================================

    -- Helper function to ensure obsidian is loaded
    local function obsidian_cmd(cmd)
      return function()
        require("lazy").load({ plugins = { "obsidian.nvim" } })
        vim.cmd(cmd)
      end
    end

    wk.add({
      -- Group header (always visible)
      { "<leader>O", group = "obsidian" },

      -- Daily notes (require markdown context for Obsidian commands)
      { "<leader>Od", obsidian_cmd("ObsidianToday"), desc = "today", cond = is_markdown },
      { "<leader>Oy", obsidian_cmd("ObsidianPrevDay"), desc = "prev day", cond = is_markdown },
      { "<leader>Ot", obsidian_cmd("ObsidianNextDay"), desc = "next day", cond = is_markdown },

      -- Weekly notes (work from anywhere - no markdown requirement)
      { "<leader>Ow", function() require("neotex.obsidian.weekly-commands").open_this_week() end, desc = "this week" },
      { "<leader>On", function() require("neotex.obsidian.weekly-commands").open_next_week() end, desc = "next week" },
      { "<leader>Op", function() require("neotex.obsidian.weekly-commands").open_previous_week() end, desc = "previous week" },

      -- Note management
      { "<leader>ON", obsidian_cmd("ObsidianNew"), desc = "new note", cond = is_markdown },
      { "<leader>Os", obsidian_cmd("ObsidianSearch"), desc = "search", cond = is_markdown },
      { "<leader>Oq", obsidian_cmd("ObsidianQuickSwitch"), desc = "quick switch", cond = is_markdown },
      { "<leader>Ob", obsidian_cmd("ObsidianBacklinks"), desc = "backlinks", cond = is_markdown },
      { "<leader>Ol", obsidian_cmd("ObsidianLinks"), desc = "links", cond = is_markdown },

      -- Open in Obsidian app
      { "<leader>Oo", function() require("neotex.obsidian.open-app").open_in_obsidian() end, desc = "open in app", cond = is_markdown },

      -- Templates
      { "<leader>OT", obsidian_cmd("ObsidianTemplate"), desc = "template", cond = is_markdown },
    })

    -- ============================================================================
    -- <leader>p - PANDOC GROUP
    -- ============================================================================

    wk.add({
      -- Group header (dynamic, only shows for pandoc-compatible files)
      { "<leader>p", group = function() return is_pandoc_compatible() and "pandoc" or nil end, cond = is_pandoc_compatible },

      -- Pandoc-specific mappings
      { "<leader>ph", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.html'<CR>", desc = "html", cond = is_pandoc_compatible },
      { "<leader>pl", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.tex'<CR>", desc = "latex", cond = is_pandoc_compatible },
      { "<leader>pm", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.md'<CR>", desc = "markdown", cond = is_pandoc_compatible },
      { "<leader>pp", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.pdf' open=0<CR>", desc = "pdf", cond = is_pandoc_compatible },
      { "<leader>pv", "<cmd>TermExec cmd='sioyek %:p:r.pdf &' open=0<CR>", desc = "view", cond = is_pandoc_compatible },
      { "<leader>pw", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.docx'<CR>", desc = "word", cond = is_pandoc_compatible },
    })

    -- ============================================================================
    -- <leader>r - RUN GROUP
    -- ============================================================================

    wk.add({
      { "<leader>r", group = "run" },
      { "<leader>rc", "<cmd>TermExec cmd='rm -rf ~/.cache/nvim' open=0<CR>", desc = "clear plugin cache" },
      { "<leader>rd", function()
          local notify = require('neotex.util.notifications')
          notify.toggle_debug_mode()
        end, desc = "toggle debug mode" },
      { "<leader>rl", "<cmd>lua require('neotex.util.diagnostics').show_all_errors()<CR>", desc = "show linter errors" },
      { "<leader>rf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "format", mode = { "n", "v" } },
      { "<leader>rF", "<cmd>lua ToggleAllFolds()<CR>", desc = "toggle all folds" },
      { "<leader>rh", "<cmd>LocalHighlightToggle<CR>", desc = "highlight" },
      { "<leader>rk", "<cmd>BufDeleteFile<CR>", desc = "kill file and buffer" },
      { "<leader>rK", "<cmd>TermExec cmd='rm -rf ~/.local/share/nvim/lazy && rm -f ~/.config/nvim/lazy-lock.json' open=0<CR>", desc = "wipe plugins and lock file" },
      { "<leader>ri", "<cmd>LeanInfoviewToggle<CR>", desc = "lean info", cond = is_lean },
      { "<leader>rm", "<cmd>lua RunModelChecker()<CR>", desc = "model checker", mode = "n" },
      { "<leader>rM", "<cmd>lua Snacks.notifier.show_history()<cr>", desc = "show messages" },
      { "<leader>ro", "za", desc = "toggle fold under cursor" },
      { "<leader>rp", "<cmd>TermExec cmd='python %:p:r.py'<CR>", desc = "python run", cond = is_python },
      { "<leader>rr", "<cmd>AutolistRecalculate<CR>", desc = "reorder list", cond = is_markdown },
      { "<leader>rR", "<cmd>ReloadConfig<cr>", desc = "reload configs" },
      { "<leader>re", "<cmd>Neotree ~/.config/nvim/snippets/<CR>", desc = "snippets edit" },
      { "<leader>rs", "<cmd>TermExec cmd='ssh brastmck@eofe10.mit.edu'<CR>", desc = "ssh" },
      -- { "<leader>rt", "<cmd>HimalayaTest<cr>", desc = "test himalaya" },
      { "<leader>rt", "<cmd>lua ToggleFoldingMethod()<CR>", desc = "toggle folding method" },
      { "<leader>ru", "<cmd>cd %:p:h | Neotree reveal<CR>", desc = "update cwd" },
      { "<leader>rg", "<cmd>lua OpenUrlUnderCursor()<CR>", desc = "go to URL" },
    })

    -- ============================================================================
    -- <leader>s - SURROUND GROUP
    -- ============================================================================

    wk.add({
      { "<leader>s", group = "surround", mode = { "n", "v" } },
      { "<leader>sc", "<Plug>(nvim-surround-change)", desc = "change" },
      { "<leader>sd", "<Plug>(nvim-surround-delete)", desc = "delete" },
      { "<leader>ss", "<Plug>(nvim-surround-normal)", desc = "surround", mode = "n" },
      { "<leader>ss", "<Plug>(nvim-surround-visual)", desc = "surround selection", mode = "v" },
    })

    -- ============================================================================
    -- <leader>S - SESSIONS GROUP
    -- ============================================================================

    wk.add({
      { "<leader>S", group = "sessions" },
      { "<leader>Sd", "<cmd>SessionManager delete_session<CR>", desc = "delete" },
      { "<leader>Sl", "<cmd>SessionManager load_session<CR>", desc = "load" },
      { "<leader>Ss", "<cmd>SessionManager save_current_session<CR>", desc = "save" },
    })

    -- ============================================================================
    -- <leader>t - TODO GROUP
    -- ============================================================================

    wk.add({
      { "<leader>t", group = "todo" },
      { "<leader>tc", function()
        local inbox_path = vim.fn.expand("~/work/notes/inbox.md")
        -- Create inbox.md if it doesn't exist
        if vim.fn.filereadable(inbox_path) == 0 then
          vim.fn.writefile({
            "# Inbox",
            "",
            "Quick captures to process later.",
            "",
            "## Captures",
            "",
          }, inbox_path)
        end
        -- Open in vertical split at bottom
        vim.cmd("botright split " .. vim.fn.fnameescape(inbox_path))
        -- Jump to end of file
        vim.cmd("normal! G")
        -- Enter insert mode on new line
        vim.cmd("normal! o")
        vim.cmd("startinsert")
      end, desc = "quick capture (inbox)" },
      { "<leader>td", "<cmd>DeadlineTelescope<CR>", desc = "deadlines (by date)" },
      { "<leader>te", function() require("neotex.util.date-expansion").expand_relative_date() end, desc = "expand @+N to date" },
      { "<leader>tk", "<cmd>TasksTelescope<CR>", desc = "tasks (by date)" },
      { "<leader>tl", "<cmd>TodoLocList<CR>", desc = "todo location list" },
      { "<leader>tn", function() require("todo-comments").jump_next() end, desc = "next todo" },
      { "<leader>to", function() require("neotex.util.todo-popup").toggle() end, desc = "todo popup (project)" },
      { "<leader>tp", function() require("todo-comments").jump_prev() end, desc = "previous todo" },
      { "<leader>tq", "<cmd>TodoQuickFix<CR>", desc = "todo quickfix" },
      { "<leader>tf", "<cmd>TodoSetFile ", desc = "set todo file (project)" },
      { "<leader>ts", function() require("neotex.util.todo-split").open_todo_split() end, desc = "todo section split" },
      { "<leader>tt", "<cmd>TodoTelescope<CR>", desc = "todo telescope (all)" },
      { "<leader>tx", "<cmd>CompletedTasksTelescope<CR>", desc = "completed tasks" },
    })

    -- ============================================================================
    -- <leader>T - TEMPLATES GROUP (LaTeX)
    -- ============================================================================

    wk.add({
      -- Group header (dynamic, only shows for LaTeX files)
      { "<leader>T", group = function() return is_latex() and "templates" or nil end, cond = is_latex },

      -- Template mappings
      { "<leader>Ta", "<cmd>read ~/.config/nvim/templates/article.tex<CR>", desc = "article.tex", cond = is_latex },
      { "<leader>Tb", "<cmd>read ~/.config/nvim/templates/beamer_slides.tex<CR>", desc = "beamer_slides.tex", cond = is_latex },
      { "<leader>Tg", "<cmd>read ~/.config/nvim/templates/glossary.tex<CR>", desc = "glossary.tex", cond = is_latex },
      { "<leader>Th", "<cmd>read ~/.config/nvim/templates/handout.tex<CR>", desc = "handout.tex", cond = is_latex },
      { "<leader>Tl", "<cmd>read ~/.config/nvim/templates/letter.tex<CR>", desc = "letter.tex", cond = is_latex },
      { "<leader>Tm", "<cmd>read ~/.config/nvim/templates/MultipleAnswer.tex<CR>", desc = "MultipleAnswer.tex", cond = is_latex },
      { "<leader>Tr", function()
        local template_dir = vim.fn.expand("~/.config/nvim/templates/report")
        local current_dir = vim.fn.getcwd()
        vim.fn.system("cp -r " .. vim.fn.shellescape(template_dir) .. " " .. vim.fn.shellescape(current_dir))
        require('neotex.util.notifications').editor('Template copied', require('neotex.util.notifications').categories.USER_ACTION, { template = 'report', directory = current_dir })
      end, desc = "Copy report/ directory", cond = is_latex },
      { "<leader>Ts", function()
        local template_dir = vim.fn.expand("~/.config/nvim/templates/springer")
        local current_dir = vim.fn.getcwd()
        vim.fn.system("cp -r " .. vim.fn.shellescape(template_dir) .. " " .. vim.fn.shellescape(current_dir))
        require('neotex.util.notifications').editor('Template copied', require('neotex.util.notifications').categories.USER_ACTION, { template = 'springer', directory = current_dir })
      end, desc = "Copy springer/ directory", cond = is_latex },
    })

    -- ============================================================================
    -- <leader>x - TEXT GROUP
    -- ============================================================================

    wk.add({
      { "<leader>x", group = "text", mode = { "n", "v" } },
      { "<leader>xa", desc = "align", mode = { "n", "v" } },
      { "<leader>xA", desc = "align with preview", mode = { "n", "v" } },
      { "<leader>xd", desc = "toggle diff overlay" },
      { "<leader>xs", desc = "split/join toggle", mode = { "n", "v" } },
      { "<leader>xw", desc = "toggle word diff" },
    })

    -- ============================================================================
    -- <leader>y - YANK GROUP
    -- ============================================================================

    wk.add({
      { "<leader>y", group = "yank", mode = { "n", "v" } },
      { "<leader>yc", function() require("yanky").clear_history() end, desc = "clear history" },
      { "<leader>yh", function() _G.YankyTelescopeHistory() end, desc = "yank history", mode = { "n", "v" } },
    })
  end,
}
