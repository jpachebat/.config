# Unified Shell & Editor Configuration

Centralized configuration management for local machine and remote clusters.

## Architecture

```
~/.config/
├── shell/
│   ├── common.sh          # Shared aliases/functions (both local & cluster)
│   ├── local.sh           # Local machine specific (macOS, homebrew, etc.)
│   └── sshfs-mounts.sh    # SSHFS cluster mount helpers
├── bash/
│   └── bashrc.cluster     # Cluster-specific bashrc
├── vim/
│   └── vimrc              # Shared vim configuration
└── nvim/                  # Full neovim config (local only)
```

## Setup Instructions

### Local Machine (macOS)

1. **Source the local configuration** in `~/.bash_profile`:
   ```bash
   # Add to ~/.bash_profile
   if [ -f ~/.config/shell/local.sh ]; then
     source ~/.config/shell/local.sh
   fi
   ```

2. **Symlink vim config**:
   ```bash
   ln -sf ~/.config/vim/vimrc ~/.vimrc
   ```

3. **Reload**:
   ```bash
   source ~/.bash_profile
   ```

### Remote Cluster

1. **Clone/pull config**:
   ```bash
   cd ~
   git clone https://gitlab.labos.polytechnique.fr/jean.pachebat/config.git .config
   # Or if already cloned:
   cd ~/.config && git pull
   ```

2. **Create secrets file** (not in git):
   ```bash
   cat > ~/.bash_private << 'EOF'
   export WANDB_API_KEY=your_key_here
   EOF
   chmod 600 ~/.bash_private
   ```

3. **Symlink configurations**:
   ```bash
   ln -sf ~/.config/bash/bashrc.cluster ~/.bashrc
   ln -sf ~/.config/vim/vimrc ~/.vimrc
   ```

4. **Reload**:
   ```bash
   source ~/.bashrc
   ```

## Common Aliases & Functions

### Navigation
- `..` - Go up one directory
- `...` - Go up two directories
- `ll` - Detailed directory listing
- `v`, `vi` - Quick vim shortcuts

### Git
- `gp` - Git pull

### Special: Outputs Navigator
**`vo [dir]`** - Navigate to outputs directory and open latest file in vim

```bash
# Default: looks for ./outputs/ and opens most recent file
vo

# Custom directory
vo results
vo logs
```

**Use case**: Quickly inspect latest experiment outputs, training logs, etc.

## Cluster-Specific (SLURM + GPU)

### SLURM
- `sq` - Show my jobs in queue
- `sb` - Submit batch job (main.sh)
- `sj` - Show today's job history (latest first)
- `sjw` - Watch today's job history (auto-refresh)

### GPU Monitoring
- `gpustat` - Show GPU usage (formatted table)
- `watch gpustat` - Continuous GPU monitoring

### WandB
- `wandb_sync` - Sync offline runs to cloud

### Directories
- `rect` - Quick cd to rect_flows project

## Vim Configuration

**Location**: `~/.config/vim/vimrc`

**Features**:
- Line numbers (relative + absolute)
- Syntax highlighting
- Smart search (case-insensitive + incremental)
- 7-line scroll padding
- Cursorline highlight
- Vi-style splits (open below/right)
- Mouse support
- 2-space tabs

**Same config** works on both local machine and cluster.

## Security: Private Secrets

**Never commit** API keys, tokens, or passwords to git.

**Pattern**: Store in `~/.bash_private`, then source it:

```bash
# In ~/.bash_private (not in git, chmod 600)
export WANDB_API_KEY=xxxxx
export OPENAI_API_KEY=xxxxx

# In bashrc/shell config
[ -f ~/.bash_private ] && source ~/.bash_private
```

## Syncing Changes

**Local → Cluster**:
```bash
# On local
cd ~/.config
git add .
git commit -m "Update shell config"
git push

# On cluster
cd ~/.config
git pull
source ~/.bashrc
```

**Cluster → Local** (if you edit on cluster):
```bash
# On cluster
cd ~/.config
git add .
git commit -m "Update from cluster"
git push

# On local
cd ~/.config
git pull
source ~/.bash_profile
```

## File Organization

| File | Purpose | Location |
|------|---------|----------|
| `shell/common.sh` | Shared aliases/functions | Both |
| `shell/local.sh` | macOS-specific config | Local only |
| `bash/bashrc.cluster` | Cluster environment | Cluster only |
| `vim/vimrc` | Vim settings | Both |
| `nvim/` | Full neovim setup | Local only |
| `~/.bash_private` | Secrets (not in git) | Both |

## Adding New Functionality

### Universal (both local + cluster)
→ Add to `~/.config/shell/common.sh`

### Local-only (macOS, homebrew, etc.)
→ Add to `~/.config/shell/local.sh`

### Cluster-only (SLURM, GPU tools)
→ Add to `~/.config/bash/bashrc.cluster`

### Vim/Editor
→ Add to `~/.config/vim/vimrc`

## Troubleshooting

**Functions not found in watch/subshells**:
```bash
# Export the function
export -f function_name
```

**Symlink broken**:
```bash
ls -la ~/.bashrc  # Check what it points to
ln -sf ~/.config/bash/bashrc.cluster ~/.bashrc  # Recreate
```

**Changes not taking effect**:
```bash
source ~/.bashrc  # Or source ~/.bash_profile on local
# Or exit and reconnect for clean shell
```

**Git conflicts**:
```bash
cd ~/.config
git status
git pull --rebase  # If you have local changes
```
