# Common shell configuration
# Sourced by both local and cluster bashrc files

# Vi mode
set -o vi

# Git shortcuts
alias gp='git pull'

# Directory navigation helpers
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah'

# Quick vim shortcuts
alias v='vim'
alias vi='vim'

# Outputs directory navigation (vo = vim outputs)
vo() {
  local outputs_dir="${1:-outputs}"
  if [ -d "$outputs_dir" ]; then
    cd "$outputs_dir"
    # Find most recent file and open in vim
    local latest=$(ls -t | head -1)
    if [ -n "$latest" ]; then
      vim "$latest"
    else
      echo "No files in $outputs_dir"
    fi
  else
    echo "Directory $outputs_dir not found"
  fi
}
export -f vo
