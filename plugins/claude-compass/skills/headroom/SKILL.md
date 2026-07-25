---
description: Use Headroom to compress large tool outputs, logs, files, and RAG chunks before they enter context, reducing input tokens while preserving accuracy.
---

# ClaudeCompass Headroom

Use this skill when the user asks to shrink large inputs, trim noisy tool output/logs, compress JSON, or reduce context/input token usage. Headroom (`headroom-ai`) compresses inputs before they reach the model (20% on coding tasks, 60-95% on JSON) and exposes an MCP server.

## Preferred Flow

1. **Use the MCP tools when connected:** `headroom_compress` (shrink a payload), `headroom_retrieve` (recover detail), `headroom_stats` (savings).
2. For a whole session, the user can wrap the agent: `headroom wrap claude`.
3. Proxy mode for zero code changes: `headroom proxy --port 8787`.

## Diagnostics

- `headroom doctor` — health check.
- `headroom perf` — performance metrics.
- `headroom dashboard` — live savings view.

Pair with ClaudeCompass Caveman (output compression) to save tokens on both request and response.

## If Missing

If the `headroom` command or MCP tools are not available, tell the user to run `/claude-compass:setup`, or install directly:

```bash
uv tool install --python 3.13 "headroom-ai[all]"
headroom mcp install   # wire the MCP server into Claude Code
```
