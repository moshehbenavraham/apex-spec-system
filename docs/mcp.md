# MCP Client Setup

Setup instructions for using the Apex Spec System as an MCP server with any MCP-capable client.

## Overview

The Apex Spec System MCP server exposes 5 tools over stdio transport:

| Tool | Description |
|------|-------------|
| `analyze_project` | Get project state, phase info, session candidates (wraps `analyze-project.sh --json`) |
| `check_prereqs` | Validate prerequisites for current session (wraps `check-prereqs.sh --json`) |
| `get_state` | Read `.spec_system/state.json` |
| `update_state` | Update specific state fields (current_phase, current_session, completed_sessions, phase_status) |
| `list_commands` | Return all 14 command names and descriptions |

## Prerequisites

- Node.js >= 18.0.0
- `jq` (required by the bash scripts)

## Quick Start

```bash
# 1. Clone the repository
git clone <repo-url> apex-spec
cd apex-spec

# 2. Build everything (including MCP server)
make build

# 3. Copy the appropriate config snippet for your tool
#    Config snippets are generated in dist/mcp/
ls dist/mcp/
```

## What Gets Generated

After running `make build`, the `dist/mcp/` directory contains config snippets for each supported tool:

| File | Target Tool | Config Location |
|------|-------------|-----------------|
| `cursor.json` | Cursor IDE | `.cursor/mcp.json` |
| `vscode.json` | VS Code / Copilot | `.vscode/mcp.json` |
| `cline.json` | Cline | `cline_mcp_settings.json` |
| `windsurf.json` | Windsurf | `mcp_config.json` |
| `codex.toml` | Codex CLI | `.codex/config.toml` |
| `gemini.json` | Gemini CLI | `settings.json` |

## Per-Tool Setup

### Cursor IDE

Copy `dist/mcp/cursor.json` to your project's `.cursor/mcp.json`:

```bash
mkdir -p .cursor
cp dist/mcp/cursor.json .cursor/mcp.json
```

Restart Cursor. The 5 tools will appear in the MCP tools panel.

### VS Code / GitHub Copilot

Copy `dist/mcp/vscode.json` to your project's `.vscode/mcp.json`:

```bash
mkdir -p .vscode
cp dist/mcp/vscode.json .vscode/mcp.json
```

### Cline

Merge `dist/mcp/cline.json` into your `cline_mcp_settings.json`.

### Windsurf

Merge `dist/mcp/windsurf.json` into your `mcp_config.json`.

### Codex CLI

Append the contents of `dist/mcp/codex.toml` to your `.codex/config.toml`:

```bash
mkdir -p .codex
cat dist/mcp/codex.toml >> .codex/config.toml
```

### Gemini CLI

Merge `dist/mcp/gemini.json` into your Gemini settings.

## Tool Details

### analyze_project

Returns project state as JSON. Equivalent to running `scripts/analyze-project.sh --json`.

**Parameters:**
- `project_dir` (optional): Absolute path to the project directory. Defaults to the server's working directory.

**Returns:** JSON with `project`, `current_phase`, `current_session`, `phases`, `completed_sessions`, `candidate_sessions`.

### check_prereqs

Validates environment and prerequisites. Equivalent to running `scripts/check-prereqs.sh --json`.

**Parameters:**
- `project_dir` (optional): Absolute path to the project directory.
- `tools` (optional): Comma-separated tool names to check (e.g., `"node,npm,docker"`).
- `files` (optional): Comma-separated file paths to check.
- `prereqs` (optional): Comma-separated prerequisite session IDs.
- `env_only` (optional): If true, only check environment (spec system, jq, git).

**Returns:** JSON with `overall` (pass/fail), `environment`, `tools`, `sessions`, `files`, `issues`.

### get_state

Reads and returns the full `.spec_system/state.json` content.

**Parameters:**
- `project_dir` (optional): Absolute path to the project directory.

**Returns:** Full state JSON object.

### update_state

Merges updates into `.spec_system/state.json`.

**Parameters:**
- `project_dir` (optional): Absolute path to the project directory.
- `current_phase` (optional): Set the current phase number.
- `current_session` (optional): Set the current session ID, or null to clear.
- `add_completed_sessions` (optional): Array of session IDs to append.
- `phase_status` (optional): Object with `phase` (string) and `status` ("not_started" | "in_progress" | "completed").

**Returns:** Updated state JSON.

### list_commands

Lists all 14 canonical commands.

**Parameters:** None.

**Returns:** JSON with `commands` array (each with `name` and `description`) and `count`.

## Architecture

```
mcp-server/
  src/index.ts    -- MCP server implementation (stdio transport)
  dist/index.js   -- Compiled output
  package.json    -- Dependencies (@modelcontextprotocol/sdk)
  tsconfig.json   -- TypeScript config

scripts/
  analyze-project.sh   -- Wrapped by analyze_project tool
  check-prereqs.sh     -- Wrapped by check_prereqs tool
  common.sh            -- Shared utilities (sourced by scripts)
```

The MCP server wraps the existing bash scripts and file operations. No workflow logic is duplicated -- the server delegates to the same scripts used by all other tool integrations.

## Troubleshooting

**Server doesn't start:**
- Verify Node.js >= 18: `node --version`
- Verify the build completed: `ls mcp-server/dist/index.js`
- Run manually to check for errors: `node mcp-server/dist/index.js`

**Tools return errors about .spec_system:**
- The project must be initialized with `/initspec` first
- Verify `.spec_system/state.json` exists in the target project
- Pass `project_dir` parameter if the MCP server runs from a different directory

**jq not found:**
- Install jq: `apt install jq` (Debian/Ubuntu) or `brew install jq` (macOS)
- The `analyze_project` and `check_prereqs` tools require jq
