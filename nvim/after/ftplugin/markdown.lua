-- Enhanced Jupyter styling for Markdown files (.md)
if vim.fn.expand("%:e") == "md" then
  -- Check if this is a Jupyter-converted markdown file
  local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
  local is_jupyter = false

  for _, line in ipairs(lines) do
    if line:match("^```python") then
      is_jupyter = true
      break
    end
  end

  if is_jupyter then
    -- Apply Jupyter notebook styling
    vim.opt_local.signcolumn = "yes:1"

    -- Ensure our styling module is loaded
    vim.defer_fn(function()
      local ok, styling = pcall(require, "neotex.plugins.tools.jupyter.styling")
      if ok and type(styling) == "table" and styling.setup then
        styling.setup()
      end
    end, 100)
  end
end

-- Soft-wrap settings for one-sentence-per-line workflow
vim.opt_local.wrap = true           -- Enable line wrapping
vim.opt_local.linebreak = true      -- Break at word boundaries
vim.opt_local.breakindent = true    -- Preserve indentation in wrapped lines
vim.opt_local.showbreak = ""        -- No indicator for wrapped lines
vim.opt_local.display:append("lastline")  -- Show as much of last line as possible

-- Note: What you're asking for (visually joining hard line breaks into continuous text)
-- is not natively supported by Vim/Neovim. The above settings provide soft-wrapping
-- for long lines, but won't visually merge separate lines.
--
-- For true visual paragraph joining, you would need:
-- 1. A custom plugin using extmarks/virtual text to hide newlines
-- 2. Or use external tools like 'par' or 'fmt' to reformat (but this changes the file)
-- 3. Or work with actual paragraphs (no line breaks between sentences)
--
-- Current behavior: Lines wrap at window width, but hard breaks remain visible

-- Set conceallevel for markdown (required by render-markdown and obsidian.nvim)
-- Note: Obsidian requires conceallevel 1 or 2 (not 3) to work properly
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = ""   -- Always conceal, even when cursor is on line

-- LaTeX math concealment in markdown
-- Set concealment options for math
vim.g.tex_conceal = 'abdmg'
vim.g.tex_superscripts = '[0-9a-zA-W.,:;+-<>/()=]'
vim.g.tex_subscripts = '[0-9aehijklmnoprstuvx,+-/().]'

-- Include TeX syntax groups for concealment WITHOUT replacing markdown syntax
vim.cmd([[
  " Include TeX concealment syntax groups (not full tex.vim)
  runtime! syntax/shared/tex-conceal.vim

  " Define math zones that include TeX concealment
  syntax cluster texMathZoneGroup contains=texMathSymbol,texGreek,texSuperscript,texSubscript,texMathOper

  " Block math $$...$$
  syntax region texMathZoneBlock start="\$\$" end="\$\$" keepend contains=@texMathZoneGroup

  " Inline math $...$ (not $$)
  syntax region texMathZoneInline start="\$" end="\$" skip="\\\$" keepend oneline contains=@texMathZoneGroup

  hi def link texMathZoneBlock Special
  hi def link texMathZoneInline Special
]])

-- Ensure markdown syntax is still loaded (render-markdown handles this)
vim.cmd('syntax sync fromstart')

-- Apply custom markdown comment and task highlighting
local function apply_highlighting()
  -- Define muted color for comments (Gruvbox gray)
  local muted_color = "#928374"

  -- Ensure HTML comment highlights are set
  vim.api.nvim_set_hl(0, "htmlComment", { fg = muted_color, italic = true })
  vim.api.nvim_set_hl(0, "htmlCommentPart", { fg = muted_color, italic = true })
  vim.api.nvim_set_hl(0, "RenderMarkdownHtmlComment", { fg = muted_color, italic = true })

  -- Task deadline highlighting - bright red for visibility
  vim.api.nvim_set_hl(0, "TaskDeadline", { fg = "#E82424", bold = true })

  -- Custom syntax for task deadlines
  vim.cmd([[
    syntax clear TaskDeadline
    syntax match TaskDeadline /@\d\{4\}-\d\{2\}-\d\{2\}/
  ]])
end

-- Apply immediately
apply_highlighting()

-- Re-apply on events
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter", "ColorScheme", "Syntax"}, {
  buffer = 0,
  callback = apply_highlighting,
})

-- Obsidian-style wiki-link and task management keybindings
local ok_obsidian, obsidian = pcall(require, "obsidian")
local ok_tasks, tasks = pcall(require, "neotex.util.tasks")

