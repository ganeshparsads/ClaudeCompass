#!/usr/bin/env bash
set -euo pipefail

COMPASS_HOME="${HOME}/.claude/claude-compass"
BACKUP_DIR="${COMPASS_HOME}/backups/$(date +%Y%m%d-%H%M%S)"
VAULT_DIR="${CLAUDE_COMPASS_VAULT:-${HOME}/Documents/ClaudeCompassVault}"

log() {
  printf '\033[1;34m[ClaudeCompass]\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33m[ClaudeCompass]\033[0m %s\n' "$*"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

install_homebrew_if_needed() {
  if has brew; then
    log "Homebrew found."
    return
  fi

  warn "Homebrew is missing. Installing Homebrew will ask for confirmation and may require your macOS password."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_package_managers() {
  install_homebrew_if_needed

  if ! has node; then
    log "Installing Node.js."
    brew install node
  fi

  if ! has python3; then
    log "Installing Python."
    brew install python
  fi

  if ! has uv; then
    log "Installing uv."
    brew install uv
  fi
}

install_obsidian() {
  if [[ -d "/Applications/Obsidian.app" ]]; then
    log "Obsidian found."
    return
  fi

  log "Installing Obsidian."
  brew install --cask obsidian
}

install_graphify() {
  if has graphify; then
    log "Graphify found."
    return
  fi

  if has uvx; then
    log "Installing Graphify with uv tool."
    uv tool install graphify || uvx graphify --help >/dev/null
  elif has pipx; then
    log "Installing Graphify with pipx."
    pipx install graphify
  else
    log "Installing pipx and Graphify."
    brew install pipx
    pipx ensurepath
    pipx install graphify
  fi
}

install_token_monitor() {
  if has ccusage; then
    log "ccusage found."
    return
  fi

  log "Installing ccusage globally."
  npm install -g ccusage
}

write_compass_files() {
  mkdir -p "${COMPASS_HOME}" "${BACKUP_DIR}" "${VAULT_DIR}/ClaudeCompass"
  cp "$(dirname "$0")/statusline.sh" "${COMPASS_HOME}/statusline.sh"
  chmod +x "${COMPASS_HOME}/statusline.sh"

  cat > "${VAULT_DIR}/ClaudeCompass/README.md" <<EOF
# ClaudeCompass Vault

This vault folder is used by ClaudeCompass for session summaries, project decisions, and durable notes.

Created: $(date)
EOF
}

merge_claude_settings() {
  local settings="${HOME}/.claude/settings.json"
  local template
  template="$(cd "$(dirname "$0")/.." && pwd)/default-user-settings.json"

  mkdir -p "${HOME}/.claude" "${BACKUP_DIR}"

  if [[ -f "${settings}" ]]; then
    cp "${settings}" "${BACKUP_DIR}/settings.json"
  fi

  python3 - "$settings" "$template" <<'PY'
import json
import pathlib
import sys

settings_path = pathlib.Path(sys.argv[1])
template_path = pathlib.Path(sys.argv[2])

existing = {}
if settings_path.exists() and settings_path.read_text().strip():
    existing = json.loads(settings_path.read_text())

template = json.loads(template_path.read_text())

def merge(base, incoming):
    for key, value in incoming.items():
        if isinstance(value, dict) and isinstance(base.get(key), dict):
            merge(base[key], value)
        elif isinstance(value, list) and isinstance(base.get(key), list):
            seen = set(base[key])
            base[key].extend(item for item in value if item not in seen)
        else:
            base.setdefault(key, value)
    return base

merged = merge(existing, template)
settings_path.write_text(json.dumps(merged, indent=2) + "\n")
PY

  log "Claude settings merged. Backup: ${BACKUP_DIR}"
}

configure_graphify() {
  if has graphify; then
    log "Running Graphify Claude installer if available."
    graphify claude install || graphify install || warn "Graphify installed, but automatic Claude configuration did not complete."
  fi
}

print_next_steps() {
  cat <<EOF

ClaudeCompass installed.

What is automatic:
- Graphify install/config attempt
- Obsidian app install
- Claude Code statusline token monitor
- Claude settings merge with backup
- Vault folder at: ${VAULT_DIR}

What may still require user clicks:
- Obsidian Local REST API plugin enablement and API key
- macOS privacy/security prompts requested by Obsidian, Terminal, or Claude Code
- Claude Code plugin trust/install prompts

Run:
  claude
  /doctor
  /tokens

EOF
}

main() {
  log "Starting macOS bootstrap."
  install_package_managers
  install_obsidian
  install_graphify
  install_token_monitor
  write_compass_files
  merge_claude_settings
  configure_graphify
  print_next_steps
}

main "$@"
