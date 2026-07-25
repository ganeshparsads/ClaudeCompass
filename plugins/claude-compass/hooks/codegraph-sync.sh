#!/usr/bin/env bash
set -euo pipefail

# Keep the CodeGraph index current for the active project on session start.
# Best-effort and non-blocking: never delay or fail a Claude Code session.

command -v codegraph >/dev/null 2>&1 || exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "${PROJECT_DIR}" 2>/dev/null || exit 0

# Sync if the graph already exists; otherwise build it. Run detached so the
# session is not blocked while indexing.
{ codegraph sync >/dev/null 2>&1 || codegraph init >/dev/null 2>&1; } &

exit 0
