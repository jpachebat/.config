#!/bin/bash
# Install lazy.nvim on clusters with old Git versions
# Works with Git 1.8+

set -e

echo "=== lazy.nvim Installation (Old Git Compatible) ==="
echo ""

LAZYPATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
echo "Installation path: $LAZYPATH"

# Create parent directory
mkdir -p "$(dirname "$LAZYPATH")"

# Remove if exists
if [ -d "$LAZYPATH" ]; then
    echo "Removing existing installation..."
    rm -rf "$LAZYPATH"
fi

echo "Cloning lazy.nvim (this may take a minute)..."
echo ""

# Use basic clone without modern options
if git clone https://github.com/folke/lazy.nvim.git "$LAZYPATH"; then
    cd "$LAZYPATH"
    git checkout stable

    echo ""
    echo "✓ Successfully installed lazy.nvim"

    # Verify
    if [ -f "$LAZYPATH/lua/lazy/init.lua" ]; then
        echo "✓ Installation verified"
        echo ""
        echo "Now run: nvim"
        exit 0
    else
        echo "✗ Installation incomplete"
        exit 1
    fi
else
    echo "✗ Clone failed"
    exit 1
fi
