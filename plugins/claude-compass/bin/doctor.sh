#!/usr/bin/env bash
set -euo pipefail

check() {
  local label="$1"
  local command="$2"
  if command -v "$command" >/dev/null 2>&1; then
    printf "ok   %s: %s\n" "$label" "$(command -v "$command")"
  else
    printf "miss %s: not found\n" "$label"
  fi
}

check "Claude Code" "claude"
check "Node.js" "node"
check "npm" "npm"
check "Python" "python3"
check "uv" "uv"
check "Graphify" "graphify"
check "ccusage" "ccusage"

if [[ -d "/Applications/Obsidian.app" ]]; then
  printf "ok   Obsidian: /Applications/Obsidian.app\n"
else
  printf "miss Obsidian: app not found in /Applications\n"
fi

if [[ -f "${HOME}/.claude/settings.json" ]]; then
  printf "ok   Claude settings: %s\n" "${HOME}/.claude/settings.json"
else
  printf "miss Claude settings: %s\n" "${HOME}/.claude/settings.json"
fi

