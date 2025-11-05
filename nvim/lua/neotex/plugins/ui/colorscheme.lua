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

-- KANAGAWA
return {
  "rebelot/kanagawa.nvim",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
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

        -- Only apply light mode overrides when in light mode
        local is_light = vim.o.background == "light"

        if not is_light then
          -- Dark mode: fix hard-to-read elements
          return {
            -- Fix black/dark text that's hard to read on dark background
            Identifier = { fg = palette.fujiWhite },        -- Variables - bright white
            Delimiter = { fg = palette.springViolet1 },     -- Brackets/parens - violet
            ["@variable"] = { fg = palette.fujiWhite },     -- Treesitter variables
            ["@punctuation.bracket"] = { fg = palette.springViolet1 },
            ["@punctuation.delimiter"] = { fg = palette.sumiInk4 },

            -- Ensure text is always visible
            Normal = { fg = palette.fujiWhite, bg = theme.ui.bg },
            NormalNC = { fg = palette.fujiWhite, bg = theme.ui.bg_dim },

            -- Comments should be visible but muted
            Comment = { fg = palette.fujiGray, italic = true },

            -- UI elements with better contrast
            LineNr = { fg = palette.fujiGray },  -- Visible gray for line numbers
            CursorLineNr = { fg = palette.roninYellow, bold = true },

            -- Make sure special chars are visible
            SpecialChar = { fg = palette.sakuraPink },
            Special = { fg = palette.springViolet2 },
          }
        end

        -- High contrast colors for light mode only
        return {
          -- LaTeX Commands - dark, saturated colors for visibility
          texStatement = { fg = "#7E3992", bold = true },               -- \begin, \end - dark purple
          texCmd = { fg = "#0F4C81" },                                  -- general commands - deep blue
          texCmdEnv = { fg = "#7E3992", bold = true },                  -- environment commands - dark purple
          texEnvArgName = { fg = "#2D7B3E", italic = true },            -- environment names - forest green
          texMathEnvArgName = { fg = "#8F5902", italic = true },        -- math environment names - brown

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
          texRefZone = { fg = "#2D7B3E", underline = true },            -- \ref, \cite - forest green
          texCite = { fg = "#2D7B3E" },                                 -- citations - forest green

          -- LaTeX Comments
          texComment = { fg = "#757575", italic = true },               -- % comments - gray

          -- LaTeX Special
          texInputFile = { fg = "#C84D99", underline = true },          -- \input, \include - magenta
          texDocType = { fg = "#8F5902", bold = true },                 -- \documentclass - brown
          texDocTypeArgs = { fg = "#8F5902" },                          -- document class args - brown

          -- General syntax improvements for light mode
          Normal = { fg = "#2E2E2E", bg = "#F5F0E8" },                  -- Main text - warm creamy background
          Comment = { fg = "#6B6B6B", italic = true },                  -- Comments - darker gray for visibility
          Keyword = { fg = "#7E2F92", bold = true },                    -- Keywords - deeper purple
          String = { fg = "#1F6B2E" },                                  -- Strings - darker green for readability
          Function = { fg = "#0A3D6B" },                                -- Functions - deeper blue
          Type = { fg = "#8F4700" },                                    -- Types - darker orange

          -- Python-specific syntax highlighting
          pythonBuiltin = { fg = "#5F2A9C", italic = true },            -- Built-in functions - purple
          pythonFunction = { fg = "#0A3D6B", bold = true },             -- Function definitions - blue
          pythonDecorator = { fg = "#A53500" },                         -- Decorators - orange-red
          pythonDecoratorName = { fg = "#A53500" },                     -- Decorator names - orange-red
          pythonException = { fg = "#B82020", bold = true },            -- Exceptions - red
          pythonOperator = { fg = "#7E2F92" },                          -- Operators - purple
          pythonRepeat = { fg = "#7E2F92", bold = true },               -- for, while - purple
          pythonConditional = { fg = "#7E2F92", bold = true },          -- if, else - purple
          pythonInclude = { fg = "#B82020" },                           -- import, from - red
          pythonStatement = { fg = "#7E2F92", bold = true },            -- return, pass, etc. - purple
          pythonAsync = { fg = "#A53500", italic = true },              -- async/await - orange
          pythonClass = { fg = "#8F4700", bold = true },                -- Class keyword - orange
          pythonDefine = { fg = "#0A3D6B", bold = true },               -- def keyword - blue
          pythonDottedName = { fg = "#2E2E2E" },                        -- Module names - dark
          pythonBuiltinObj = { fg = "#5F2A9C", italic = true },         -- Built-in objects - purple
          pythonBuiltinFunc = { fg = "#5F2A9C", italic = true },        -- Built-in functions - purple
          pythonStrFormat = { fg = "#1F6B2E", bold = true },            -- String formatting - green
          pythonNumber = { fg = "#A53500" },                            -- Numbers - orange-red

          -- Treesitter Python groups (for better compatibility)
          ["@keyword.python"] = { fg = "#7E2F92", bold = true },
          ["@keyword.function.python"] = { fg = "#0A3D6B", bold = true },
          ["@keyword.return.python"] = { fg = "#7E2F92", bold = true },
          ["@keyword.operator.python"] = { fg = "#7E2F92" },
          ["@function.builtin.python"] = { fg = "#5F2A9C", italic = true },
          ["@function.call.python"] = { fg = "#0A3D6B" },
          ["@variable.builtin.python"] = { fg = "#5F2A9C", italic = true },
          ["@exception.python"] = { fg = "#B82020", bold = true },
          ["@decorator.python"] = { fg = "#A53500" },
          ["@type.python"] = { fg = "#8F4700" },
          ["@type.builtin.python"] = { fg = "#8F4700", italic = true },
          ["@constant.builtin.python"] = { fg = "#A53500", bold = true },
          ["@string.documentation.python"] = { fg = "#1F6B2E", italic = true },

          -- Code blocks and markdown code
          RenderMarkdownCode = { bg = "#EDE8DC" },                      -- Code block background - slightly darker cream
          RenderMarkdownCodeInline = { fg = "#A53500", bg = "#EDE8DC" },-- Inline code - orange on darker cream

          -- Better contrast for various elements
          Constant = { fg = "#A53500" },                                -- Constants - orange-red
          Number = { fg = "#A53500" },                                  -- Numbers - orange-red
          Boolean = { fg = "#A53500", bold = true },                    -- Booleans - orange-red
          Character = { fg = "#1F6B2E" },                               -- Characters - green
          Identifier = { fg = "#2E2E2E" },                              -- Identifiers - dark
          Statement = { fg = "#7E2F92", bold = true },                  -- Statements - purple
          Conditional = { fg = "#7E2F92", bold = true },                -- if/else - purple
          Repeat = { fg = "#7E2F92", bold = true },                     -- loops - purple
          Label = { fg = "#8F4700" },                                   -- Labels - orange
          Operator = { fg = "#7E2F92" },                                -- Operators - purple
          Exception = { fg = "#B82020", bold = true },                  -- Exceptions - red
          PreProc = { fg = "#A53500" },                                 -- Preprocessor - orange-red
          Include = { fg = "#B82020" },                                 -- Includes - red
          Define = { fg = "#A53500" },                                  -- Defines - orange-red
          Macro = { fg = "#A53500" },                                   -- Macros - orange-red
          Special = { fg = "#A53500" },                                 -- Special - orange-red
          SpecialChar = { fg = "#B82020" },                             -- Special chars - red
          Delimiter = { fg = "#2E2E2E" },                               -- Delimiters - dark
          SpecialComment = { fg = "#6B6B6B", bold = true },             -- Special comments - gray
          Debug = { fg = "#B82020" },                                   -- Debug - red
        }
      end,
      theme = "wave", -- Load "wave" theme (will switch based on background option)
      background = {
        -- map the value of 'background' option to a theme
        dark = "wave", -- try "dragon" !
        light = "lotus"
      },
    })

    -- Auto-detect theme based on time of day
    local function set_theme_by_time()
      local hour = tonumber(os.date("%H"))

      -- Light mode: 7 AM to 7 PM (7-19)
      -- Dark mode: 7 PM to 7 AM (19-7)
      if hour >= 7 and hour < 19 then
        vim.opt.background = "light"
      else
        vim.opt.background = "dark"
      end
    end

    -- Set initial theme based on current time
    set_theme_by_time()

    vim.cmd("colorscheme kanagawa") -- setup must be called before loading

    -- Ensure time-based theme is applied after everything loads
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        set_theme_by_time()
      end,
      once = true,
    })
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
