# Tmux Configuration

Custom tmux setup optimized for managing local and remote sessions, especially for HPC cluster workflows.

## Key Features

- **Prefix**: `C-Space` (more ergonomic than default `C-b`)
- **Nested Mode**: Smart handling of tmux-within-tmux sessions
- **Vi Mode**: Vi-style keybindings in copy mode
- **Theme Integration**: Syncs with Alacritty/Nvim themes

---

## Nested Tmux Mode

When SSH'ing into clusters that also run tmux, you can easily control the inner session without interference.

### How It Works

**Toggle nested mode**: `F12` (industry standard)

- **Normal mode** (default): Controls your local tmux session
- **Nested mode**: All keys pass through to the remote/inner tmux session
  - Status bar dims and shows red "NESTED" indicator
  - You can now control the inner tmux normally with its prefix

### Usage Example

```bash
# On local machine in tmux
C-Space c         # Create new window locally

# SSH into cluster
ssh cholesky

# The cluster also has tmux running
# Enter nested mode:
F12               # → Status bar dims, shows "NESTED"

# Now control the remote tmux:
C-Space c         # Creates window in REMOTE tmux
C-Space w         # Shows windows in REMOTE tmux
C-Space d         # Detaches from REMOTE tmux (back to cluster shell)

# Exit nested mode to control local tmux again:
F12               # → Status bar returns to normal
```

### Key Bindings in Nested Mode

When in nested mode (`F12`), all keys pass through to the inner tmux.
Just use tmux normally - the outer session is completely disabled.

| Keys | Action |
|------|--------|
| `F12` | Exit nested mode (return to local control) |
| `C-Space c` | New window (inner) |
| `C-Space d` | Detach (inner) |
| `C-Space w` | List windows (inner) |
| `C-Space 0-9` | Switch to window N (inner) |
| Any key | Works normally - outer tmux is off |

No special bindings needed - the outer layer is simply turned off.

---

## Other Useful Bindings

| Keys | Action |
|------|--------|
| `C-Space r` | Reload tmux configuration |
| `C-Space c` | Create new window |
| `C-Space d` | Detach from session |
| `C-Space w` | List windows |
| `C-Space 0-9` | Switch to window N |

---

## Installation

The config is automatically loaded from `~/.config/tmux/tmux.conf` if you've set up the symlink:

```bash
# Link the config (if not already done)
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf

# Reload config in running session
tmux source-file ~/.config/tmux/tmux.conf
# Or press: C-Space r
```

---

## Workflow: Local Tmux → SSH → Remote Tmux

### Recommended Setup

**Local session** (your laptop):
- Use tmux as orchestration layer
- Have persistent panes with SSH connections
- Mount remote filesystems via sshfs

**Remote session** (cluster):
- Use tmux for long-running jobs
- Each project gets its own tmux session
- Jobs continue even if SSH drops

### Example Workflow

```bash
# Local: Start home session
thome              # Loads ~/.config/tmuxp/global.yaml

# Window 1: Dashboard (local)
# Window 2: Two persistent SSH connections to clusters
# Window 3: Queue monitoring

# In the SSH window, enter nested mode
F12

# Now attach to or create project sessions on cluster
tmux new -s myproject
# Or: tmux attach -t myproject

# Control this remote session normally
C-Space c          # New window for this project
# ... do work ...

# When done, exit nested mode
F12

# Back to controlling local tmux
C-Space 0          # Jump to dashboard window
```

---

## Tips

1. **Visual Feedback**: Always check the status bar
   - Normal: default theme
   - Nested: dimmed with red "NESTED" indicator

2. **Quick Toggle**: `F12` works both ways (enter/exit)

3. **Standard Practice**: F12 is the industry-standard key for nested tmux toggling

4. **Muscle Memory**: After toggling to nested mode, just use tmux normally

5. **No Conflicts**: The inner tmux doesn't need special config - it works with any prefix

6. **SSH Auto-Attach**: Add to `~/.ssh/config`:
   ```
   Host cholesky
       RequestTTY yes
       RemoteCommand tmux new -As main
   ```
   Now `ssh cholesky` automatically attaches to the persistent session!
