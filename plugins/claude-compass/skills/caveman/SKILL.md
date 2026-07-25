---
description: Enable Caveman output-token compression to make Claude's responses terser while preserving code, commands, and errors byte-for-byte.
---

# ClaudeCompass Caveman

Use this skill when the user asks to reduce output tokens, "talk like caveman", be more concise, cut costs, or wants brief commits/reviews. Caveman is an output-token compression skill (~65% reduction) that installs its own `/caveman` commands into Claude Code.

## Modes and Commands

- `/caveman [lite|full|ultra|wenyan]` — enable compression (defaults to `full`); say "normal mode" to disable.
- `/caveman-commit` — brief conventional commits.
- `/caveman-review` — one-line PR comments.
- `/caveman-stats` — token savings and cost analytics.
- `/caveman-compress <file>` — compress a memory/notes file for future sessions.

## Behavior

- Compression preserves code blocks, shell commands, file paths, and error text verbatim; it only strips filler prose.
- Pair with ClaudeCompass Headroom (input/context compression) for savings on both sides of the request.

## If Missing

If the `/caveman` commands are not available, tell the user to run `/claude-compass:setup`, or install directly:

```bash
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
```

The installer auto-detects Claude Code and registers the commands. Requires Node >= 18.
