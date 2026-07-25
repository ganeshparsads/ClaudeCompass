---
description: Use CodeGraph to answer structural questions about a codebase and keep the code index synced, instead of broad grep/read crawling.
---

# ClaudeCompass CodeGraph

Use this skill when the user asks about codebase structure, call paths, blast radius, "where is X used", refactor impact, or when you would otherwise grep/read many files to understand code.

CodeGraph (`@colbymchenry/codegraph`) is a local code knowledge graph over 20+ languages, stored in SQLite. It exposes an MCP tool `codegraph_explore` and a CLI. ClaudeCompass installs it and keeps the per-project index synced through a SessionStart hook.

## Preferred Flow

1. **Prefer `codegraph_explore` (MCP) or `codegraph explore <query>` before broad source search.** One call returns the relevant symbols' verbatim source grouped by file, plus call paths and a blast-radius summary.
2. Only fall back to grep/read when CodeGraph has no answer or the graph is not initialized.

## Ensuring the Index Exists and Stays Current

- Check availability: `codegraph status`
- Initialize a project once: `codegraph init`
- Incremental update: `codegraph sync`

The graph auto-updates via native file watchers as code changes, and the ClaudeCompass SessionStart hook runs `codegraph sync` (or `codegraph init` on first use) so the index is fresh each session.

## If Missing

If the `codegraph` command is not found, tell the user to run `/claude-compass:setup`, or install directly:

```bash
npm i -g @colbymchenry/codegraph
codegraph install   # wires the MCP server into Claude Code
codegraph init      # build the graph for the current project
```
