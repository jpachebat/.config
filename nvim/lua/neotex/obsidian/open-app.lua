local M = {}

-- URL encode a string
local function url_encode(str)
  str = string.gsub(str, "([^%w%.%- ])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  str = string.gsub(str, " ", "%%20")
  return str
end

-- Open current note in Obsidian app
function M.open_in_obsidian()
  local current_file = vim.fn.expand("%:p")
  local vault_path = vim.fn.expand("~/work/notes")

  -- Check if we're in the vault
  if not current_file:match("^" .. vim.pesc(vault_path)) then
    vim.notify("Not in Obsidian vault: " .. current_file, vim.log.levels.WARN)
    return
  end

  -- Get relative path from vault root
  local relative_path = current_file:gsub("^" .. vim.pesc(vault_path) .. "/", "")

  -- Remove .md extension for Obsidian URI
  local note_path = relative_path:gsub("%.md$", "")

  -- Construct Obsidian URI
  -- Format: obsidian://open?vault=VaultName&file=path/to/note
  local vault_name = "work" -- Your vault name from obsidian.lua config
  local encoded_vault = url_encode(vault_name)
  local encoded_path = url_encode(note_path)

  local uri = string.format("obsidian://open?vault=%s&file=%s", encoded_vault, encoded_path)

  -- Open with macOS open command
  local cmd = string.format("open '%s'", uri)
  local result = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to open Obsidian: " .. result, vim.log.levels.ERROR)
  else
    vim.notify("Opening in Obsidian: " .. note_path, vim.log.levels.INFO)
  end
end

-- Register command
vim.api.nvim_create_user_command("ObsidianOpenApp", function()
  M.open_in_obsidian()
end, { desc = "Open current note in Obsidian app" })

return M
