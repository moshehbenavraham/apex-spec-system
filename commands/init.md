---
name: init
description: Initialize the Apex Spec System in the current project
---

# /init Command

Initialize the Apex Spec System in the current project directory.

## Role & Mindset

You are a **senior engineer** who is obsessive about pristine code — zero errors, zero warnings, zero lint issues. You are known for **clean project scaffolding**, rigorous **structure discipline**, and treating implementation as a craft: methodical, patient, and uncompromising on quality.

## Your Task

Set up the complete spec system directory structure and initial files for a new or existing project. All spec system files are stored in the `.spec_system/` directory to keep the project root clean.

## Steps

### 1. Check Current State

First, check if the spec system is already initialized:
- Look for `.spec_system/state.json`
- Check for `.spec_system/PRD/` directory
- Check for `.spec_system/specs/` directory

If already initialized, ask the user if they want to reinitialize (this will reset state).

### 2. Gather Project Information

Ask the user for:
- **Project name**: Name of the project
- **Project description**: Brief description of what the project does
- **First phase name**: Name for Phase 00 (default: "Foundation")

### 3. Create Directory Structure

Create the following directories:

```bash
mkdir -p .spec_system/PRD/phase_00
mkdir -p .spec_system/specs
mkdir -p .spec_system/archive/backups
mkdir -p .spec_system/archive/sessions
mkdir -p .spec_system/archive/planning
mkdir -p .spec_system/archive/PRD
mkdir -p .spec_system/archive/phases
```

### 4. Create state.json

Create `.spec_system/state.json`:

```json
{
  "version": "2.0",
  "project_name": "[PROJECT_NAME]",
  "description": "[PROJECT_DESCRIPTION]",
  "current_phase": 0,
  "current_session": null,
  "phases": {
    "0": {
      "name": "[PHASE_NAME]",
      "status": "not_started",
      "session_count": 0
    }
  },
  "completed_sessions": [],
  "next_session_history": []
}
```

### 5. Create PRD Template

Create `.spec_system/PRD/PRD.md` with a starter template:

```markdown
# [PROJECT_NAME] - Product Requirements Document

## Overview

[PROJECT_DESCRIPTION]

## Goals

1. [Goal 1]
2. [Goal 2]
3. [Goal 3]

## Phases

| Phase | Name | Sessions | Status |
|-------|------|----------|--------|
| 00 | [PHASE_NAME] | TBD | Not Started |

## Phase 00: [PHASE_NAME]

### Objectives

1. [Objective 1]
2. [Objective 2]

### Sessions (To Be Defined)

Use `/nextsession` to get recommendations for sessions to implement.

## Technical Stack

- [Technology 1]
- [Technology 2]

## Success Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
```

### 6. Create Phase PRD

Create `.spec_system/PRD/phase_00/PRD_phase_00.md`:

```markdown
# Phase 00: [PHASE_NAME]

**Status**: Not Started
**Progress**: 0/0 sessions (0%)

## Overview

[Phase description - to be filled in]

## Progress Tracker

| Session | Name | Status | Validated |
|---------|------|--------|-----------|
| - | No sessions defined | - | - |

## Next Steps

Run `/nextsession` to get the first session recommendation.
```

### 7. Copy Scripts Locally (Optional)

Scripts can run from either location:
- **Plugin** (default): `${CLAUDE_PLUGIN_ROOT}/scripts/` - Always up-to-date with plugin updates
- **Local**: `.spec_system/scripts/` - Allows per-project customization, isolated from plugin updates

If local scripts exist, commands will use them automatically (local takes precedence).

Ask user: "Do you want to copy scripts locally for customization, or use them from the plugin (recommended)?"

If the user wants local scripts:

```bash
mkdir -p .spec_system/scripts
cp ${CLAUDE_PLUGIN_ROOT}/scripts/*.sh .spec_system/scripts/
chmod +x .spec_system/scripts/*.sh
```

**Note**: Local scripts won't receive plugin updates automatically. To update, delete `.spec_system/scripts/` and re-copy, or just remove it to fall back to plugin scripts.

### 8. Report Success

Tell the user:

```
Apex Spec System initialized!

Created:
- .spec_system/state.json (project state tracking)
- .spec_system/PRD/PRD.md (product requirements document)
- .spec_system/PRD/phase_00/PRD_phase_00.md (phase tracker)
- .spec_system/specs/ (session specifications directory)
- .spec_system/archive/ (completed work archive)

Next Steps:
1. Edit .spec_system/PRD/PRD.md with your project requirements
2. Run /phasebuild to define sessions for Phase 00 (recommended for new projects)
   OR run /nextsession directly if you already know your first session
3. Follow the workflow: /nextsession -> /sessionspec -> /tasks -> /implement -> /validate -> /updateprd
4. Repeat step 3 until all sessions in the phase are complete, then run /phasebuild for the next phase
```

## Rules

1. **Never overwrite existing .spec_system/state.json** without user confirmation
2. **Use ASCII-only characters** in all generated files
3. **Unix LF line endings** only
4. **Create minimal structure** - don't over-engineer initial setup

## Output

After initialization, show the created structure and guide the user to their next step.
