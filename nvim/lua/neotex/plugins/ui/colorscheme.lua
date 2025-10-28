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

        -- High contrast colors for light mode
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
          Normal = { fg = "#43436C", bg = "#F2ECBC" },                  -- Main text - dark on warm beige
          Comment = { fg = "#757575", italic = true },                  -- Comments - medium gray
          Keyword = { fg = "#7E3992", bold = true },                    -- Keywords - purple
          String = { fg = "#2D7B3E" },                                  -- Strings - green
          Function = { fg = "#0F4C81" },                                -- Functions - blue
          Type = { fg = "#A56200" },                                    -- Types - orange
        }
      end,
      theme = "lotus", -- Load "lotus" theme (light mode)
      background = {
        -- map the value of 'background' option to a theme
        dark = "wave", -- try "dragon" !
        light = "lotus"
      },
    })
    vim.opt.background = "light" -- Set background to light
    vim.cmd("colorscheme kanagawa") -- setup must be called before loading
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
