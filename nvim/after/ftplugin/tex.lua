-- We're now using nvim-surround instead of mini.surround
-- LaTeX-specific surround configurations are in lua/neotex/plugins/coding/surround.lua

-- This file includes buffer-specific surround configuration
require("nvim-surround").buffer_setup({
  surrounds = {
    -- LaTeX environments
    ["e"] = {
      add = function()
        local env = vim.fn.input("Environment: ")
        return { { "\\begin{" .. env .. "}" }, { "\\end{" .. env .. "}" } }
      end,
    },
    -- LaTeX quotes
    ["Q"] = {
      add = { "``", "''" },
      find = "%b``.-''",
      delete = "^(``)().-('')()$",
    },
    -- LaTeX single quotes
    ["q"] = {
      add = { "`", "'" },
      find = "`.-'",
      delete = "^(`)().-(')()$",
    },
    -- LaTeX text formatting
    ["b"] = {
      add = { "\\textbf{", "}" },
      find = "\\%a-bf%b{}",
      delete = "^(\\%a-bf{)().-(})()$",
    },
    ["i"] = {
      add = { "\\textit{", "}" },
      find = "\\%a-it%b{}",
      delete = "^(\\%a-it{)().-(})()$",
    },
    ["t"] = {
      add = { "\\texttt{", "}" },
      find = "\\%a-tt%b{}",
      delete = "^(\\%a-tt{)().-(})()$",
    },
    ["$"] = {
      add = { "$", "$" },
    },
  },
})

-- PdfAnnots
function PdfAnnots()
  local ok, pdf = pcall(vim.api.nvim_eval,
    "vimtex#context#get().handler.get_actions().entry.file")
  if not ok then
    vim.notify "No file found"
    return
  end

  local cwd = vim.fn.getcwd()
  vim.fn.chdir(vim.b.vimtex.root)

  if vim.fn.isdirectory('Annotations') == 0 then
    vim.fn.mkdir('Annotations')
  end

  local md = vim.fn.printf("Annotations/%s.md", vim.fn.fnamemodify(pdf, ":t:r"))
  -- vim.fn.system(vim.fn.printf('pdfannots -o "%s" "%s"', md, pdf))
  vim.fn.system(string.format('pdfannots -o "%s" "%s"', md, pdf))
  vim.cmd.edit(vim.fn.fnameescape(md))

  vim.fn.chdir(cwd)
end

-- Enable full-line syntax highlighting for LaTeX files
-- Override the global synmaxcol=200 setting for better LaTeX support
vim.opt_local.synmaxcol = 0  -- 0 means no limit

-- Soft-wrap settings for one-sentence-per-line workflow
vim.opt_local.wrap = true           -- Enable line wrapping
vim.opt_local.linebreak = true      -- Break at word boundaries
vim.opt_local.breakindent = true    -- Preserve indentation in wrapped lines
vim.opt_local.showbreak = ""        -- No indicator for wrapped lines
vim.opt_local.display:append("lastline")  -- Show as much of last line as possible

-- LaTeX concealment settings (tex-conceal.vim)
vim.opt_local.conceallevel = 2  -- Enable concealment (0=off, 2=on with cursor reveal)
vim.opt_local.concealcursor = "n"  -- Show actual text when cursor is on the line (in normal mode)

-- Configure tex-conceal.vim symbols
vim.g.tex_conceal = "abdmgs"  -- Enable conceal for:
                              -- a = accents/ligatures
                              -- b = bold/italic
                              -- d = delimiters (e.g., \left, \right)
                              -- m = math symbols (α, β, ∑, etc.)
                              -- g = Greek letters
                              -- s = superscripts/subscripts

