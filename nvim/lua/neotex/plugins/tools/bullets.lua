return {
  'dkarter/bullets.vim',
  ft = { 'markdown', 'text', 'gitcommit' },
  init = function()
    -- Enable bullets.vim features
    vim.g.bullets_enabled_file_types = { 'markdown', 'text', 'gitcommit' }

    -- Checkbox toggling
    vim.g.bullets_checkbox_markers = ' .oOX'

    -- Outline numbering
    vim.g.bullets_outline_levels = { 'ROM', 'ABC', 'num', 'abc', 'rom', 'std-' }

    -- Don't add bullets in empty lines
    vim.g.bullets_line_spacing = 1

    -- Renumber when inserting/deleting
    vim.g.bullets_renumber_on_change = 1

    -- Custom checkbox states
    vim.g.bullets_checkbox_partials_toggle = 1

    -- Mappings
    vim.g.bullets_set_mappings = 1
  end,
}
