-- OSC 52 clipboard plugin for SSH/remote environments
-- Provides reliable copy/paste over SSH connections
--
-- Usage on SSH/cluster:
--   Visual mode: select text, then <leader>c to copy to local clipboard
--   Normal mode: <leader>cc to copy current line
--
-- Usage locally: Normal y/p commands work with system clipboard
return {
  "ojroques/nvim-osc52",
  event = "VeryLazy",
  -- Always load - the plugin will only be useful on SSH anyway
  config = function()
    require('osc52').setup({
      max_length = 0,           -- Maximum length of selection (0 for no limit)
      silent = false,           -- Show message on successful copy
      trim = false,             -- Don't trim whitespaces
      tmux_passthrough = true,  -- Use tmux passthrough if in tmux
    })

    -- Auto-copy on yank to + register
    vim.api.nvim_create_autocmd('TextYankPost', {
      callback = function()
        if vim.v.event.operator == 'y' and vim.v.event.regname == '+' then
          require('osc52').copy_register('+')
        end
      end
    })

    -- Manual copy keybindings (only when SSH'd)
    vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr = true, desc = "Copy to local (OSC52)"})
    vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true, desc = "Copy line to local"})
    vim.keymap.set('v', '<leader>c', require('osc52').copy_visual, {desc = "Copy selection to local"})

    -- Also make y copy to local clipboard
    vim.keymap.set('v', 'y', require('osc52').copy_visual, {desc = "Yank to local clipboard"})
  end,
}
