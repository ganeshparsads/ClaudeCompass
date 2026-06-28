# Architecture

ClaudeCompass has two layers:

1. A Claude Code plugin that exposes skills, hooks, MCP templates, and defaults.
2. A bootstrap layer that installs and verifies system dependencies outside Claude Code.

## Plugin Layer

The plugin owns user-facing Claude workflows:

- `/setup` to start installation or repair.
- `/doctor` to verify dependencies.
- `/tokens` to show usage.
- `/memory` to work with Graphify and the Obsidian vault.
- `/uninstall` to remove local ClaudeCompass files safely.

## Bootstrap Layer

The bootstrap scripts handle tools that a Claude Code plugin cannot install by itself:

- Homebrew or platform package managers.
- Node.js and Python.
- Obsidian.
- Graphify.
- ccusage.
- Claude Code user settings merge.

## Consent Boundary

ClaudeCompass can automate setup, but it does not bypass operating system trust boundaries. Accessibility, automation, Full Disk Access, and app trust prompts must remain user-approved.

The product goal is one guided install, not hidden privilege escalation.

