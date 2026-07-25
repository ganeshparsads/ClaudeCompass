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

  log "Attempting Graphify install. This is optional and setup will continue if Graphify is unavailable."
  if has uvx; then
    uv tool install graphify 2>/dev/null || warn "uv could not install Graphify."
  elif has pipx; then
    pipx install graphify 2>/dev/null || warn "pipx could not install Graphify."
  else
    brew install pipx 2>/dev/null || warn "Could not install pipx."
    if has pipx; then
      pipx ensurepath 2>/dev/null || true
      pipx install graphify 2>/dev/null || warn "pipx could not install Graphify."
    fi
  fi

  if has graphify; then
    log "Graphify installed."
  else
    warn "Graphify is not available through the detected package managers. Skipping Graphify and continuing setup."
  fi
}

install_codegraph() {
  if has codegraph; then
    log "CodeGraph found."
  else
    log "Installing CodeGraph."
    npm install -g @colbymchenry/codegraph 2>/dev/null || warn "Could not install CodeGraph globally. Run: npm i -g @colbymchenry/codegraph"
  fi

  if has codegraph; then
    log "Wiring CodeGraph MCP server into Claude Code."
    codegraph install 2>/dev/null || warn "CodeGraph MCP wiring did not complete. Run: codegraph install"
  fi
}

install_caveman() {
  local marker="${COMPASS_HOME}/.caveman-installed"
  if [[ -f "${marker}" ]]; then
    log "Caveman already installed by ClaudeCompass."
    return
  fi

  log "Installing Caveman (output-token compression skill). Auto-detects Claude Code."
  if curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash; then
    mkdir -p "${COMPASS_HOME}"
    date > "${marker}"
    log "Caveman installed. Enable with /caveman."
  else
    warn "Caveman install did not complete. Run: curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash"
  fi
}

install_headroom() {
  if has headroom; then
    log "Headroom found."
  else
    log "Installing Headroom (input/context compression)."
    if has uv; then
      uv tool install --python 3.13 "headroom-ai[all]" 2>/dev/null || warn "uv could not install Headroom."
    elif has pipx; then
      pipx install "headroom-ai[all]" 2>/dev/null || warn "pipx could not install Headroom."
    elif has pip3; then
      pip3 install --user "headroom-ai[all]" 2>/dev/null || warn "pip could not install Headroom."
    else
      warn "No uv/pipx/pip found for Headroom. Run: uv tool install --python 3.13 \"headroom-ai[all]\""
    fi
  fi

  if has headroom; then
    log "Wiring Headroom MCP server into Claude Code."
    headroom mcp install 2>/dev/null || warn "Headroom MCP wiring did not complete. Run: headroom mcp install"
  fi
}

install_token_monitor() {
  if has ccusage; then
    log "ccusage found."
    return
  fi

  log "Installing ccusage."
  if npm install -g ccusage 2>/dev/null; then
    log "ccusage installed globally."
    return
  fi

  # Fall back to user-local prefix to avoid needing sudo.
  local npm_prefix="${HOME}/.npm-global"
  mkdir -p "${npm_prefix}"
  npm install -g ccusage --prefix "${npm_prefix}" 2>/dev/null || true

  if [[ -x "${npm_prefix}/bin/ccusage" ]]; then
    log "ccusage installed at ${npm_prefix}/bin/ccusage."
    warn "Add ${npm_prefix}/bin to your PATH to use ccusage from any terminal."
  else
    warn "ccusage install failed. Run: npm install -g ccusage (may need sudo or PATH config)."
  fi
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
  else
    warn "Graphify command not found. ClaudeCompass memory vault and token setup still completed."
  fi
}

print_next_steps() {
  cat <<EOF

ClaudeCompass installed.

What is automatic:
- Graphify install/config attempt when available
- CodeGraph install + MCP wiring + per-session index sync
- Caveman output-token compression skill
- Headroom input/context compression + MCP wiring
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
  /claude-compass:doctor
  /claude-compass:tokens

EOF
}

main() {
  log "Starting macOS bootstrap."
  install_package_managers
  install_obsidian
  install_graphify
  install_codegraph
  install_caveman
  install_headroom
  install_token_monitor
  write_compass_files
  merge_claude_settings
  configure_graphify
  print_next_steps
}

main "$@"
