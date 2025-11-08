return {
  "nvim-lualine/lualine.nvim",
  event = "BufReadPost", -- Only load when an actual file is read
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()

    require('lualine').setup({
      options = {
        icons_enabled = false,
        theme = 'gruvbox',
        component_separators = '',
        section_separators = '',
        disabled_filetypes = {
          statusline = {
            "Avante",
            "AvanteInput",
            "AvanteAsk",
            "AvanteEdit"
          },
          winbar = {
            "Avante",
            "AvanteInput",
            "AvanteAsk",
            "AvanteEdit"
          },
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {},
        lualine_c = {
          'filename',
        },
        lualine_x = { 'diagnostics' },
        lualine_y = {},
        lualine_z = { 'progress', 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    })
  end,
}
