# Compatibility Matrix

Apex Spec System feature support across AI coding tools.

## Feature Matrix

| Feature | Codex CLI | Gemini CLI | Cursor | VS Code / Copilot | Cline | Windsurf | Antigravity | GitHub Copilot | Amazon Q | Goose | Kiro | Aider |
|---------|-----------|------------|--------|-------------------|-------|----------|-------------|----------------|----------|-------|------|-------|
| **Commands (14)** | Skills (SKILL.md + openai.yaml) | TOML commands (.gemini/commands/) | Markdown commands (.cursor/commands/) | Via MCP only | Via AGENTS.md + MCP | Via rules (summaries) + MCP | Via skill + MCP | Via instructions + AGENTS.md | Via rules + AGENTS.md | Via .goosehints + AGENTS.md | Via steering + AGENTS.md | Via --read AGENTS.md |
| **Skill / Rules** | Skills directory (.agents/skills/) | SKILL.md + references (.gemini/skills/) | MDC rule (.cursor/rules/) | Via MCP only | .clinerules/ (YAML frontmatter) | .windsurf/rules/ (3 stage files) | .agent/skills/ | .github/instructions/ | .amazonq/rules/ | .goosehints | .kiro/steering/ | Read-only context |
| **AGENTS.md** | Native (project root) | Native (project root) | Native (project root) | Native (project root) | Auto-detected (project root) | Native (project root) | Native (project root) | Native (project root) | Native (project root) | Native (CONTEXT_FILE_NAMES) | Native (project root) | Via --read flag |
| **MCP Tools (5)** | config.toml fragment | settings.json fragment | .cursor/mcp.json | .vscode/mcp.json | cline_mcp_settings.json | mcp_config.json | Via Gemini MCP config | .vscode/mcp.json | N/A | N/A | N/A | N/A |
| **Scripts** | Bundled per skill | Via MCP or direct | Via MCP or direct | Via MCP | Via MCP or direct | Via MCP or direct | Via MCP or direct | Via MCP or direct | Direct | Direct | Direct | Direct |
| **Extension/Plugin** | N/A | gemini-extension.json | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## MCP Tools

All MCP-capable clients can access these 5 tools:

| Tool | Description | Output |
|------|-------------|--------|
| `analyze_project` | Project state, phase info, session candidates | JSON |
| `check_prereqs` | Validate prerequisites for current session | JSON |
| `get_state` | Read .spec_system/state.json | JSON |
| `update_state` | Update specific state fields | JSON |
| `list_commands` | Return available command names and descriptions | JSON |

## Command Access by Tool

| Command | Codex CLI | Gemini CLI | Cursor | Cline | Windsurf | Antigravity | Copilot | Amazon Q | Goose | Kiro | Aider |
|---------|-----------|------------|--------|-------|----------|-------------|---------|----------|-------|------|-------|
| `/initspec` | Skill invocation | `/initspec` TOML | `/@initspec` cmd | Via AGENTS.md | Plan rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/createprd` | Skill invocation | `/createprd` TOML | `/@createprd` cmd | Via AGENTS.md | Plan rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/phasebuild` | Skill invocation | `/phasebuild` TOML | `/@phasebuild` cmd | Via AGENTS.md | Plan rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/nextsession` | Skill invocation | `/nextsession` TOML | `/@nextsession` cmd | Via AGENTS.md | Build rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/sessionspec` | Skill invocation | `/sessionspec` TOML | `/@sessionspec` cmd | Via AGENTS.md | Build rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/tasks` | Skill invocation | `/tasks` TOML | `/@tasks` cmd | Via AGENTS.md | Build rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/implement` | Skill invocation | `/implement` TOML | `/@implement` cmd | Via AGENTS.md | Build rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/validate` | Skill invocation | `/validate` TOML | `/@validate` cmd | Via AGENTS.md | Build rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/updateprd` | Skill invocation | `/updateprd` TOML | `/@updateprd` cmd | Via AGENTS.md | Build rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/audit` | Skill invocation | `/audit` TOML | `/@audit` cmd | Via AGENTS.md | Harden rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/pipeline` | Skill invocation | `/pipeline` TOML | `/@pipeline` cmd | Via AGENTS.md | Harden rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/infra` | Skill invocation | `/infra` TOML | `/@infra` cmd | Via AGENTS.md | Harden rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/documents` | Skill invocation | `/documents` TOML | `/@documents` cmd | Via AGENTS.md | Harden rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |
| `/carryforward` | Skill invocation | `/carryforward` TOML | `/@carryforward` cmd | Via AGENTS.md | Harden rule | Via skill | Via instructions | Via rules | Via hints | Via steering | Via context |

## Requirements

| Requirement | Codex CLI | Gemini CLI | Cursor | VS Code / Copilot | Cline | Windsurf | Antigravity | Copilot | Amazon Q | Goose | Kiro | Aider |
|-------------|-----------|------------|--------|-------------------|-------|----------|-------------|---------|----------|-------|------|-------|
| Node.js 18+ | For MCP only | For MCP only | For MCP only | For MCP only | For MCP only | For MCP only | For MCP only | For MCP only | No | No | No | No |
| Bash | Required (scripts) | Required (scripts) | Required (scripts) | For MCP only | For MCP only | For MCP only | Required (scripts) | For MCP only | For scripts | For scripts | For scripts | For scripts |
| jq | Recommended | Recommended | Recommended | Recommended | Recommended | Recommended | Recommended | Recommended | Recommended | Recommended | Recommended | Recommended |
| Tool CLI | `codex` | `gemini` | Cursor IDE | VS Code | VS Code + Cline ext | Windsurf IDE | Antigravity IDE | VS Code + Copilot | VS Code + Q ext or `q` CLI | `goose` CLI | Kiro IDE or `kiro` CLI | `aider` CLI |

## Known Limitations

| Tool | Limitation | Workaround |
|------|-----------|------------|
| Codex CLI | AGENTS.md must be under 32KB | Current size is ~3.7KB, well within limit |
| Cursor | MCP limited to 40 tools per server | We expose exactly 5 tools |
| Gemini CLI | TOML multiline strings must escape certain chars | Build script handles escaping |
| VS Code / Copilot | No native command format | Use MCP tools + AGENTS.md for guidance |
| Windsurf | 12K char limit per rule file | Split into 3 rule files by stage (plan/build/harden) |
| Cline | No native command format | AGENTS.md auto-detected + MCP tools |
| Antigravity | Shares ~/.gemini/ path with Gemini CLI | Use project-level configs only |
| GitHub Copilot | Instructions limited to ~2 pages (repo-wide) | Full detail in instructions/ file (30K char limit) |
| Amazon Q | No MCP support | Use AGENTS.md + rules for guidance, scripts directly |
| Goose | .goosehints loaded every request (token cost) | Keep concise, use @AGENTS.md reference |
| Kiro | No MCP support currently | Use AGENTS.md + steering files |
| Aider | No native rules/commands format | Load AGENTS.md via --read flag or .aider.conf.yml |
| All tools | Scripts require bash | Windows users need WSL or Git Bash |

## Validation

Run the validation suite to verify your installation:

```bash
bash test/validate-install.sh
```

This checks:
- All expected files exist per tool (11 tools + MCP + universal)
- JSON/TOML syntax validity
- AGENTS.md size under 32KB
- Windsurf rules under 12K chars each
- Correct frontmatter presence/absence per tool format
- ASCII-only content
- MCP server health (if Node.js available)