-- Custom concealment for natbib citations
-- Add syntax rules for \citet{} and \citep{}
vim.cmd([[
  " Conceal \citet{key} as [key]
  syntax match texCiteT "\\citet\*\?{[^}]\+}" contains=texCiteTBrace,texCiteTKey
  syntax match texCiteTBrace contained "\\citet\*\?{" conceal cchar=[
  syntax match texCiteTBrace contained "}" conceal cchar=]
  syntax match texCiteTKey contained "[^{}]\+"

  " Conceal \citep{key} as (key)
  syntax match texCiteP "\\citep\*\?{[^}]\+}" contains=texCitePBrace,texCitePKey
  syntax match texCitePBrace contained "\\citep\*\?{" conceal cchar=(
  syntax match texCitePBrace contained "}" conceal cchar=)
  syntax match texCitePKey contained "[^{}]\+"

  " Also handle \cite{} as [key]
  syntax match texCite "\\cite\*\?{[^}]\+}" contains=texCiteBrace,texCiteKey
  syntax match texCiteBrace contained "\\cite\*\?{" conceal cchar=[
  syntax match texCiteBrace contained "}" conceal cchar=]
  syntax match texCiteKey contained "[^{}]\+"

  " Highlighting for citation keys
  highlight link texCiteTKey Identifier
  highlight link texCitePKey Identifier
  highlight link texCiteKey Identifier
]])

-- Custom concealment for equation delimiters
-- Conceal \[ and \] (display math), and equation environment delimiters
vim.cmd([[
  " Conceal display math delimiters \[ and \]
  syntax match texMathDelimOpen "\\\[" conceal
  syntax match texMathDelimClose "\\\]" conceal

  " Conceal equation environment delimiters
  syntax match texEquationBegin "\\begin{equation\*\?}" conceal
  syntax match texEquationEnd "\\end{equation\*\?}" conceal

  " Conceal align environment delimiters
  syntax match texAlignBegin "\\begin{align\*\?}" conceal
  syntax match texAlignEnd "\\end{align\*\?}" conceal

  " Conceal gather environment delimiters
  syntax match texGatherBegin "\\begin{gather\*\?}" conceal
  syntax match texGatherEnd "\\end{gather\*\?}" conceal

  " Conceal multline environment delimiters
  syntax match texMultlineBegin "\\begin{multline\*\?}" conceal
  syntax match texMultlineEnd "\\end{multline\*\?}" conceal
]])

-- Optional: Add more natbib citation commands
vim.cmd([[
  " \citealp{key} as key (no brackets)
  syntax match texCiteAlp "\\citealp\*\?{[^}]\+}" contains=texCiteAlpBrace,texCiteAlpKey
  syntax match texCiteAlpBrace contained "\\citealp\*\?{" conceal
  syntax match texCiteAlpBrace contained "}" conceal
  syntax match texCiteAlpKey contained "[^{}]\+"
  highlight link texCiteAlpKey Identifier

  " \citealt{key} as key (no brackets)
  syntax match texCiteAlt "\\citealt\*\?{[^}]\+}" contains=texCiteAltBrace,texCiteAltKey
  syntax match texCiteAltBrace contained "\\citealt\*\?{" conceal
  syntax match texCiteAltBrace contained "}" conceal
  syntax match texCiteAltKey contained "[^{}]\+"
  highlight link texCiteAltKey Identifier
]])

-- Toggle concealment function
local function toggle_conceal()
  if vim.wo.conceallevel == 0 then
    vim.wo.conceallevel = 2
    vim.notify("LaTeX concealment enabled", vim.log.levels.INFO)
  else
    vim.wo.conceallevel = 0
    vim.notify("LaTeX concealment disabled", vim.log.levels.INFO)
  end
end

