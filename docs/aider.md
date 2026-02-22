# Aider Setup

Use the Apex Spec System with [Aider](https://aider.chat/) by loading `AGENTS.md` as read-only context.

## Quick Start

```bash
# Option 1: CLI flag
aider --read AGENTS.md

# Option 2: In-session command
/read AGENTS.md
```

## Persistent Configuration

Add to `.aider.conf.yml` in your project root:

```yaml
read: AGENTS.md
```

Or load multiple files:

```yaml
read:
  - AGENTS.md
  - .spec_system/CONVENTIONS.md
  - .spec_system/CONSIDERATIONS.md
```

## How It Works

- `AGENTS.md` is loaded as **read-only context** (Aider will not edit it)
- Read-only files benefit from **prompt caching** -- essentially free after first load
- The file contains the full 14-command workflow reference, directory structure, and session scope rules
- No special file generation is needed for Aider

## MCP Tools

If you have Node.js installed, you can also use the MCP server for structured project analysis:

```bash
# Build the MCP server
cd mcp-server && npm install && npx tsc

# Configure in .aider.conf.yml (if Aider adds MCP support)
# Otherwise, use the scripts directly:
bash scripts/analyze-project.sh --json
bash scripts/check-prereqs.sh --json --env
```

## Workflow

1. Start Aider with context: `aider --read AGENTS.md`
2. Ask Aider to run spec system commands (e.g., "run /nextsession")
3. Aider will follow the workflow guidance from AGENTS.md
4. Use scripts directly for project analysis when needed
