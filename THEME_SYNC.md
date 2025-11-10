# Automatic Theme Sync with macOS

Your Neovim and Alacritty themes now automatically sync with macOS system theme (dark/light mode).

## How It Works

**macOS System Theme** → **Auto-sync** → **Neovim + Alacritty**

When you change macOS appearance (System Settings → Appearance → Light/Dark), both applications update within ~3 seconds.

### Neovim Theme Sync
- **File**: `nvim/lua/neotex/util/theme.lua`
- **How**: Checks macOS theme every 3 seconds
- **Themes**:
  - Dark mode → Kanagawa Wave (deep black variant)
  - Light mode → Kanagawa Lotus

### Alacritty Theme Sync
- **Script**: `~/.config/alacritty/sync-theme.sh`
- **Launch Agent**: `~/Library/LaunchAgents/com.user.alacritty-theme-sync.plist`
- **How**: Background daemon watches macOS theme changes
- **Themes**:
  - Dark mode → `~/.config/alacritty/themes/dark.toml`
  - Light mode → `~/.config/alacritty/themes/light.toml`

### Shared State
Both use the same state file: `~/.config/theme/current`

This ensures they stay in sync even if you manually change one.

## Manual Control

If you want to temporarily override:

**Neovim**:
```vim
:ThemeSync dark   " Force dark mode
:ThemeSync light  " Force light mode
:ThemeSync        " Re-sync with macOS
```

**Alacritty**:
```bash
~/.config/alacritty/toggle-theme.sh  # Toggle between light/dark
```

## Auto-start

The Alacritty theme sync runs automatically on login via macOS Launch Agent.

**Check status**:
```bash
launchctl list | grep alacritty-theme-sync
```

**Stop/Start**:
```bash
launchctl unload ~/Library/LaunchAgents/com.user.alacritty-theme-sync.plist
launchctl load ~/Library/LaunchAgents/com.user.alacritty-theme-sync.plist
```

**Logs**:
```bash
tail -f /tmp/alacritty-theme-sync.log
tail -f /tmp/alacritty-theme-sync.error.log
```

## macOS Auto Dark Mode

This works best with macOS auto dark mode enabled:
- System Settings → Appearance → Auto
- macOS will automatically switch based on sunrise/sunset times
- Neovim and Alacritty follow along automatically

No more fixed-hour theme switching!
