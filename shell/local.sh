# Local machine specific configuration
# Sourced by ~/.bash_profile on local machine

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Homebrew
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # macOS aliases
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
fi

# Local paths
export PATH="$HOME/.local/bin:$PATH"

# SSHFS cluster shortcuts (from existing config)
if [ -f ~/.config/shell/sshfs-mounts.sh ]; then
  source ~/.config/shell/sshfs-mounts.sh
fi

# Load common configuration
if [ -f ~/.config/shell/common.sh ]; then
  source ~/.config/shell/common.sh
fi

# Load private secrets (API keys, tokens)
if [ -f ~/.bash_private ]; then
  source ~/.bash_private
fi
