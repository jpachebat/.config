#!/bin/bash
# Alternative clipboard method using terminal bracketed paste
# This is a fallback if OSC52 doesn't work

if [ -z "$1" ]; then
    echo "Usage: cat file.txt | $0"
    echo "   or: $0 'text to copy'"
    exit 1
fi

if [ -p /dev/stdin ]; then
    # Reading from pipe
    TEXT=$(cat)
else
    # Reading from argument
    TEXT="$1"
fi

# Base64 encode
B64=$(echo -n "$TEXT" | base64)

# Try multiple OSC52 formats
# Format 1: Standard OSC52
printf "\033]52;c;%s\007" "$B64"

# Format 2: Alternative escape
printf "\033]52;c;%s\033\\" "$B64"

# Format 3: With explicit ST
printf "\033]52;c;%s\x1b\\" "$B64"

echo "Clipboard copy attempted via OSC52"
echo "Text length: ${#TEXT} characters"
