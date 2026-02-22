# Apex Spec System

**Version: 1.0.1-beta**

A specification-driven workflow system for AI-assisted development. Works with any AI coding tool that supports AGENTS.md, rules files, or MCP.

**Philosophy**: `1 session = 1 spec = 2-4 hours (12-25 tasks) = safe context window`

## Supported Tools

| Tool | Integration | Setup Guide |
|------|------------|-------------|
| **Codex CLI** | AGENTS.md + skills | [docs/codex.md](docs/codex.md) |
| **Cursor** | Commands + rules | [docs/cursor.md](docs/cursor.md) |
| **Gemini CLI** | TOML commands + extension | [docs/gemini.md](docs/gemini.md) |
| **GitHub Copilot** | Instructions files | [docs/COMPATIBILITY-MATRIX.md](docs/COMPATIBILITY-MATRIX.md) |
| **Cline** | Rules files | [docs/COMPATIBILITY-MATRIX.md](docs/COMPATIBILITY-MATRIX.md) |
| **Windsurf** | Cascade rules | [docs/COMPATIBILITY-MATRIX.md](docs/COMPATIBILITY-MATRIX.md) |
| **Antigravity** | Skills + GEMINI.md | [docs/COMPATIBILITY-MATRIX.md](docs/COMPATIBILITY-MATRIX.md) |
| **Amazon Q** | Rules files | [docs/COMPATIBILITY-MATRIX.md](docs/COMPATIBILITY-MATRIX.md) |
| **Goose** | .goosehints | [docs/COMPATIBILITY-MATRIX.md](docs/COMPATIBILITY-MATRIX.md) |
| **Kiro** | Steering files | [docs/COMPATIBILITY-MATRIX.md](docs/COMPATIBILITY-MATRIX.md) |
| **Aider** | --read flag + MCP | [docs/aider.md](docs/aider.md) |
| **MCP Clients** | MCP server (5 tools) | [docs/mcp.md](docs/mcp.md) |

## Architecture

```
 Canonical Sources              Build Pipeline              Per-Tool Outputs
+------------------+                                  +------------------------+
| commands/*.md    |----+                             | dist/codex/            |
| (14 commands,    |    |                             |   .agents/skills/      |
|  YAML + markdown)|    |    +------------------+    +------------------------+
+------------------+    +--->| build/           |    | dist/cursor/           |
                        |    | generate.sh      |--->|   .cursor/commands/    |
+------------------+    |    | (pure bash,      |    +------------------------+
| skills/          |----+    |  no dependencies)|    | dist/gemini/           |
|   spec-workflow/ |    |    +------------------+    |   .gemini/commands/    |
|   SKILL.md       |    |             |              +------------------------+
+------------------+    |             v              | dist/copilot/          |
                        |    +------------------+    | dist/cline/            |
+------------------+    |    | AGENTS.md        |    | dist/windsurf/         |
| scripts/         |----+    | (root, <32KB)    |    | dist/antigravity/      |
|   analyze-       |         +------------------+    | dist/amazonq/          |
|   project.sh     |                                 | dist/goose/            |
|   check-         |         +------------------+    | dist/kiro/             |
|   prereqs.sh     |-------->| mcp-server/      |    +------------------------+
+------------------+         | (TypeScript,     |    | dist/mcp/              |
                             |  5 tools, stdio) |    |   cursor.json          |
                             +------------------+    |   vscode.json          |
                                                     |   cline.json ...       |
                                                     +------------------------+
```

## Quick Start

### Option A: Universal Installer (recommended)

```bash
git clone https://github.com/ai-with-apex/apex-spec-system.git
cd apex-spec-system
bash install.sh              # Auto-detects your tools
```

The installer detects which AI tools you have and sets up the right configuration. Use `--tool <name>` to target a specific tool, or `--dry-run` to preview.

### Option B: Manual Build

```bash
git clone https://github.com/ai-with-apex/apex-spec-system.git
cd apex-spec-system
make build                   # Generate all outputs in dist/
```

