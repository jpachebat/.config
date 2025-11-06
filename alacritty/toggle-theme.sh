#!/usr/bin/env bash
set -euo pipefail

CONFIG="${HOME}/.config/alacritty/alacritty.toml"
CONFIG_DIR="$(dirname "$CONFIG")"
LIGHT_REL='~/.config/alacritty/themes/light.toml'
DARK_REL='~/.config/alacritty/themes/dark.toml'
LIGHT_PATH="${CONFIG_DIR}/themes/light.toml"
DARK_PATH="${CONFIG_DIR}/themes/dark.toml"
THEME_DIR="${HOME}/.config/theme"
STATE_FILE="${THEME_DIR}/current"
APPLY_TMUX="${THEME_DIR}/apply-tmux.sh"

ensure_state_file() {
  mkdir -p "$THEME_DIR"
  if [[ ! -f "$STATE_FILE" ]]; then
    printf 'light\n' > "$STATE_FILE"
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
  pkill -USR1 alacritty 2>/dev/null || true
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
  if [[ ! -x "$APPLY_TMUX" ]]; then
    chmod +x "$APPLY_TMUX" 2>/dev/null || true
  fi

  local current next target_rel
  current="$(tr -d '\r\n' < "$STATE_FILE" 2>/dev/null || echo light)"
  if [[ "$current" == "light" ]]; then
    next="dark"
    target_rel="$DARK_REL"
  else
    next="light"
    target_rel="$LIGHT_REL"
  fi

  printf '%s\n' "$next" > "$STATE_FILE"
  update_alacritty_import "$target_rel"
  if [[ -x "$APPLY_TMUX" ]]; then
    "$APPLY_TMUX" "$next" || true
  fi

  echo "Switched theme to ${next}"
}

main "$@"
