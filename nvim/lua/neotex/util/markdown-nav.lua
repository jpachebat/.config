-- Markdown anchor navigation utility
local M = {}

-- Jump to markdown anchor in current file or open markdown file link
-- Handles links like [Text](#anchor-name) and [Text](file.md)
function M.follow_anchor()
  -- Get the current line and cursor position
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  -- First, check if it's a file link [text](file.md) or [text](path/file.md)
  -- Match everything except anchors (no # at start)
  local file_link = line:match("%[.-%]%(([^#)]+)%)")

  if file_link and file_link ~= "" and not file_link:match("^#") then
    -- It's a file link, open it
    -- Handle relative paths
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir = vim.fn.fnamemodify(current_file, ":h")
    local full_path = vim.fn.resolve(current_dir .. "/" .. file_link)

    if vim.fn.filereadable(full_path) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(full_path))
      return
    else
      -- Try without resolving (maybe it's an absolute path)
      if vim.fn.filereadable(file_link) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(file_link))
        return
      else
        vim.notify("File not found: " .. file_link, vim.log.levels.WARN)
        return
      end
    end
  end

  -- Extract anchor from markdown link [text](#anchor)
  local anchor = line:match("%[.-%]%(#([^%)]+)%)")

  if not anchor then
    -- Last resort: try default gf for other types of links
    local ok, err = pcall(function()
      vim.cmd("normal! gf")
    end)
    if not ok then
      vim.notify("No markdown link found", vim.log.levels.WARN)
    end
    return
  end

  -- Convert anchor to heading text
  -- GitHub style: lowercase with hyphens -> Title Case with spaces
  local heading = anchor:gsub("%-", " ")

  -- Save current position in jumplist
  vim.cmd("normal! m'")

  -- Go to top of file
  vim.cmd("normal! gg")

  -- Search for heading (case insensitive)
  local pattern = "\\c^#\\+\\s\\+" .. vim.fn.escape(heading, "\\")
  local search_result = vim.fn.search(pattern, "W")

  if search_result > 0 then
    vim.cmd("normal! zz") -- Center the line
    vim.notify("Jumped to: " .. heading, vim.log.levels.INFO)
  else
    -- Try without spaces (exact anchor match)
    vim.cmd("normal! gg")
    pattern = "\\c^#\\+\\s.*" .. vim.fn.escape(anchor, "\\")
    search_result = vim.fn.search(pattern, "W")

    if search_result > 0 then
      vim.cmd("normal! zz")
      vim.notify("Jumped to section", vim.log.levels.INFO)
    else
      -- Restore position
      vim.cmd("normal! ``")
      vim.notify("Heading not found: " .. heading, vim.log.levels.WARN)
    end
  end
end

-- Setup function to create keymaps for markdown files
function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      vim.keymap.set("n", "gf", M.follow_anchor, {
        buffer = true,
        desc = "Follow markdown anchor"
      })
    end
  })
end

return M