Then follow the [per-tool setup guide](#supported-tools) for your AI coding tool.

### Start the Workflow

Once installed, initialize in your project and follow the workflow:

```
/initspec        # Initialize spec system
/createprd       # Generate PRD from requirements
/phasebuild      # Set up phases and sessions
/nextsession     # Get next session recommendation
/sessionspec     # Create formal specification
/tasks           # Generate task checklist
/implement       # AI-led implementation
/validate        # Verify completeness
/updateprd       # Mark complete, sync docs
```

## Requirements

| Dependency | Required | Install |
|------------|----------|---------|
| **jq** | Yes | `apt install jq` or `brew install jq` |
| **git** | Optional | Usually pre-installed |
| **bash** | Yes | Pre-installed on macOS/Linux |

Verify with: `bash scripts/check-prereqs.sh --env`

## Commands (14 total)

| Command | Purpose |
|---------|---------|
| `/initspec` | Initialize spec system in current project |
| `/createprd` | Generate master PRD from requirements document |
| `/nextsession` | Analyze project and recommend next session |
| `/sessionspec` | Create formal technical specification |
| `/tasks` | Generate 12-25 task checklist |
| `/implement` | AI-led task-by-task implementation |
| `/validate` | Verify session completeness |
| `/updateprd` | Mark session complete, sync documentation |
| `/audit` | Local dev tooling (formatter, linter, types, tests, hooks) |
| `/pipeline` | CI/CD workflows (quality, build, security, integration, ops) |
| `/infra` | Production infrastructure (health, security, backup, deploy) |
| `/documents` | Audit and update project documentation |
| `/carryforward` | Extract lessons learned between phases |
| `/phasebuild` | Create structure for new phase |

## Repository Structure

```
apex-spec-system/
  AGENTS.md                 # Generated -- committed for tools that read it natively
  Makefile                  # Build entry point (build, validate, clean)
  install.sh                # Universal installer (auto-detects tools)
  README.md
  build/
    generate.sh             # Build script (pure bash, no dependencies)
    templates/              # Output templates
  commands/                 # Canonical command sources (14 files, YAML + markdown)
  docs/
    CANONICAL-FORMAT.md     # Command file format specification
    COMPATIBILITY-MATRIX.md # Feature support across all tools
    GUIDANCE.md             # Usage guidance and workflow modes
    WALKTHROUGH.md          # Production walkthrough (79+ sessions, 16 phases)
    aider.md                # Aider integration guide
    codex.md                # Codex CLI setup
    cursor.md               # Cursor setup
    gemini.md               # Gemini CLI setup
    mcp.md                  # MCP client setup
  mcp-server/               # TypeScript MCP server (5 tools, stdio transport)
  scripts/                  # Bash utilities (analyze-project, check-prereqs)
  skills/
    spec-workflow/           # Auto-activating workflow skill
  test/
    validate-install.sh     # 125-check validation suite
  dist/                     # Generated (gitignored)
    codex/ cursor/ gemini/ copilot/ cline/ windsurf/
    antigravity/ amazonq/ goose/ kiro/ mcp/ universal/
```

## Building

```bash
make build    # Generate all outputs in dist/ and AGENTS.md at root
make clean    # Remove dist/
```

The build script is pure bash with no external dependencies beyond standard Unix tools.

## Session Scope

- Maximum 25 tasks per session
- Maximum 4 hours estimated time
- Single clear objective
- Ideal: 12-25 tasks (sweet spot: 20)

## ASCII Encoding (Non-Negotiable)

All files must use ASCII-only characters (0-127). No Unicode, emoji, or smart quotes.

## Video Tutorial

[Watch on YouTube](https://youtu.be/iY6ySesmOCg) - Installation and workflow walkthrough

## Documentation

- [Usage Guidance](docs/GUIDANCE.md) - When to use, workflow modes, team patterns
- [Production Walkthrough](docs/WALKTHROUGH.md) - Real-world example (79+ sessions, 16 phases)
- [Compatibility Matrix](docs/COMPATIBILITY-MATRIX.md) - Feature support across all tools
- [Canonical Format](docs/CANONICAL-FORMAT.md) - Command and skill file format
- [Contributing](CONTRIBUTING.md) - How to add support for new tools

## License

MIT License - Use freely in your projects.
