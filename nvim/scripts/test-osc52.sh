#!/bin/bash
# Test OSC 52 clipboard support
# Run this on the cluster to test if OSC52 works

echo "=== OSC 52 Clipboard Test ==="
echo ""

# Test 1: Check environment
echo "1. Environment Check:"
echo "   SSH_TTY: ${SSH_TTY:-not set}"
echo "   SSH_CONNECTION: ${SSH_CONNECTION:-not set}"
echo "   TMUX: ${TMUX:-not set}"
echo ""

# Test 2: Send OSC 52 sequence
echo "2. Testing OSC 52..."
echo "   Sending 'Hello from cluster!' to clipboard..."
printf "\033]52;c;$(printf "Hello from cluster!" | base64)\a"
echo ""
echo "   ✓ Sequence sent"
echo ""

# Test 3: Instructions
echo "3. Verification:"
echo "   On your LOCAL machine, try pasting (Cmd+V)"
echo "   You should see: Hello from cluster!"
echo ""
echo "   If you see it: OSC 52 works! ✅"
echo "   If you don't: Check Alacritty config ⚠️"
echo ""

# Test 4: Alacritty config check
echo "4. Next Steps:"
echo ""
echo "   If OSC 52 doesn't work, add this to your LOCAL"
echo "   ~/.config/alacritty/alacritty.toml:"
echo ""
echo "   [terminal]"
echo "   osc52 = \"CopyPaste\""
echo ""
