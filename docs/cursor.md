# Cursor Setup

Setup instructions for using the Apex Spec System with Cursor IDE.

## Overview

Cursor supports two integration points:

1. **Commands** -- Markdown files in `.cursor/commands/` that appear as `/commands` in chat
2. **Rules** -- Markdown files in `.cursor/rules/` that provide persistent context to the AI

The build system generates both from the canonical command sources.

## Quick Start

```bash
# 1. Clone the Apex Spec System
git clone <repo-url> apex-spec
cd apex-spec

# 2. Build all targets
make build

# 3. Copy artifacts to your project
cp -r dist/cursor/.cursor /path/to/your-project/
cp dist/cursor/AGENTS.md /path/to/your-project/

# 4. Open your project in Cursor
```

All 12 commands will appear in Cursor's `/` command menu. The rule loads automatically.

## What Gets Generated

### Commands (`.cursor/commands/`)

One markdown file per command, with YAML frontmatter stripped (Cursor commands are plain markdown):

```
.cursor/commands/
  initspec.md
  createprd.md
  phasebuild.md
  plansession.md
  implement.md
  validate.md
  updateprd.md
  audit.md
  pipeline.md
  infra.md
  documents.md
  carryforward.md
```

Each file starts with `# /command-name` and contains the full command instructions.

### Rules (`.cursor/rules/`)

A single rule file with MDC frontmatter:

```
.cursor/rules/
  apex-spec.md
```

**Frontmatter:**
```yaml
---
description: "Activates for spec system, session workflow, implement session..."
alwaysApply: true
---
```

This rule provides persistent context about the spec workflow, directory structure, session scope, and task format. With `alwaysApply: true`, Cursor always has this context available.

### AGENTS.md

Also copied to `dist/cursor/` for projects that want both Cursor rules and the universal instruction file. Cursor reads `AGENTS.md` natively from the project root.

## Workflow

Once installed, use the spec system workflow in Cursor:

1. Type `/` in chat to see available commands
2. Select `/initspec` to set up `.spec_system/` in your project
3. Follow the workflow: `/plansession` -> `/implement` -> `/validate` -> `/updateprd`
4. Between phases: `/audit` -> `/pipeline` -> `/infra` -> `/carryforward` -> `/documents`

## Updating

To pick up new command versions:

```bash
cd apex-spec
git pull
make build
cp -r dist/cursor/.cursor /path/to/your-project/
cp dist/cursor/AGENTS.md /path/to/your-project/
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Commands not in `/` menu | Verify `.cursor/commands/` exists in project root |
| Rule not loading | Verify `.cursor/rules/apex-spec.md` has valid MDC frontmatter |
| Stale commands | Re-run `make build` and copy outputs |
| AGENTS.md not read | Verify `AGENTS.md` exists in project root |
