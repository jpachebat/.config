#!/bin/bash
# Manual lazy.nvim Installation for Clusters
# Run this if lazy.nvim fails to auto-install

set -e  # Exit on error

echo "=== Manual lazy.nvim Installation ==="
echo ""

# Define paths
LAZYPATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
echo "Installation path: $LAZYPATH"
echo ""

# Create parent directory if needed
mkdir -p "$(dirname "$LAZYPATH")"

# Check if already exists
if [ -d "$LAZYPATH" ]; then
    echo "⚠ lazy.nvim directory already exists"
    read -p "Remove and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing installation..."
        rm -rf "$LAZYPATH"
    else
        echo "Aborting."
        exit 0
    fi
fi

echo "Cloning lazy.nvim from GitHub..."
echo ""

# Try different clone methods
if git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZYPATH"; then
    echo ""
    echo "✓ Successfully installed lazy.nvim"
    echo ""

    # Verify installation
    if [ -f "$LAZYPATH/lua/lazy/init.lua" ]; then
        echo "✓ Installation verified"
        echo ""
        echo "Now you can run: nvim"
        exit 0
    else
        echo "✗ Installation incomplete - missing files"
        exit 1
    fi
else
    echo ""
    echo "✗ Git clone failed"
    echo ""
    echo "Trying alternative method (full clone)..."

    if git clone https://github.com/folke/lazy.nvim.git "$LAZYPATH"; then
        cd "$LAZYPATH"
        git checkout stable
        echo ""
        echo "✓ Successfully installed lazy.nvim (full clone)"
        exit 0
    else
        echo ""
        echo "✗ All installation methods failed"
        echo ""
        echo "Possible issues:"
        echo "1. No network access to GitHub"
        echo "2. Firewall/proxy blocking git"
        echo "3. SSL certificate issues"
        echo ""
        echo "Solutions to try:"
        echo "1. Configure git proxy if behind firewall:"
        echo "   git config --global http.proxy http://proxy.example.com:8080"
        echo ""
        echo "2. Disable SSL verification (security risk, cluster only):"
        echo "   git config --global http.sslVerify false"
        echo ""
        echo "3. Download manually and extract:"
        echo "   wget https://github.com/folke/lazy.nvim/archive/refs/heads/stable.zip"
        echo "   unzip stable.zip"
        echo "   mv lazy.nvim-stable '$LAZYPATH'"
        exit 1
    fi
fi
