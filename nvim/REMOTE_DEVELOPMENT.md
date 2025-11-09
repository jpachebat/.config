# Remote Development with SSHFS

Complete guide for editing files on Cholesky cluster using local Neovim with full configuration support.

## Why SSHFS?

✅ **Simple** - No installation needed on remote server  
✅ **Complete** - Full local Neovim config works (all plugins, AI tools)  
✅ **Real-time** - Changes sync immediately in both directions  
✅ **Efficient** - Great for moderate codebases and large log files  
✅ **Works everywhere** - No glibc dependency issues  

## Current Setup

**Mount Points:**
- `~/work/cholesky-home` → `/mnt/beegfs/home/CMAP/jean.pachebat` (your $HOME)
- `~/work/cholesky-work` → `/mnt/beegfs/workdir/jean.pachebat` (your $WORKDIR)

**Connection:** SSH via `cholesky` host alias

## Commands Reference

**Mounting:**
```bash
mount-cholesky           # Mount both home AND work
mount-cholesky-home      # Mount only home
mount-cholesky-work      # Mount only work
```

**Unmounting:**
```bash
umount-cholesky          # Unmount both
umount-cholesky-home     # Unmount only home
umount-cholesky-work     # Unmount only work
```

**Quick dev:**
```bash
chol                     # Opens nvim in work dir (default)
chol-home                # Opens nvim in home dir
chol file.py             # Opens specific file
```

**Status:**
```bash
check-cholesky           # Show what's mounted
```

## Quick Start

```bash
# 1. Mount
mount-cholesky

# 2. Edit
cd ~/work/cholesky-work
nvim your-project/

# 3. Unmount when done
umount-cholesky
```

## ⚠️ IMPORTANT SAFETY

**SSHFS is a LIVE mount, not a copy!**

```bash
rm -rf ~/work/cholesky-work/folder
```
☠️ **This DELETES on remote cluster immediately!**

Treat mounted directories as if you're working directly on the server - because you are!

## Performance

| Method | LSP Speed | Setup | Works with old glibc? | Local config? |
|--------|-----------|-------|----------------------|---------------|
| **SSHFS** | ⚠️ Moderate | ✅ Easy | ✅ Yes | ✅ Yes |
| Distant | ✅ Fast | ⚠️ Moderate | ❌ No | ✅ Yes |

**SSHFS is the best option for Cholesky's old glibc (2.17).**

Enjoy remote development, beau gosse! 🚀
