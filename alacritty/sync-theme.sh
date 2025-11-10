#!/usr/bin/env bash
# Sync Alacritty theme with macOS system theme
# This script watches ~/.config/theme/current and updates Alacritty when it changes

set -euo pipefail

CONFIG="${HOME}/.config/alacritty/alacritty.toml"
CONFIG_DIR="$(dirname "$CONFIG")"
LIGHT_REL='~/.config/alacritty/themes/light.toml'
DARK_REL='~/.config/alacritty/themes/dark.toml'
LIGHT_PATH="${CONFIG_DIR}/themes/light.toml"
DARK_PATH="${CONFIG_DIR}/themes/dark.toml"
THEME_DIR="${HOME}/.config/theme"
STATE_FILE="${THEME_DIR}/current"

ensure_state_file() {
  mkdir -p "$THEME_DIR"
  if [[ ! -f "$STATE_FILE" ]]; then
    # Detect macOS theme on first run
    if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
      printf 'dark\n' > "$STATE_FILE"
    else
      printf 'light\n' > "$STATE_FILE"
    fi
  fi
}

update_alacritty_import() {
  local target_rel="$1"
  local tmp_file
  tmp_file="$(mktemp)"
  trap 'rm -f "$tmp_file"' EXIT

  sed -E "s|^import = \\[\".*\"\\]|import = [\"$target_rel\"]|" "$CONFIG" > "$tmp_file"
  mv "$tmp_file" "$CONFIG"
  trap - EXIT
  rm -f "$tmp_file"

  # Reload Alacritty config
  pkill -USR1 alacritty 2>/dev/null || true
}

apply_theme() {
  local theme="$1"
  local target_rel

  if [[ "$theme" == "dark" ]]; then
    target_rel="$DARK_REL"
  else
    target_rel="$LIGHT_REL"
  fi

  update_alacritty_import "$target_rel"
}

# Get macOS system theme
get_macos_theme() {
  if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
    echo "dark"
  else
    echo "light"
  fi
}

# Watch macOS theme and update state file + Alacritty
watch_macos_theme() {
  local last_theme=""

  while true; do
    local current_theme
    current_theme="$(get_macos_theme)"

    if [[ "$current_theme" != "$last_theme" ]]; then
      echo "macOS theme changed to: $current_theme"
      printf '%s\n' "$current_theme" > "$STATE_FILE"
      apply_theme "$current_theme"
      last_theme="$current_theme"
    fi

    sleep 3
  done
}

main() {
  if [[ ! -f "$CONFIG" ]]; then
    echo "alacritty configuration not found at $CONFIG" >&2
    exit 1
  fi

  if [[ ! -f "$LIGHT_PATH" ]] || [[ ! -f "$DARK_PATH" ]]; then
    echo "theme files missing; expected at $LIGHT_PATH and $DARK_PATH" >&2
    exit 1
  fi

  ensure_state_file

  # Apply initial theme
  initial_theme="$(get_macos_theme)"
  apply_theme "$initial_theme"

  # Watch for macOS theme changes
  echo "Watching macOS theme changes (Ctrl+C to stop)..."
  watch_macos_theme
}

main "$@"
