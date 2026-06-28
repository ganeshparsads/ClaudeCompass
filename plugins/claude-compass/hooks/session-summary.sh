#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="${CLAUDE_COMPASS_VAULT:-${HOME}/Documents/ClaudeCompassVault}"
SESSION_DIR="${VAULT_DIR}/ClaudeCompass/Sessions"
mkdir -p "${SESSION_DIR}"

STAMP="$(date +%Y%m%d-%H%M%S)"
cat > "${SESSION_DIR}/${STAMP}.md" <<EOF
# Claude Session ${STAMP}

ClaudeCompass hook placeholder.

Future versions will receive session metadata from Claude Code hooks and write a concise summary here.
EOF

