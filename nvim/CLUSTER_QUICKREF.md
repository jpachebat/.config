# Neovim Cluster Config - Quick Reference

## Quick Start

```bash
# Complete setup in 6 commands
git clone https://github.com/jpachebat/.config.git ~/.config
cd ~/.config
git checkout cluster-simple-config
git branch --set-upstream-to=origin/cluster-simple-config cluster-simple-config
cd nvim && ln -s init.cluster.lua init.lua
nvim  # Auto-installs everything on first launch
```

## Essential Keybindings

### Leader Key: `<Space>`

### File Operations
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Search in files (grep) |
| `<leader>fb` | List open buffers |
| `<leader>fr` | Recent files |
| `<leader>e` | File explorer |
| `<leader>w` | Save file |
| `<leader>q` | Quit |

### LSP (Code Intelligence)
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Show documentation |
| `gi` | Go to implementation |
| `gr` | Find references |
| `<leader>rn` | Rename |
| `<leader>ca` | Code actions |
| `<leader>d` | Show diagnostic |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

### Git
| Key | Action |
|-----|--------|
| `]c` | Next change |
| `[c` | Previous change |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |

### Navigation
| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Window navigation |
| `Shift+h` | Previous buffer |
| `Shift+l` | Next buffer |
| `Ctrl+o` | Jump back |
| `Ctrl+i` | Jump forward |

## Quick Commands

```vim
" Plugin management
:Lazy                 " Plugin manager UI
:Lazy update         " Update all plugins
:Lazy clean          " Remove unused plugins

" LSP
:LspInfo             " Show LSP status
:LspRestart          " Restart LSP servers
:Mason               " LSP server manager

" Health check
:checkhealth         " Check Neovim setup

" File explorer
:NvimTreeToggle      " Toggle file tree
:NvimTreeFocus       " Focus file tree

" Telescope
:Telescope           " Show all pickers
:Telescope find_files
:Telescope live_grep
:Telescope buffers
:Telescope help_tags
```

## Troubleshooting

### Connection dropped during install
**Don't worry!** Just relaunch nvim - lazy.nvim will resume where it left off:
```bash
nvim  # Continues installation
# Or force sync: :Lazy sync
```

### Git 1.8 compatibility errors
If you see "error: unknown option `filter=blob:none`":
- Ensure you're on `cluster-simple-config` branch
- This fix is already in `init.cluster.lua` lines 356-359

### Plugins won't install
```bash
# Check network
ping github.com

# Verify git version (need 1.8+)
git --version

# Manual lazy.nvim install
cd ~/.local/share/nvim/lazy
git clone https://github.com/folke/lazy.nvim.git
```

### LSP not working
```vim
:LspInfo              " Check if LSP is attached
:Mason                " Check if servers are installed
:checkhealth lsp      " Check LSP health
```

### Treesitter issues
```vim
:TSInstall python     " Install specific parser
:TSUpdate             " Update parsers
:checkhealth nvim-treesitter
```

### Performance issues
```lua
-- Disable treesitter for large files
-- Add to init.cluster.lua:
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
    if ok and stats and stats.size > 500000 then -- 500KB
      vim.b.large_file = true
      vim.cmd("TSBufDisable highlight")
    end
  end,
})
```

## Installation for Air-Gapped Systems

If your cluster has no internet:

```bash
# On machine with internet:
# 1. Install plugins
nvim --headless "+Lazy! sync" +qa

# 2. Package everything
cd ~/.local/share/nvim
tar czf nvim-plugins.tar.gz lazy/

cd ~/.config/nvim-cluster
tar czf nvim-config.tar.gz .

# 3. Transfer to cluster
scp nvim-*.tar.gz cluster:~/

# On cluster:
# 4. Extract
mkdir -p ~/.local/share/nvim
cd ~/.local/share/nvim
tar xzf ~/nvim-plugins.tar.gz

mkdir -p ~/.config/nvim-cluster
cd ~/.config/nvim-cluster
tar xzf ~/nvim-config.tar.gz
```

## Minimal Configuration (Emergency Fallback)

If even this config is too heavy, create `~/.config/nvim/init.lua`:

```lua
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- No plugins, just Neovim defaults
```

## Getting Help

```vim
:help                 " General help
:help key-notation    " Keyboard notation
:help lsp             " LSP help
:help telescope       " Telescope help
```

## Switching Back to Full Config

```bash
# If using NVIM_APPNAME
unset NVIM_APPNAME
nvim  # Uses default config

# If using symlink/replace
cd ~/.config/nvim
git checkout master
# Restore backup if needed
mv init.lua.backup.* init.lua
```
