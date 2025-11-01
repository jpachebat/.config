-- OpenAI CLI terminal integration (similar to Claude Code)
-- Uses aichat CLI for terminal-based OpenAI interaction
return {
  "akinsho/toggleterm.nvim",
  optional = true, -- Only loads if toggleterm is available
  config = function()
    local Terminal = require('toggleterm.terminal').Terminal

    -- Create OpenAI terminal instance
    local openai_term = Terminal:new({
      cmd = "aichat --role code",  -- Start aichat in code role
      direction = "vertical",
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4  -- 40% width, matching Claude Code
        end
      end,
      close_on_exit = false,
      hidden = true,
      on_open = function(term)
        -- Make buffer unlisted to prevent it from appearing in tabs/bufferline
        vim.bo[term.bufnr].buflisted = false
        vim.bo[term.bufnr].buftype = "terminal"
        vim.bo[term.bufnr].bufhidden = "hide"

        -- Enter insert mode automatically
        vim.cmd("startinsert!")
      end,
      on_close = function()
        -- Optional: cleanup on close
      end,
    })

    -- Toggle function
    function _G.toggle_openai_terminal()
      openai_term:toggle()
    end

    -- Open function
    function _G.open_openai_terminal()
      openai_term:open()
    end

    -- Close function
    function _G.close_openai_terminal()
      openai_term:close()
    end

    -- Create user commands
    vim.api.nvim_create_user_command('OpenAIToggle', function()
      _G.toggle_openai_terminal()
    end, { desc = "Toggle OpenAI terminal" })

    vim.api.nvim_create_user_command('OpenAIOpen', function()
      _G.open_openai_terminal()
    end, { desc = "Open OpenAI terminal" })

    vim.api.nvim_create_user_command('OpenAIClose', function()
      _G.close_openai_terminal()
    end, { desc = "Close OpenAI terminal" })
  end,
}
