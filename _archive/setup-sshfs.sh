#!/bin/bash
# Setup SSHFS for MIT cluster remote development
# This is simpler than distant and requires NO installation on remote server

set -e

echo "🚀 Setting up SSHFS for MIT Cluster"
echo "===================================="
echo ""

# Install macFUSE and SSHFS
echo "📦 Installing macFUSE and SSHFS..."
if ! command -v sshfs &> /dev/null; then
    echo "Installing via Homebrew..."
    brew install --cask macfuse
    brew install gromgit/fuse/sshfs-mac

    echo ""
    echo "⚠️  IMPORTANT: macFUSE requires a system extension."
    echo "You may need to:"
    echo "1. Open System Settings"
    echo "2. Go to Privacy & Security"
    echo "3. Scroll down and allow the macFUSE system extension"
    echo "4. Restart your Mac"
    echo ""
    echo "Press Enter after you've enabled the extension..."
    read
else
    echo "✅ sshfs already installed"
fi

# Create mount point
echo ""
echo "📁 Creating mount point..."
mkdir -p ~/cluster
echo "✅ Created ~/cluster directory"

# Create convenience aliases
echo ""
echo "📝 Adding aliases to ~/.bash_profile..."

cat >> ~/.bash_profile << 'EOF'

# MIT Cluster SSHFS aliases
alias mount-cluster='sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,auto_cache,follow_symlinks brastmck@eofe10.mit.edu:/home/brastmck ~/cluster'
alias umount-cluster='diskutil unmount force ~/cluster 2>/dev/null || umount ~/cluster 2>/dev/null'
alias check-cluster='mount | grep cluster'

# Quick cluster development
function cdev() {
    if ! check-cluster &>/dev/null; then
        echo "📡 Mounting cluster..."
        mount-cluster
        sleep 1
    fi
    cd ~/cluster
    if [ -n "$1" ]; then
        nvim "$@"
    else
        nvim .
    fi
}
EOF

echo "✅ Aliases added!"

# Source the profile
source ~/.bash_profile

echo ""
echo "=================================================="
echo "✅ Setup complete!"
echo "=================================================="
echo ""
echo "📚 USAGE:"
echo ""
echo "1. Mount cluster:"
echo "   mount-cluster"
echo ""
echo "2. Navigate and edit:"
echo "   cd ~/cluster"
echo "   nvim your-project/"
echo ""
echo "3. Quick dev session:"
echo "   cdev                 # Opens nvim in ~/cluster"
echo "   cdev file.py         # Opens specific file"
echo ""
echo "4. Unmount when done:"
echo "   umount-cluster"
echo ""
echo "5. Check if mounted:"
echo "   check-cluster"
echo ""
echo "🎉 Try it now: mount-cluster"