-- LaTeX section picker using Telescope
local function latex_sections_picker()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")

  -- Define highlight groups for different section levels
  vim.api.nvim_set_hl(0, "TelescopeLatexChapter", { fg = "#7E2F92", bold = true })      -- Deep purple
  vim.api.nvim_set_hl(0, "TelescopeLatexSection", { fg = "#0A3D6B", bold = true })      -- Deep blue
  vim.api.nvim_set_hl(0, "TelescopeLatexSubsection", { fg = "#1F6B2E" })                -- Dark green
  vim.api.nvim_set_hl(0, "TelescopeLatexSubsubsection", { fg = "#8F4700" })             -- Dark orange
  vim.api.nvim_set_hl(0, "TelescopeLatexParagraph", { fg = "#6B6B6B" })                 -- Gray
  vim.api.nvim_set_hl(0, "TelescopeLatexEquation", { fg = "#A53500", italic = true })   -- Orange-red

  -- Get all lines from current buffer
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local sections = {}
  local equations = {}
  local show_equations = false

  -- Counters for each level (chapter, section, subsection, subsubsection, paragraph, subparagraph)
  local counters = {0, 0, 0, 0, 0, 0}

  -- Parse for LaTeX sections
  for i, line in ipairs(lines) do
    local section_type = line:match("\\(chapter%*?)%s*{")
      or line:match("\\(section%*?)%s*{")
      or line:match("\\(subsection%*?)%s*{")
      or line:match("\\(subsubsection%*?)%s*{")
      or line:match("\\(paragraph%*?)%s*{")
      or line:match("\\(subparagraph%*?)%s*{")

    if section_type then
      local title = line:match("{(.-)}")
      local depth = 0
      local is_starred = section_type:match("%*$")  -- Check if it's a starred section

      if section_type:match("^chapter") then depth = 0
      elseif section_type:match("^section") then depth = 1
      elseif section_type:match("^subsection") then depth = 2
      elseif section_type:match("^subsubsection") then depth = 3
      elseif section_type:match("^paragraph") then depth = 4
      elseif section_type:match("^subparagraph") then depth = 5
      end

      -- Update counters (only for non-starred sections)
      if not is_starred then
        counters[depth + 1] = counters[depth + 1] + 1
        -- Reset all deeper level counters
        for j = depth + 2, 6 do
          counters[j] = 0
        end
      end

      -- Build section number string
      local number_str = ""
      if not is_starred then
        -- Find the first non-zero counter (top-level section type)
        local start_level = 1
        for j = 1, depth + 1 do
          if counters[j] > 0 then
            start_level = j
            break
          end
        end

        -- Build number from first used level to current depth
        local num_parts = {}
        for j = start_level, depth + 1 do
          table.insert(num_parts, tostring(counters[j]))
        end
        number_str = table.concat(num_parts, ".") .. " "
      end

      local indent = string.rep("  ", depth)
      local display_text = indent .. number_str .. title

      -- Determine highlight group based on section type
      local hl_group = "TelescopeLatexSection"
      if section_type:match("^chapter") then
        hl_group = "TelescopeLatexChapter"
      elseif section_type:match("^section") and not section_type:match("subsection") then
        hl_group = "TelescopeLatexSection"
      elseif section_type:match("^subsection") and not section_type:match("subsubsection") then
        hl_group = "TelescopeLatexSubsection"
      elseif section_type:match("^subsubsection") then
        hl_group = "TelescopeLatexSubsubsection"
      elseif section_type:match("^paragraph") then
        hl_group = "TelescopeLatexParagraph"
      end

      table.insert(sections, {
        lnum = i,
        text = display_text,
        type = section_type,
        hl_group = hl_group,
        is_equation = false,
      })
    end

    -- Also parse equations (equation, align, gather environments)
    if line:match("\\begin{equation}") or line:match("\\begin{align") or
       line:match("\\begin{gather}") or line:match("\\%[") then
      -- Look ahead to find label or extract content
      local eq_label = ""
      local eq_preview = ""

      -- Check next few lines for label
      for j = i, math.min(i + 5, #lines) do
        local label_match = lines[j]:match("\\label{(.-)}")
        if label_match then
          eq_label = label_match
          break
        end
        -- Get first line of equation for preview
        if eq_preview == "" and lines[j]:match("[^\\%%]") then
          eq_preview = lines[j]:gsub("^%s+", ""):sub(1, 40)
        end
      end

      local eq_text = "    📐 Equation"
      if eq_label ~= "" then
        eq_text = eq_text .. ": " .. eq_label
      elseif eq_preview ~= "" then
        eq_text = eq_text .. ": " .. eq_preview .. "..."
      end

      table.insert(equations, {
        lnum = i,
        text = eq_text,
        type = "equation",
        hl_group = "TelescopeLatexEquation",
        is_equation = true,
      })
    end
  end

  -- Function to create picker with current state
  local function create_picker()
    -- Combine sections and equations if show_equations is true
    local all_items = {}

    -- Always add sections
    for i = #sections, 1, -1 do
      table.insert(all_items, sections[i])
    end

    -- Add equations if enabled
    if show_equations then
      for i = #equations, 1, -1 do
        table.insert(all_items, equations[i])
      end

      -- Sort by line number (descending) to interleave them properly and maintain top-to-bottom order
      table.sort(all_items, function(a, b)
        return a.lnum > b.lnum
      end)
    end

    local title = show_equations
      and "LaTeX Outline (<C-u/d> scroll, Enter jump, <C-e> hide equations)"
      or "LaTeX Outline (<C-u/d> scroll, Enter jump, <C-e> show equations)"

    pickers.new({}, {
      prompt_title = title,
      finder = finders.new_table({
        results = all_items,
        entry_maker = function(entry)
          local make_display = function(e)
            local displayer = entry_display.create({
              separator = "",
              items = {{ remaining = true }},
            })
            return displayer({{ e.text, e.hl_group }})
          end

          return {
            value = entry,
            display = make_display,
            ordinal = entry.text,
            lnum = entry.lnum,
            text = entry.text,
            hl_group = entry.hl_group,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        -- Default Enter action: jump to section/equation
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.api.nvim_win_set_cursor(0, {selection.lnum, 0})
          vim.cmd("normal! zz")
        end)

        -- Ctrl-u/d: Scroll results list (like in buffers)
        map("i", "<C-u>", actions.results_scrolling_up)
        map("i", "<C-d>", actions.results_scrolling_down)
        map("n", "<C-u>", actions.results_scrolling_up)
        map("n", "<C-d>", actions.results_scrolling_down)

        -- Ctrl-e: Toggle equations
        map("i", "<C-e>", function()
          show_equations = not show_equations
          actions.close(prompt_bufnr)
          vim.schedule(function()
            create_picker()
          end)
        end)

        map("n", "<C-e>", function()
          show_equations = not show_equations
          actions.close(prompt_bufnr)
          vim.schedule(function()
            create_picker()
          end)
        end)

        return true
      end,
    }):find()
  end

  -- Start with initial picker
  create_picker()
end

-- Register LaTeX-specific which-key mappings for this buffer
local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
  -- LaTeX commands
  wk.add({
    { "<leader>l", group = "latex", icon = "󰙩", buffer = 0 },
    { "<leader>la", "<cmd>lua PdfAnnots()<CR>", desc = "annotate", icon = "󰏪", buffer = 0 },
    { "<leader>lb", "<cmd>terminal bibexport -o %:p:r.bib %:p:r.aux<CR>", desc = "bib export", icon = "󰈝", buffer = 0 },
    { "<leader>lc", "<cmd>VimtexCompile<CR>", desc = "compile", icon = "󰖷", buffer = 0 },
    { "<leader>lC", toggle_conceal, desc = "toggle conceal", icon = "󰈈", buffer = 0 },
    { "<leader>ld", "<cmd>terminal LATEXMK_DRAFT_MODE=1 latexmk -pdf -e '$draft_mode=1' %:p<CR>", desc = "draft mode", icon = "󰌶", buffer = 0 },
    { "<leader>le", "<cmd>VimtexErrors<CR>", desc = "errors", icon = "󰅚", buffer = 0 },
    { "<leader>lf", "<cmd>terminal latexmk -pdf %:p<CR>", desc = "final build", icon = "󰸞", buffer = 0 },
    { "<leader>lg", "<cmd>e ~/.config/nvim/templates/Glossary.tex<CR>", desc = "glossary", icon = "󰈚", buffer = 0 },
    { "<leader>lh", "<cmd>terminal latexindent -w %:p:r.tex<CR>", desc = "format", icon = "󰉣", buffer = 0 },
    { "<leader>li", "<cmd>VimtexTocOpen<CR>", desc = "index (sidebar)", icon = "󰋽", buffer = 0 },
    { "<leader>lk", "<cmd>VimtexClean<CR>", desc = "kill aux", icon = "󰩺", buffer = 0 },
    { "<leader>lo", latex_sections_picker, desc = "outline (telescope)", icon = "󰊕", buffer = 0 },
    { "<leader>lm", "<plug>(vimtex-context-menu)", desc = "menu", icon = "󰍉", buffer = 0 },
    { "<leader>lv", "<cmd>VimtexView<CR>", desc = "view", icon = "󰛓", buffer = 0 },
    { "<leader>lw", "<cmd>VimtexCountWords!<CR>", desc = "word count", icon = "󰆿", buffer = 0 },
    { "<leader>lx", "<cmd>:VimtexClearCache All<CR>", desc = "clear cache", icon = "󰃢", buffer = 0 },
  })

  -- Template mappings
  wk.add({
    { "<leader>T", group = "templates", icon = "󰈭", buffer = 0 },
    { "<leader>Ta", "<cmd>read ~/.config/nvim/templates/article.tex<CR>", desc = "article.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Tb", "<cmd>read ~/.config/nvim/templates/beamer_slides.tex<CR>", desc = "beamer_slides.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Tg", "<cmd>read ~/.config/nvim/templates/glossary.tex<CR>", desc = "glossary.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Th", "<cmd>read ~/.config/nvim/templates/handout.tex<CR>", desc = "handout.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Tl", "<cmd>read ~/.config/nvim/templates/letter.tex<CR>", desc = "letter.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Tm", "<cmd>read ~/.config/nvim/templates/MultipleAnswer.tex<CR>", desc = "MultipleAnswer.tex", icon = "󰈙", buffer = 0 },
    { "<leader>Tr", function()
      local template_dir = vim.fn.expand("~/.config/nvim/templates/report")
      local current_dir = vim.fn.getcwd()
      vim.fn.system("cp -r " .. vim.fn.shellescape(template_dir) .. " " .. vim.fn.shellescape(current_dir))
      require('neotex.util.notifications').editor('Template copied', require('neotex.util.notifications').categories.USER_ACTION, { template = 'report', directory = current_dir })
    end, desc = "Copy report/ directory", icon = "󰉖", buffer = 0 },
    { "<leader>Ts", function()
      local template_dir = vim.fn.expand("~/.config/nvim/templates/springer")
      local current_dir = vim.fn.getcwd()
      vim.fn.system("cp -r " .. vim.fn.shellescape(template_dir) .. " " .. vim.fn.shellescape(current_dir))
      require('neotex.util.notifications').editor('Template copied', require('neotex.util.notifications').categories.USER_ACTION, { template = 'springer', directory = current_dir })
    end, desc = "Copy springer/ directory", icon = "󰉖", buffer = 0 },
  })
end

-- -- LSP menu to preserve vimtex citation data
-- require('cmp').setup.buffer {
--   formatting = {
--     format = function(entry, vim_item)
--         vim_item.menu = ({
--           omni = (vim.inspect(vim_item.menu):gsub('%"', "")),
--           buffer = "[Buffer]",
--           -- formatting for other sources
--           })[entry.source.name]
--         return vim_item
--       end,
--   },
--   sources = {
--     { name = 'omni' },
--     { name = 'buffer' },
--     -- other sources
--   },
-- }
