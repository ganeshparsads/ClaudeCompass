#!/usr/bin/env bash
set -euo pipefail

if command -v ccusage >/dev/null 2>&1; then
  ccusage statusline 2>/dev/null || true
  exit 0
fi

if command -v npx >/dev/null 2>&1; then
  npx -y ccusage@latest statusline 2>/dev/null || true
  exit 0
fi

printf "ClaudeCompass: token monitor not installed"

