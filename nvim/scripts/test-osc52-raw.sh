#!/bin/bash
# Raw OSC52 test - bypasses shell interpretation

echo "=== Raw OSC52 Test ==="
echo ""

# Method 1: printf with explicit codes
echo "Test 1: Using printf..."
printf '\033]52;c;%s\a' "$(printf '%s' 'Test1: Hello!' | base64)"
echo "Sent: 'Test1: Hello!'"
echo ""

# Method 2: Using echo -e
echo "Test 2: Using echo -e..."
echo -e "\033]52;c;$(echo -n 'Test2: World!' | base64)\007"
echo "Sent: 'Test2: World!'"
echo ""

# Method 3: Using cat
echo "Test 3: Using cat with heredoc..."
cat <<EOF
$(printf '\033]52;c;%s\a' "$(echo -n 'Test3: Cat method!' | base64)")
EOF
echo "Sent: 'Test3: Cat method!'"
echo ""

echo "Now try pasting on your Mac (Cmd+V)"
echo "You should see one of: 'Test1: Hello!' or 'Test2: World!' or 'Test3: Cat method!'"
echo ""
echo "If NONE work, the issue is:"
echo "  1. Alacritty not recognizing OSC52"
echo "  2. SSH server stripping escape codes"
echo "  3. Terminal emulator mismatch"
