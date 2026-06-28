#!/usr/bin/env bash
set -euo pipefail

if command -v graphify >/dev/null 2>&1; then
  graphify --help >/dev/null 2>&1 || true
fi

