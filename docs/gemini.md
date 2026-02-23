# Gemini CLI Setup

Setup instructions for using the Apex Spec System with Gemini CLI.

## Overview

Gemini CLI supports three integration points:

1. **AGENTS.md** -- Project-level instruction file read automatically from the repo root
2. **Commands** -- TOML command definitions in `.gemini/commands/` invoked as `/commands`
3. **Skills** -- Reusable skill definitions in `.gemini/skills/` for persistent context

The build system generates all three from the canonical command sources.

Optionally, the system also generates a **Gemini Extension** manifest (`gemini-extension.json` + `GEMINI.md`) for packaging as a distributable extension.

## Quick Start

```bash
# 1. Clone the Apex Spec System
git clone <repo-url> apex-spec
cd apex-spec

# 2. Build all targets
make build

# 3. Copy artifacts to your project
cp dist/gemini/AGENTS.md /path/to/your-project/
cp -r dist/gemini/.gemini /path/to/your-project/

# 4. Run Gemini CLI in your project
cd /path/to/your-project
gemini
```

Gemini CLI will automatically read `AGENTS.md` and discover all 12 commands.

## What Gets Generated

### AGENTS.md (Root Instruction File)

Placed at your project root. Contains:
- Core philosophy and 3-stage workflow
- Command reference table (all 12 commands)
- Directory structure, session scope rules, task format
- Scripts reference and troubleshooting

Size: ~3.7 KB (well under the 32 KB limit).

### Commands (`.gemini/commands/`)

One TOML file per command:

```
.gemini/commands/
  initspec.toml
  createprd.toml
  plansession.toml
  implement.toml
  validate.toml
  updateprd.toml
  audit.toml
  pipeline.toml
  infra.toml
  documents.toml
  carryforward.toml
  phasebuild.toml
```

Each TOML file uses the Gemini CLI command format:
```toml
description = "Initialize the Apex Spec System in the current project"
prompt = """
# /initspec Command

Set up the complete `.spec_system/` directory structure...
"""
```

All 12 commands are flat files (no nested directories).

### Skill (`.gemini/skills/spec-workflow/`)

Persistent workflow context with restricted tool access:

```
.gemini/skills/spec-workflow/
  SKILL.md          # Skill definition with allowed-tools
  references/
    workflow.md     # Detailed command workflows
```

The skill includes an `allowed-tools` field restricting to safe file operations:
```yaml
allowed-tools:
  - Bash
  - ReadFile
  - WriteFile
  - ReadManyFiles
  - ListDir
```

### Gemini Extension (Optional)

For distributing as a Gemini extension:

- `gemini-extension.json` -- Extension manifest with name, version, description
- `GEMINI.md` -- Single context file combining skill content and command reference

Install locally with:
```bash
gemini extensions install dist/gemini/
```

## Workflow

Once installed, use the spec system workflow in Gemini CLI:

1. `/initspec` -- Set up `.spec_system/` in your project
2. `/createprd` -- Generate PRD from requirements
3. `/phasebuild` -- Create phase structure
4. `/plansession` -- Analyze, create spec and task checklist
5. `/implement` -- AI-led implementation
6. `/validate` -- Verify completeness
7. `/updateprd` -- Mark session complete, loop back to step 4

## Updating

To pick up new command versions:

```bash
cd apex-spec
git pull
make build
cp dist/gemini/AGENTS.md /path/to/your-project/
cp -r dist/gemini/.gemini /path/to/your-project/
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Commands not found | Verify `.gemini/commands/` exists in project root |
| AGENTS.md not read | Verify `AGENTS.md` exists in project root |
| TOML parse errors | Check for unescaped `"""` in command content |
| Skill not loaded | Verify `.gemini/skills/spec-workflow/SKILL.md` exists |
| Extension install fails | Run `gemini extensions install <path>` with full path |
| Stale commands | Re-run `make build` and copy outputs |
| Scripts fail | Ensure `bash`, `sed`, `awk` are available |