if ok_obsidian or ok_tasks then
  local ok_wk, wk = pcall(require, "which-key")
  if ok_wk then
    local mappings = {
      { "<leader>m", group = "markdown/notes", icon = "󰈙", buffer = 0 },
    }

    -- Add Obsidian mappings if available
    if ok_obsidian then
      table.insert(mappings, { "<leader>mn", "<cmd>ObsidianNew<CR>", desc = "new note", icon = "󰝒", buffer = 0 })
      table.insert(mappings, { "<leader>mf", "<cmd>ObsidianQuickSwitch<CR>", desc = "find note", icon = "󰍉", buffer = 0 })
      table.insert(mappings, { "<leader>ms", "<cmd>ObsidianSearch<CR>", desc = "search notes", icon = "󰺮", buffer = 0 })
      table.insert(mappings, { "<leader>ml", "<cmd>ObsidianBacklinks<CR>", desc = "backlinks", icon = "󰌷", buffer = 0 })
      table.insert(mappings, { "<leader>mt", "<cmd>ObsidianTags<CR>", desc = "tags", icon = "󰓹", buffer = 0 })
      table.insert(mappings, { "<leader>md", function() require("neotex.obsidian.dailies").open_daily(0, { ensure_loaded = true }) end, desc = "daily note", icon = "󰃰", buffer = 0 })
      table.insert(mappings, { "<leader>mT", "<cmd>ObsidianTemplate<CR>", desc = "insert template", icon = "󰈙", buffer = 0 })
      table.insert(mappings, { "<leader>mo", "<cmd>ObsidianOpen<CR>", desc = "open in Obsidian", icon = "󰏋", buffer = 0 })
    end

    -- Add task management mappings if available
    if ok_tasks then
      table.insert(mappings, { "<leader>mx", function() tasks.show_tasks_telescope({vault = false}) end, desc = "tasks (file)", icon = "☐", buffer = 0 })
      table.insert(mappings, { "<leader>mX", function() tasks.show_tasks_telescope({vault = true}) end, desc = "tasks (vault)", icon = "☐", buffer = 0 })
      table.insert(mappings, { "<leader>mi", tasks.insert_task_with_deadline, desc = "task (full)", icon = "󰄬", buffer = 0 })
      table.insert(mappings, { "<leader>mI", tasks.quick_insert_task, desc = "task (quick)", icon = "󰄬", buffer = 0 })
    end

    wk.add(mappings)
  end
end

-- Setup markdown anchor navigation (for TOC links)
local markdown_nav = require("neotex.util.markdown-nav")

-- Use <CR> (Enter) on TOC links instead of gf to avoid conflicts
vim.keymap.set("n", "<CR>", markdown_nav.follow_anchor, {
  buffer = true,
  desc = "Follow markdown anchor"
})

-- Also keep gf but with higher priority
vim.keymap.set("n", "gf", markdown_nav.follow_anchor, {
  buffer = true,
  desc = "Follow markdown anchor",
  silent = true,
})

-- Markdown-specific nvim-surround configuration
-- These surrounds are only available in markdown files
-- Use vim.schedule to ensure this runs after all plugins are loaded
vim.schedule(function()
  local ok, surround = pcall(require, "nvim-surround")
  if not ok then
    return
  end

  surround.buffer_setup({
  -- Explicitly disable aliases that conflict with our custom surrounds
  aliases = {
    a = ">",
    r = "]",
    q = { '"', "'", "`" },
    s = { "}", "]", ")", ">", '"', "'", "`" },
    -- Explicitly set b and i to false to disable the aliases
    b = false,
    i = false,
    B = "}",  -- Keep this one
  },
  surrounds = {
    -- Bold: **text** (double asterisk for strong emphasis)
    ["b"] = {
      add = { "**", "**" },
      find = "%*%*.-%*%*",
      delete = "^(%*%*)().-(%*%*)()$",
    },
    -- Italic: *text* (single asterisk for emphasis)
    ["i"] = {
      add = { "*", "*" },
      find = "%*.-%*",
      delete = "^(%*)().-(%)()$",
    },
    -- Inline code: `text` (backtick for code)
    ["`"] = {
      add = { "`", "`" },
      find = "`.-`",
      delete = "^(`)().-(`)()$",
    },
    -- Code block: ```language\ntext\n``` (fenced code block with language prompt)
    ["c"] = {
      add = function()
        local lang = vim.fn.input("Language: ")
        return { { "```" .. lang, "" }, { "", "```" } }
      end,
    },
    -- Link: [text](url) (markdown link with URL prompt)
    ["l"] = {
      add = function()
        local url = vim.fn.input("URL: ")
        return { { "[", "](" .. url .. ")" } }
      end,
    },
    -- Strikethrough: ~~text~~ (GFM strikethrough)
    ["~"] = {
      add = { "~~", "~~" },
      find = "~~.-~~",
      delete = "^(~~)().-(~~)()$",
    },
  },
  })
end)

