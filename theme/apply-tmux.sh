#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="${HOME}/.config/theme"
STATE_FILE="${THEME_DIR}/current"
MODE="${1:-}"

ensure_state_file() {
  mkdir -p "$THEME_DIR"
  if [[ ! -f "$STATE_FILE" ]]; then
    printf 'light\n' > "$STATE_FILE"
  fi
}

read_mode() {
  ensure_state_file
  if [[ -z "$MODE" ]]; then
    MODE="$(tr -d '\r\n' < "$STATE_FILE" 2>/dev/null || echo light)"
  fi
  if [[ "$MODE" != "dark" ]]; then
    MODE="light"
  fi
}

apply_tmux() {
  command -v tmux >/dev/null 2>&1 || return 0
  if ! tmux has-session >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$MODE" == "dark" ]]; then
    tmux set -g status-style "bg=#1F1F28,fg=#DCD7BA"
    tmux set -g status-left-style "bg=#1F1F28,fg=#7E9CD8"
    tmux set -g status-right-style "bg=#1F1F28,fg=#7E9CD8"
    tmux set -g message-style "bg=#1F1F28,fg=#7E9CD8"
    tmux set -g pane-border-style "fg=#2A2A37"
    tmux set -g pane-active-border-style "fg=#7E9CD8"
    tmux set -g window-status-current-style "bg=#223249,fg=#DCD7BA"
  else
    tmux set -g status-style "bg=#F5F0E8,fg=#2E2E2E"
    tmux set -g status-left-style "bg=#F5F0E8,fg=#0A3D6B"
    tmux set -g status-right-style "bg=#F5F0E8,fg=#0A3D6B"
    tmux set -g message-style "bg=#F5F0E8,fg=#0A3D6B"
    tmux set -g pane-border-style "fg=#C8C0AF"
    tmux set -g pane-active-border-style "fg=#0A3D6B"
    tmux set -g window-status-current-style "bg=#EAE2D3,fg=#2E2E2E"
  fi
}

read_mode
apply_tmux
