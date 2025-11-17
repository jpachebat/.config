-- Scroll Padding - Virtual lines at top/bottom for scrolloff

local M = {}
local ns_id = vim.api.nvim_create_namespace("scroll_padding")
local PADDING_LINES = 7  -- Virtual lines at top and bottom

function M.add_padding(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local ok, buftype = pcall(vim.api.nvim_buf_get_option, bufnr, "buftype")
  if not ok or (buftype ~= "" and buftype ~= "acwrite") then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  local line_count = vim.api.nvim_buf_line_count(bufnr)

  -- Top padding - single extmark with multiple virtual lines
  local top_virt_lines = {}
  for _ = 1, PADDING_LINES do
    table.insert(top_virt_lines, { { "", "Normal" } })
  end
  vim.api.nvim_buf_set_extmark(bufnr, ns_id, 0, 0, {
    virt_lines = top_virt_lines,
    virt_lines_above = true,
  })

  -- Bottom padding - single extmark with multiple virtual lines
  if line_count > 0 then
    local bottom_virt_lines = {}
    for _ = 1, PADDING_LINES do
      table.insert(bottom_virt_lines, { { "", "Normal" } })
    end
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_count - 1, 0, {
      virt_lines = bottom_virt_lines,
      virt_lines_above = false,
    })
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ScrollPadding", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinScrolled", "VimResized" }, {
    group = group,
    callback = function(args)
      local bufnr = args.buf or vim.api.nvim_get_current_buf()
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      pcall(M.add_padding, bufnr)
    end,
  })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    callback = function(args)
      local bufnr = args.buf or vim.api.nvim_get_current_buf()
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      pcall(M.add_padding, bufnr)
    end,
  })

  -- Initial padding
  vim.schedule(function()
    pcall(M.add_padding, vim.api.nvim_get_current_buf())
  end)
end

return M
