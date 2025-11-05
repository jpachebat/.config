#!/bin/bash
# Cluster Installation Debug Script
# Run this on the cluster to diagnose lazy.nvim installation issues

echo "=== Neovim Cluster Installation Diagnostics ==="
echo ""

# Check Neovim version
echo "1. Neovim Version:"
nvim --version | head -3
echo ""

# Check Git
echo "2. Git Version:"
git --version
echo ""

# Check network connectivity
echo "3. Network Connectivity (GitHub):"
if command -v curl &> /dev/null; then
    curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" https://github.com
elif command -v wget &> /dev/null; then
    wget --spider -q https://github.com && echo "GitHub is reachable" || echo "Cannot reach GitHub"
else
    echo "Neither curl nor wget available"
fi
echo ""

# Check lazy.nvim directory
echo "4. Lazy.nvim Installation Status:"
LAZYPATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
echo "Expected path: $LAZYPATH"
if [ -d "$LAZYPATH" ]; then
    echo "✓ Directory exists"
    echo "  Files:"
    ls -la "$LAZYPATH" | head -10
    if [ -f "$LAZYPATH/lua/lazy/init.lua" ]; then
        echo "✓ lazy.nvim properly installed"
    else
        echo "✗ Directory exists but lazy.nvim files missing"
    fi
else
    echo "✗ Directory does not exist"
    echo "  Attempting manual installation..."

    # Try manual installation
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZYPATH"

    if [ $? -eq 0 ]; then
        echo "✓ Manual installation succeeded"
    else
        echo "✗ Manual installation failed"
        echo "  Git clone error code: $?"
    fi
fi
echo ""

# Check config directory
echo "5. Config Directory:"
NVIMCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
echo "Config path: $NVIMCONFIG"
if [ -d "$NVIMCONFIG" ]; then
    echo "✓ Config directory exists"
    echo "  Key files:"
    ls -1 "$NVIMCONFIG/init.lua" "$NVIMCONFIG/lua/neotex/bootstrap.lua" 2>/dev/null || echo "  Missing key files"
else
    echo "✗ Config directory missing"
fi
echo ""

# Check permissions
echo "6. Permissions:"
echo "Data directory:"
ls -ld "${XDG_DATA_HOME:-$HOME/.local/share}/nvim" 2>/dev/null || echo "  Directory doesn't exist yet"
echo ""

# Check proxy settings (common issue on clusters)
echo "7. Proxy Settings:"
echo "HTTP_PROXY: ${HTTP_PROXY:-not set}"
echo "HTTPS_PROXY: ${HTTPS_PROXY:-not set}"
echo "http_proxy: ${http_proxy:-not set}"
echo "https_proxy: ${https_proxy:-not set}"
echo ""

# Check if behind firewall
echo "8. Git Configuration:"
git config --global --get http.proxy || echo "No HTTP proxy configured"
git config --global --get https.proxy || echo "No HTTPS proxy configured"
git config --global --get http.sslVerify || echo "SSL verify not configured (default: true)"
echo ""

echo "=== Diagnostics Complete ==="
echo ""
echo "If lazy.nvim installation failed, try:"
echo "1. Check if you need to configure proxy settings"
echo "2. Verify you can clone from GitHub manually:"
echo "   git clone https://github.com/folke/lazy.nvim.git /tmp/test-lazy"
echo "3. Check cluster documentation for network restrictions"
