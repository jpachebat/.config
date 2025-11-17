-- GRUVBOX (disabled)
-- return {
--   "ellisonleao/gruvbox.nvim",
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     require("gruvbox").setup({
--       overrides = {
--         SignColumn = { bg = "#282828" },
--         NvimTreeCutHL = { fg = "#fb4934", bg = "#282828" },
--         NvimTreeCopiedHL = { fg = "#b8bb26", bg = "#282828" },
--         DiagnosticSignError = { fg = "#fb4934", bg = "#282828" },
--         DiagnosticSignWarn = { fg = "#fabd2f", bg = "#282828" },
--         DiagnosticSignHint = { fg = "#8ec07c", bg = "#282828" },
--         DiagnosticSignInfo = { fg = "#d3869b", bg = "#282828" },
--         DiffText = { fg = "#ebdbb2", bg = "#3c3836" },
--         DiffAdd = { fg = "#ebdbb2", bg = "#32361a" },
--         -- Markdown comment highlighting (muted)
--         htmlComment = { fg = "#928374", italic = true },
--         htmlCommentPart = { fg = "#928374", italic = true },
--         markdownHtmlComment = { fg = "#928374", italic = true },
--         RenderMarkdownHtmlComment = { fg = "#928374", italic = true },
--       }
--     })
--     vim.cmd("colorscheme gruvbox")
--   end,
-- }

-- -- MONOKAI
-- return {
--   "tanvirtin/monokai.nvim",  -- Monokai theme
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     require("monokai").setup {
--       -- palette = require("monokai").pro,  -- Use Monokai Pro palette
--     }
--   vim.cmd("colorscheme monokai")
--   end
-- }

