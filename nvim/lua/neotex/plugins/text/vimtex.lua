return {
  "lervag/vimtex",
  dependencies = {
    "KeitaNakamura/tex-conceal.vim",  -- LaTeX symbol concealment
  },
  init = function()
    -- Viewer settings - Skim for macOS with bidirectional SyncTeX
    vim.g.vimtex_view_method = 'skim'              -- Skim PDF viewer (native macOS)
    vim.g.vimtex_view_skim_sync = 1                -- Enable forward search (Neovim -> PDF)
    vim.g.vimtex_view_skim_activate = 1            -- Activate Skim when viewing
    vim.g.vimtex_view_skim_reading_bar = 1         -- Show reading bar in Skim

    -- Note: Inverse search (PDF -> Neovim) is configured in Skim preferences:
    -- Skim > Preferences > Sync > PDF-TeX Sync Support
    -- Preset: Custom
    -- Command: /opt/homebrew/bin/nvr
    -- Arguments: --servername /tmp/nvim-latex-server.pipe --remote-silent +"%line" "%file"
    --
    -- Note: nvr (neovim-remote) communicates with the running nvim instance.
    -- The server starts automatically when opening .tex files (see autocmds.lua)
    -- using the fixed socket path: /tmp/nvim-latex-server.pipe

    -- Formatting settings
    -- vim.g.vimtex_format_enabled = true             -- Enable formatting with latexindent
    -- vim.g.vimtex_format_program = 'latexindent'

    -- Indentation settings
    vim.g.vimtex_indent_enabled = false            -- Disable auto-indent from Vimtex
    vim.g.tex_indent_items = false                 -- Disable indent for enumerate
    vim.g.tex_indent_brace = false                 -- Disable brace indent

    -- Compiler settings
    vim.g.vimtex_compiler_method = 'latexmk'       -- Explicit compiler backend selection
    vim.g.vimtex_compiler_latexmk = {              -- latexmk configuration
      -- build_dir removed for Skim SyncTeX compatibility
      -- Build directory breaks synctex path resolution with Skim
      options = {
        '-xelatex',                                -- Use XeLaTeX engine
        '-interaction=nonstopmode',                -- Don't stop on errors
        '-file-line-error',                        -- Better error messages
        '-synctex=1',                              -- Enable SyncTeX
      },
    }

    -- Quickfix settings
    vim.g.vimtex_quickfix_mode = 0                 -- Open quickfix window on errors (2 = auto-close when empty)
    vim.g.vimtex_quickfix_ignore_filters = {       -- Filter out common noise
      'Underfull',
      'Overfull',
      'specifier changed to',
      'Token not allowed in a PDF string',
      'Package hyperref Warning',
    }
    vim.g.vimtex_log_ignore = {                    -- Suppress specific log messages
      'Underfull',
      'Overfull',
      'specifier changed to',
      'Token not allowed in a PDF string',
    }

    -- Other settings
    vim.g.vimtex_mappings_enabled = false          -- Disable default mappings
    vim.g.tex_flavor = 'latex'                     -- Set file type for TeX files
  end,
}
