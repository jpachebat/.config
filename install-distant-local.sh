#!/bin/bash
# Install distant CLI on macOS (local machine)

set -e

echo "🚀 Installing distant CLI for macOS"
echo "===================================="
echo ""

# Check if already installed
if command -v distant &> /dev/null; then
    echo "✅ distant already installed: $(distant --version)"
    exit 0
fi

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    BINARY="distant-aarch64-apple-darwin"
    echo "📱 Detected Apple Silicon (M1/M2/M3)"
else
    BINARY="distant-x86_64-apple-darwin"
    echo "💻 Detected Intel Mac"
fi

# Create bin directory
mkdir -p ~/.local/bin

# Download binary
echo "📥 Downloading $BINARY..."
curl -L "https://github.com/chipsenkbeil/distant/releases/latest/download/$BINARY" -o ~/.local/bin/distant

# Make executable
chmod +x ~/.local/bin/distant

# Add to PATH if not already there
# Check both .bash_profile and .bashrc
SHELL_RC=""
if [ -f ~/.bash_profile ]; then
    SHELL_RC=~/.bash_profile
elif [ -f ~/.bashrc ]; then
    SHELL_RC=~/.bashrc
else
    SHELL_RC=~/.bash_profile
    touch ~/.bash_profile
fi

if ! grep -q '.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    echo "✅ Added ~/.local/bin to PATH in $SHELL_RC"
fi

# Test installation
if ~/.local/bin/distant --version &> /dev/null; then
    echo ""
    echo "✅ Installation successful!"
    echo "📍 Installed at: ~/.local/bin/distant"
    echo "📦 Version: $(~/.local/bin/distant --version)"
    echo ""
    echo "⚠️  IMPORTANT: Restart your terminal or run:"
    echo "   source $SHELL_RC"
else
    echo "❌ Installation failed. Please try manual installation."
    exit 1
fi
