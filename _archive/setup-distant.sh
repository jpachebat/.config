#!/bin/bash
# Quick setup script for Distant.nvim remote development
# Run this on your LOCAL machine (macOS)

set -e  # Exit on error

echo "🚀 Setting up Distant.nvim for remote development"
echo "=================================================="
echo ""

# Step 1: Install distant locally
echo "📦 Step 1: Installing distant CLI locally..."
if command -v distant &> /dev/null; then
    echo "✅ distant already installed: $(distant --version)"
else
    if command -v brew &> /dev/null; then
        echo "Installing via Homebrew..."
        brew install distant
    elif command -v cargo &> /dev/null; then
        echo "Installing via Cargo..."
        cargo install distant
    else
        echo "❌ Error: Neither Homebrew nor Cargo found."
        echo "Please install Homebrew or Rust, then run this script again."
        exit 1
    fi
    echo "✅ distant installed: $(distant --version)"
fi

echo ""

# Step 2: Install on remote
echo "📡 Step 2: Installing distant on MIT cluster..."
echo "=================================================="
echo ""
echo "📝 INSTRUCTIONS FOR REMOTE INSTALLATION:"
echo ""
echo "1. SSH into MIT cluster:"
echo "   ssh brastmck@eofe10.mit.edu"
echo ""
echo "2. Run these commands on the remote server:"
echo ""
cat << 'REMOTE_COMMANDS'
# Download distant binary
wget https://github.com/chipsenkbeil/distant/releases/latest/download/distant-x86_64-unknown-linux-gnu

# Make executable
chmod +x distant-x86_64-unknown-linux-gnu

# Create bin directory
mkdir -p ~/.local/bin

# Move binary
mv distant-x86_64-unknown-linux-gnu ~/.local/bin/distant

# Add to PATH in .bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Reload shell
source ~/.bashrc

# Verify installation
distant --version
REMOTE_COMMANDS

echo ""
echo "3. Copy the commands above and paste them in your SSH session"
echo ""
echo "=================================================="
echo ""

# Step 3: Setup SSH keys (optional but recommended)
echo "🔑 Step 3: SSH Key Setup (Optional but Recommended)"
echo "=================================================="
echo ""

if [ -f ~/.ssh/id_ed25519 ] || [ -f ~/.ssh/id_rsa ]; then
    echo "✅ SSH key already exists"
    echo ""
    echo "To copy it to MIT cluster, run:"
    echo "  ssh-copy-id brastmck@eofe10.mit.edu"
else
    echo "No SSH key found. Would you like to generate one? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Generating SSH key..."
        ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"
        echo ""
        echo "✅ SSH key generated!"
        echo ""
        echo "Now copy it to MIT cluster:"
        echo "  ssh-copy-id brastmck@eofe10.mit.edu"
    else
        echo "⏭️  Skipping SSH key generation"
    fi
fi

echo ""
echo "=================================================="
echo "✅ Local setup complete!"
echo "=================================================="
echo ""
echo "📚 NEXT STEPS:"
echo ""
echo "1. Complete remote installation (see instructions above)"
echo ""
echo "2. (Optional) Setup passwordless SSH:"
echo "   ssh-copy-id brastmck@eofe10.mit.edu"
echo ""
echo "3. Restart Neovim and sync plugins:"
echo "   nvim"
echo "   :Lazy sync"
echo ""
echo "4. Connect to MIT cluster:"
echo "   :DistantMIT"
echo ""
echo "5. Open remote files:"
echo "   :DistantOpen"
echo ""
echo "📖 Full documentation:"
echo "   ~/.config/nvim/REMOTE_DEVELOPMENT.md"
echo ""
echo "🎉 Happy remote coding!"
