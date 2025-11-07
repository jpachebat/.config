# Neovim Cluster Configuration

This is a simplified Neovim configuration designed for cluster systems with older system libraries but modern Neovim (0.10+).

## Features Included

### Core Features (Kept)
- ✅ **LSP** - Language Server Protocol for code intelligence
- ✅ **Treesitter** - Advanced syntax highlighting
- ✅ **Telescope** - Fuzzy finder for files and grep
- ✅ **Git integration** - Gitsigns for git status and commands
- ✅ **Completion** - nvim-cmp with LSP integration
- ✅ **Essential editing tools** - autopairs, surround, comment, which-key
- ✅ **File explorer** - nvim-tree for file navigation

### Features Removed (for Performance & Compatibility)
- ❌ AI integrations (Avante, ChatGPT, Claude, Lectic, MCP-Hub)
- ❌ Email client (Himalaya)
- ❌ LaTeX support (VimTeX)
- ❌ Markdown preview & Obsidian integration
- ❌ Jupyter notebook support
- ❌ Heavy UI plugins (custom statusline, bufferline)
- ❌ Session management
- ❌ Complex workflows and specifications

## Installation on Cluster

### Option 1: Use NVIM_APPNAME (Recommended)

This allows you to keep both configs side by side:

```bash
# On your cluster, create a separate config directory
export NVIM_APPNAME=nvim-cluster
mkdir -p ~/.config/nvim-cluster

# Copy the cluster config
scp -r ~/.config/nvim/init.cluster.lua cluster:~/.config/nvim-cluster/init.lua

# Or clone just this branch
git clone -b cluster-simple-config --single-branch \
  <your-repo-url> ~/.config/nvim-cluster

# In your cluster .bashrc or .bash_profile:
export NVIM_APPNAME=nvim-cluster
alias nvim="NVIM_APPNAME=nvim-cluster nvim"
```

### Option 2: Replace Main Config

If you only want the cluster config:

```bash
# Backup your current config
cd ~/.config/nvim
git checkout master  # or your main branch

# Switch to cluster config
git checkout cluster-simple-config

# Symlink the cluster config
ln -sf ~/.config/nvim/init.cluster.lua ~/.config/nvim/init.lua
```

### Option 3: Direct Copy

Simply copy the cluster config:

```bash
# On cluster
cp ~/.config/nvim/init.cluster.lua ~/.config/nvim/init.lua
```

## First Time Setup

1. **Launch Neovim**: The first time you open Neovim, lazy.nvim will be installed automatically.

```bash
nvim
```

2. **Wait for plugin installation**: Lazy will automatically install all plugins. This may take a few minutes.

3. **If you have internet issues**: You can disable Mason's automatic installation:
   - Open `init.cluster.lua`
   - Set `automatic_installation = false` (already done)
   - Manually install LSP servers if needed

## Manual LSP Installation (No Internet)

If your cluster has no internet access, you can install LSP servers manually on a machine with internet, then copy them:

```bash
# On a machine with internet:
nvim
:MasonInstall lua_ls pyright rust_analyzer

# Find the Mason installation directory
:echo stdpath("data") . "/mason"

# Copy the entire mason directory to your cluster
scp -r ~/.local/share/nvim/mason cluster:~/.local/share/nvim/
```

## Performance Considerations

This config is optimized for performance:

1. **Lazy loading**: Most plugins load only when needed
2. **Disabled features**: Removed matchit, matchparen, and other default plugins
3. **No heavy UI**: Minimal statusline and simpler UI components
4. **Reduced plugin count**: ~15 plugins vs 50+ in the full config

## Key Mappings

### Leader Key
- Leader: `<Space>`

### File Operations
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - List buffers
- `<leader>fr` - Recent files
- `<leader>e` - Toggle file explorer
- `<leader>w` - Save file
- `<leader>q` - Quit

### LSP
- `gd` - Go to definition
- `K` - Hover documentation
- `gi` - Go to implementation
- `gr` - Find references
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code action
- `<leader>d` - Show diagnostics
- `[d` - Previous diagnostic
- `]d` - Next diagnostic

### Git
- `]c` - Next hunk
- `[c` - Previous hunk
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame line

### Buffer Navigation
- `Shift+h` - Previous buffer
- `Shift+l` - Next buffer

### Window Navigation
- `Ctrl+h/j/k/l` - Navigate between windows

## Troubleshooting

### Issue: Plugins won't install
**Solution**: Check if you have git and network access. If not, you may need to manually copy plugins from another machine.

### Issue: Treesitter compilation fails
**Solution**: You may need to install a C compiler. If that's not possible:
```lua
-- In init.cluster.lua, change:
highlight = { enable = false }
```

### Issue: LSP servers fail to install
**Solution**: Use manual installation method above, or install servers system-wide if available.

### Issue: Old glibc errors
**Solution**: This config avoids most binary dependencies. If you still see errors, you may need to:
1. Compile plugins on the cluster directly
2. Use older versions of problematic plugins
3. Disable the problematic plugin

## Customization

To customize the config for your needs, edit `init.cluster.lua`:

- **Add more LSP servers**: See the `lspconfig` section
- **Change colorscheme**: Replace `gruvbox` with another scheme
- **Add more Treesitter parsers**: Update `ensure_installed` list
- **Adjust keymaps**: Edit the keymaps section at the bottom

## Comparing with Full Config

| Feature | Full Config | Cluster Config |
|---------|-------------|----------------|
| Total files | 280+ Lua files | 1 file |
| Plugin count | 50+ plugins | ~15 plugins |
| LSP | ✅ | ✅ |
| Treesitter | ✅ | ✅ |
| Telescope | ✅ | ✅ |
| Git | ✅ | ✅ |
| AI tools | ✅ | ❌ |
| LaTeX | ✅ | ❌ |
| Email | ✅ | ❌ |
| Jupyter | ✅ | ❌ |
| Complex UI | ✅ | ❌ |

## Getting Back to Full Config

To switch back to your full configuration:

```bash
# If using NVIM_APPNAME
unset NVIM_APPNAME
# or just run:
nvim  # with NVIM_APPNAME=""

# If you switched branches
git checkout master
rm init.lua  # if it's a symlink
```

## Support

If you encounter issues, check:
1. Neovim version: `:version` (should be 0.10+)
2. Plugin status: `:Lazy`
3. LSP status: `:LspInfo`
4. Health check: `:checkhealth`
