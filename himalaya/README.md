# Himalaya Email Client

**Status**: Not currently in use, kept for future migration

## What is Himalaya?

Himalaya is a terminal-based email client written in Rust. It's designed for CLI-first workflows and can be integrated with Neovim.

## Current Setup

This directory contains:
- `sync_coordinator.json` - Sync configuration metadata
- `backups/` - Backup directory (currently empty)

## When You're Ready to Use It

1. **Installation**: Install himalaya via your package manager
   ```bash
   brew install himalaya  # macOS
   ```

2. **Configuration**: You'll need to create a `config.toml` file with your email accounts
   - Documentation: https://github.com/soywod/himalaya

3. **Neovim Integration**: This config appears to have some neovim sync functionality already set up

## Original Config Source

This configuration came from the NeoTex setup by benbrastmckie, which includes email workflow integration with Neovim.

## Future Setup Resources

- Official docs: https://pimalaya.org/himalaya/
- Neovim integration: Check nvim/docs/ for any himalaya-specific keybindings
- Account setup: Configure IMAP/SMTP for your email providers

---

*Note: This is a placeholder. Update this file when you actually configure himalaya.*
