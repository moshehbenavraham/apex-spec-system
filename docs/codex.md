# Codex CLI Setup

Setup instructions for using the Apex Spec System with OpenAI Codex CLI.

## Overview

Codex CLI supports two integration points:

1. **AGENTS.md** -- Project-level instruction file read automatically from the repo root
2. **Skills** -- Reusable command definitions in `.agents/skills/` that appear as `/commands`

The build system generates both from the canonical command sources.

## Quick Start

```bash
# 1. Clone the Apex Spec System
git clone <repo-url> apex-spec
cd apex-spec

# 2. Build all targets
make build

# 3. Copy artifacts to your project
cp dist/codex/AGENTS.md /path/to/your-project/
cp -r dist/codex/.agents /path/to/your-project/

# 4. Run Codex CLI in your project
cd /path/to/your-project
codex
```

Codex CLI will automatically read `AGENTS.md` and discover all 14 skills.

## What Gets Generated

### AGENTS.md (Root Instruction File)

Placed at your project root. Contains:
- Core philosophy and 3-stage workflow
- Command reference table (all 14 commands)
- Directory structure, session scope rules, task format
- Scripts reference and troubleshooting

Size: ~3.7 KB (well under the 32 KB limit).

### Skills (`.agents/skills/`)

One skill per command, each containing:

```
.agents/skills/
  initspec/
    SKILL.md        # Command instructions (YAML frontmatter + markdown)
    openai.yaml     # Codex metadata (display_name, description, policy)
    scripts/        # Bash utilities (analyze-project.sh, check-prereqs.sh, common.sh)
  createprd/
    SKILL.md
    openai.yaml
    scripts/
  ... (14 total)
```

**SKILL.md** uses YAML frontmatter compatible with Codex CLI:
```yaml
---
name: initspec
description: Initialize the Apex Spec System in the current project
---
```

**openai.yaml** controls Codex behavior:
```yaml
interface:
  display_name: "/initspec"
  short_description: "Initialize the Apex Spec System in the current project"
policy:
  allow_implicit_invocation: false
```

All skills set `allow_implicit_invocation: false` -- they only activate when explicitly invoked.

## Workflow

Once installed, use the spec system workflow in Codex CLI:

1. `/initspec` -- Set up `.spec_system/` in your project
2. `/createprd` -- Generate PRD from requirements
3. `/phasebuild` -- Create phase structure
4. `/nextsession` -- Get next session recommendation
5. `/sessionspec` -- Create formal specification
6. `/tasks` -- Generate task checklist
7. `/implement` -- AI-led implementation
8. `/validate` -- Verify completeness
9. `/updateprd` -- Mark session complete, loop back to step 4

## Updating

To pick up new command versions:

```bash
cd apex-spec
git pull
make build
cp dist/codex/AGENTS.md /path/to/your-project/
cp -r dist/codex/.agents /path/to/your-project/
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Skills not discovered | Verify `.agents/skills/` exists in project root |
| AGENTS.md not read | Verify `AGENTS.md` exists in project root |
| Stale commands | Re-run `make build` and copy outputs |
| Scripts fail | Ensure `bash`, `sed`, `awk` are available |
