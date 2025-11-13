-----------------------------------------------------
-- Scroll Padding - Add virtual lines at top/bottom of buffers
--
-- This module adds virtual padding lines at the beginning and end
-- of buffers to allow scrolloff=999 to keep the cursor centered
-- even when at the first or last line of a file.
-----------------------------------------------------

local M = {}

-- Namespace for extmarks
local ns_id = vim.api.nvim_create_namespace("scroll_padding")

-- Number of virtual lines to add at top and bottom
local PADDING_LINES = 30

---Add virtual padding lines to a buffer
---@param bufnr number Buffer number
function M.add_padding(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Skip if buffer is not normal or modifiable
  local buftype = vim.bo[bufnr].buftype
  if buftype ~= "" and buftype ~= "acwrite" then
    return
  end

  -- Clear existing padding
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  -- Get total lines in buffer
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  -- Add padding at top (line 0, which is before line 1)
  for i = 1, PADDING_LINES do
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, 0, 0, {
      virt_lines = { { { "", "Normal" } } },
      virt_lines_above = true,
    })
  end

  -- Add padding at bottom (after last line)
  if line_count > 0 then
    for i = 1, PADDING_LINES do
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_count - 1, 0, {
        virt_lines = { { { "", "Normal" } } },
        virt_lines_above = false,
      })
    end
  end
end

---Remove padding from a buffer
---@param bufnr number Buffer number
function M.remove_padding(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

---Setup autocmds to add padding to buffers
function M.setup()
  local group = vim.api.nvim_create_augroup("ScrollPadding", { clear = true })

  -- Add padding when entering a buffer
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = group,
    callback = function(args)
      vim.defer_fn(function()
        M.add_padding(args.buf)
      end, 50)
    end,
  })

  -- Re-add padding after text changes (to adjust bottom padding)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    callback = function(args)
      vim.defer_fn(function()
        M.add_padding(args.buf)
      end, 100)
    end,
  })

  -- Add padding to current buffer immediately
  M.add_padding(vim.api.nvim_get_current_buf())
end

---Toggle padding on/off
function M.toggle()
  if not M.enabled then
    M.setup()
    M.enabled = true
    vim.notify("Scroll padding enabled", vim.log.levels.INFO)
  else
    -- Remove padding from all buffers
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        M.remove_padding(bufnr)
      end
    end
    -- Clear autocmds
    vim.api.nvim_del_augroup_by_name("ScrollPadding")
    M.enabled = false
    vim.notify("Scroll padding disabled", vim.log.levels.INFO)
  end
end

M.enabled = false

return M