-- SIMPLE VIM-LIKE COLORSCHEME
return {
  "rebelot/kanagawa.nvim",
  priority = 1000,
  config = function()
    -- Use default vim colors for light mode, kanagawa for dark
    if vim.o.background == "light" then
      vim.cmd("colorscheme shine")  -- Built-in vim-like light theme
    else
      require('kanagawa').setup({
      compile = false,  -- enable compiling the colorscheme
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,   -- do not set background color
      dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
      colors = {
        -- add/modify theme and palette colors
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
      },
      overrides = function(colors) -- add/modify highlights
        local theme = colors.theme
        local palette = colors.palette

        -- Detect if this is lotus (light) theme by checking palette colors
        -- Kanagawa lotus has a bright background, wave/dragon are dark
        local is_light = colors.theme.ui.bg == "#f2ecbc" or colors.theme.ui.bg:match("^#[def]")

        if not is_light then
          -- Dark mode: fix hard-to-read elements
          local deep_bg = "#050505"
          local deep_bg_dim = "#080808"
          local deep_bg_highlight = "#0e0e0e"
          local deep_bg_float = "#0c0c0c"

          return {
            -- Core surfaces darkened for near-black UI
            Normal = { fg = palette.fujiWhite, bg = deep_bg },
            NormalNC = { fg = palette.fujiWhite, bg = deep_bg_dim },
            NormalSB = { fg = palette.fujiWhite, bg = deep_bg_dim },
            NormalFloat = { fg = palette.fujiWhite, bg = deep_bg_float },
            FloatBorder = { fg = palette.sumiInk4, bg = deep_bg_float },
            SignColumn = { bg = deep_bg_dim },
            LineNr = { fg = palette.fujiGray, bg = deep_bg_dim },  -- Visible gray for line numbers
            CursorLine = { bg = deep_bg_highlight },
            CursorLineNr = { fg = palette.roninYellow, bg = deep_bg_highlight, bold = true },
            StatusLine = { fg = palette.springBlue, bg = deep_bg_highlight },
            StatusLineNC = { fg = palette.fujiGray, bg = deep_bg_dim },
            Visual = { bg = "#1a1a1a" },

            -- Floating UIs keep the near-black tone
            Pmenu = { fg = palette.fujiWhite, bg = deep_bg_float },
            PmenuSel = { fg = palette.sakuraPink, bg = deep_bg_highlight, bold = true },
            PmenuSbar = { bg = deep_bg_highlight },
            PmenuThumb = { bg = palette.waveBlue1 },
            WinSeparator = { fg = "#121212", bg = deep_bg_dim },

            -- Telescope surfaces inherit the deep background to avoid washed-out panels
            TelescopeNormal = { fg = palette.fujiWhite, bg = deep_bg_float },
            TelescopeBorder = { fg = palette.sumiInk4, bg = deep_bg_float },
            TelescopeResultsNormal = { fg = palette.fujiWhite, bg = deep_bg_dim },
            TelescopeResultsBorder = { fg = palette.sumiInk4, bg = deep_bg_dim },
            TelescopePreviewNormal = { fg = palette.fujiWhite, bg = deep_bg_dim },
            TelescopePreviewBorder = { fg = palette.sumiInk4, bg = deep_bg_dim },
            TelescopePromptNormal = { fg = palette.fujiWhite, bg = deep_bg_highlight },
            TelescopePromptBorder = { fg = palette.sumiInk4, bg = deep_bg_highlight },

            -- Fix black/dark text that's hard to read on dark background
            Identifier = { fg = palette.fujiWhite },        -- Variables - bright white
            Delimiter = { fg = palette.springViolet1 },     -- Brackets/parens - violet
            ["@variable"] = { fg = palette.fujiWhite },     -- Treesitter variables
            ["@punctuation.bracket"] = { fg = palette.springViolet1 },
            ["@punctuation.delimiter"] = { fg = palette.springViolet1 }, -- Visible commas/dots
            ["@punctuation.special"] = { fg = palette.springViolet2 },

            -- Comments should be visible but muted
            Comment = { fg = palette.fujiGray, italic = true },

            -- Make sure special chars are visible
            SpecialChar = { fg = palette.sakuraPink },
            Special = { fg = palette.springViolet2 },
            Operator = { fg = palette.boatYellow2 },

            -- Render-markdown checkboxes pop with clear colors
            RenderMarkdownUnchecked = { fg = palette.samuraiRed, bold = true },
            RenderMarkdownChecked = { fg = palette.autumnGreen, bold = true },
            RenderMarkdownTodo = { fg = palette.roninYellow, bold = true },

            -- Python readability in dark mode
            pythonBuiltin = { fg = palette.springBlue, italic = true },
            pythonFunction = { fg = palette.crystalBlue },
            pythonDecorator = { fg = palette.peachRed },
            pythonDecoratorName = { fg = palette.peachRed },
            pythonOperator = { fg = palette.boatYellow2 },
            pythonRepeat = { fg = palette.oniViolet, bold = true },
            pythonConditional = { fg = palette.oniViolet, bold = true },
            pythonInclude = { fg = palette.autumnRed },
            pythonStatement = { fg = palette.oniViolet, bold = true },
            pythonNumber = { fg = palette.surimiOrange },

            ["@keyword.python"] = { fg = palette.oniViolet, bold = true },
            ["@keyword.function.python"] = { fg = palette.crystalBlue },
            ["@function.python"] = { fg = palette.crystalBlue },
            ["@function.call.python"] = { fg = palette.crystalBlue },
            ["@function.builtin.python"] = { fg = palette.springBlue, italic = true },
            ["@variable.builtin.python"] = { fg = palette.springBlue, italic = true },
            ["@exception.python"] = { fg = palette.autumnRed, bold = true },
            ["@constant.builtin.python"] = { fg = palette.surimiOrange },
            ["@number.python"] = { fg = palette.surimiOrange },
          }
        end

        -- Professional light mode colors - neutral blues and grays
        return {
          -- Cursor line - subtle gray highlight (not green!)
          CursorLine = { bg = "#F9FAFB" },                              -- Very light gray - subtle
          CursorLineNr = { fg = "#1F2937", bg = "#F9FAFB", bold = true }, -- Dark gray number

          -- LaTeX Commands - professional blues and burgundy
          texStatement = { fg = "#7C3AED", bold = true },               -- \begin, \end - purple
          texCmd = { fg = "#1E40AF" },                                  -- general commands - navy blue
          texCmdEnv = { fg = "#7C3AED", bold = true },                  -- environment commands - purple
          texEnvArgName = { fg = "#0F3460", italic = true },            -- environment names - dark blue
          texMathEnvArgName = { fg = "#92400E", italic = true },        -- math environment names - brown

          -- LaTeX Sections and Structure
          texSection = { fg = "#C13030", bold = true },                 -- \section - bright red
          texSectionMarker = { fg = "#C13030" },                        -- section markers - bright red
          texSectionName = { fg = "#C13030", bold = true },             -- section names - bright red
          texTitle = { fg = "#BA2F2F", bold = true },                   -- \title, \author - crimson

          -- LaTeX Math
          texMath = { fg = "#5A3D99" },                                 -- math mode content - purple
          texMathZone = { fg = "#5A3D99" },                             -- math zones - purple
          texMathDelim = { fg = "#A56200", bold = true },               -- $ $ delimiters - dark orange
          texMathSymbol = { fg = "#7E3992" },                           -- math symbols - dark purple
          texMathCmd = { fg = "#0F4C81" },                              -- math commands - deep blue

          -- LaTeX Delimiters and Brackets
          texDelimiter = { fg = "#8F5902" },                            -- {}, [] - brown
          texSpecialChar = { fg = "#D14D41" },                          -- special characters - coral red

          -- LaTeX Style Commands
          texTypeStyle = { fg = "#1A7C8A", italic = true },             -- \textbf, \textit - teal
          texTypeSize = { fg = "#1A7C8A" },                             -- \large, \small - teal

          -- LaTeX References and Citations
          texRefZone = { fg = "#1E40AF", underline = true },            -- \ref, \cite - navy blue
          texCite = { fg = "#1E40AF" },                                 -- citations - navy blue

          -- LaTeX Comments
          texComment = { fg = "#71717A", italic = true },               -- % comments - neutral gray

          -- LaTeX Special
          texInputFile = { fg = "#BE185D", underline = true },          -- \input, \include - pink
          texDocType = { fg = "#92400E", bold = true },                 -- \documentclass - brown
          texDocTypeArgs = { fg = "#92400E" },                          -- document class args - brown

          -- General syntax improvements for light mode - professional palette
          Normal = { fg = "#1F2937", bg = "#FFFFFF" },                  -- Dark gray on pure white
          Comment = { fg = "#6B7280", italic = true },                  -- Medium gray
          Keyword = { fg = "#7C3AED", bold = true },                    -- Purple
          String = { fg = "#0F3460" },                                  -- Dark blue - professional, not green
          Function = { fg = "#1E40AF" },                                -- Navy blue
          Type = { fg = "#D97706" },                                    -- Amber

          -- Python-specific syntax highlighting - professional colors
          pythonBuiltin = { fg = "#7C3AED", italic = true },            -- Built-in functions - purple
          pythonFunction = { fg = "#1E40AF", bold = true },             -- Function definitions - navy
          pythonDecorator = { fg = "#D97706" },                         -- Decorators - amber
          pythonDecoratorName = { fg = "#D97706" },                     -- Decorator names - amber
          pythonException = { fg = "#DC2626", bold = true },            -- Exceptions - red
          pythonOperator = { fg = "#7C3AED" },                          -- Operators - purple
          pythonRepeat = { fg = "#7C3AED", bold = true },               -- for, while - purple
          pythonConditional = { fg = "#7C3AED", bold = true },          -- if, else - purple
          pythonInclude = { fg = "#DC2626" },                           -- import, from - red
          pythonStatement = { fg = "#7C3AED", bold = true },            -- return, pass, etc. - purple
          pythonAsync = { fg = "#D97706", italic = true },              -- async/await - amber
          pythonClass = { fg = "#D97706", bold = true },                -- Class keyword - amber
          pythonDefine = { fg = "#1E40AF", bold = true },               -- def keyword - navy
          pythonDottedName = { fg = "#1F2937" },                        -- Module names - dark gray
          pythonBuiltinObj = { fg = "#7C3AED", italic = true },         -- Built-in objects - purple
          pythonBuiltinFunc = { fg = "#7C3AED", italic = true },        -- Built-in functions - purple
          pythonStrFormat = { fg = "#0F3460", bold = true },            -- String formatting - dark blue
          pythonNumber = { fg = "#D97706" },                            -- Numbers - amber

          -- Treesitter Python groups - professional colors
          ["@keyword.python"] = { fg = "#7C3AED", bold = true },
          ["@keyword.function.python"] = { fg = "#1E40AF", bold = true },
          ["@keyword.return.python"] = { fg = "#7C3AED", bold = true },
          ["@keyword.operator.python"] = { fg = "#7C3AED" },
          ["@function.builtin.python"] = { fg = "#7C3AED", italic = true },
          ["@function.call.python"] = { fg = "#1E40AF" },
          ["@variable.builtin.python"] = { fg = "#7C3AED", italic = true },
          ["@exception.python"] = { fg = "#DC2626", bold = true },
          ["@decorator.python"] = { fg = "#D97706" },
          ["@type.python"] = { fg = "#D97706" },
          ["@type.builtin.python"] = { fg = "#D97706", italic = true },
          ["@constant.builtin.python"] = { fg = "#D97706", bold = true },
          ["@string.documentation.python"] = { fg = "#0F3460", italic = true },

          -- Code blocks and markdown code - professional clean
          RenderMarkdownCode = { bg = "#F3F4F6" },                      -- Code block background - light gray
          RenderMarkdownCodeInline = { fg = "#D97706", bg = "#F3F4F6" },-- Inline code - amber on gray

          -- Render-markdown checkbox icons - professional colors
          RenderMarkdownUnchecked = { fg = "#DC2626", bold = true },    -- Red unchecked
          RenderMarkdownChecked = { fg = "#059669", bold = true },      -- Teal checked (only green usage - for positive indicator)
          RenderMarkdownTodo = { fg = "#D97706", bold = true },         -- Amber partial

          -- Better contrast for various elements - professional palette
          Constant = { fg = "#D97706" },                                -- Constants - amber
          Number = { fg = "#D97706" },                                  -- Numbers - amber
          Boolean = { fg = "#D97706", bold = true },                    -- Booleans - amber
          Character = { fg = "#0F3460" },                               -- Characters - dark blue
          Identifier = { fg = "#1F2937" },                              -- Identifiers - dark gray
          Statement = { fg = "#7C3AED", bold = true },                  -- Statements - purple
          Conditional = { fg = "#7C3AED", bold = true },                -- if/else - purple
          Repeat = { fg = "#7C3AED", bold = true },                     -- loops - purple
          Label = { fg = "#D97706" },                                   -- Labels - amber
          Operator = { fg = "#7C3AED" },                                -- Operators - purple
          Exception = { fg = "#DC2626", bold = true },                  -- Exceptions - red
          PreProc = { fg = "#D97706" },                                 -- Preprocessor - amber
          Include = { fg = "#DC2626" },                                 -- Includes - red
          Define = { fg = "#D97706" },                                  -- Defines - amber
          Macro = { fg = "#D97706" },                                   -- Macros - amber
          Special = { fg = "#D97706" },                                 -- Special - amber
          SpecialChar = { fg = "#DC2626" },                             -- Special chars - red
          Delimiter = { fg = "#1F2937" },                               -- Delimiters - dark gray
          SpecialComment = { fg = "#6B7280", bold = true },             -- Special comments - gray
          Debug = { fg = "#DC2626" },                                   -- Debug - red
        }
      end,
      theme = "wave",
      background = {
        dark = "wave",
        light = "lotus"
      },
    })
      vim.cmd("colorscheme kanagawa")
    end
    require("neotex.util.theme").setup()
  end,
}



-- -- NIGHTFLY
-- return {
--   "bluz71/vim-nightfly-guicolors",
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     -- load the colorscheme here
--     vim.cmd("colorscheme nightfly")
--   end,
-- }


-- OTHER
-- "luisiacc/gruvbox-baby"
-- "folke/tokyonight.nvim"
-- "lunarvim/darkplus.nvim"
-- "navarasu/onedark.nvim"
-- "savq/melange"
-- "EdenEast/nightfox.nvim"
