---
description: Install or repair ClaudeCompass, including Graphify, Obsidian, token visibility, and Claude Code settings.
---

# ClaudeCompass Setup

Use this skill when the user asks to install, configure, bootstrap, or repair ClaudeCompass.

## Behavior

1. Detect the user's OS.
2. Run the matching bootstrap script from `bin/`.
3. Explain any remaining manual approvals clearly.
4. Run `bin/doctor.sh` after setup when possible.

## Commands

macOS:

```bash
plugins/claude-compass/bin/bootstrap-macos.sh
```

Windows:

```powershell
plugins\claude-compass\bin\bootstrap-windows.ps1
```
