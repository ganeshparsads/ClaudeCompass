---
description: Remove ClaudeCompass local files safely while preserving user data unless explicitly asked.
---

# ClaudeCompass Uninstall

Use this skill when the user asks to remove ClaudeCompass.

## Behavior

- Remove `~/.claude/claude-compass`.
- Show the latest settings backup path.
- Do not delete the Obsidian vault unless the user explicitly asks.
- Do not uninstall Homebrew, Node, Python, or Obsidian unless the user explicitly asks.
