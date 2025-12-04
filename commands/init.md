---
name: init
description: Initialize the Apex Spec System in the current project
---

# /init Command

Initialize the Apex Spec System in the current project directory.

## Your Task

Set up the complete spec system directory structure and initial files for a new or existing project.

## Steps

### 1. Check Current State

First, check if the spec system is already initialized:
- Look for `state.json` in the project root
- Check for `PRD/` directory
- Check for `specs/` directory

If already initialized, ask the user if they want to reinitialize (this will reset state).

### 2. Gather Project Information

Ask the user for:
- **Project name**: Name of the project
- **Project description**: Brief description of what the project does
- **First phase name**: Name for Phase 00 (default: "Foundation")

### 3. Create Directory Structure

Create the following directories:

```bash
mkdir -p PRD/phase_00
mkdir -p specs
mkdir -p archive/backups
mkdir -p archive/sessions
mkdir -p archive/planning
mkdir -p archive/PRD
```

### 4. Create state.json

Create the initial state file:

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

Create `PRD/PRD.md` with a starter template:

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

### 6. Create Phase README

Create `PRD/phase_00/README.md`:

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

### 7. Copy Templates (Optional)

If the user wants local templates, copy from the plugin:

```bash
cp -r ${CLAUDE_PLUGIN_ROOT}/templates ./templates
cp -r ${CLAUDE_PLUGIN_ROOT}/scripts ./scripts
chmod +x ./scripts/*.sh
```

Ask user: "Do you want to copy templates and scripts locally, or use them from the plugin?"

### 8. Report Success

Tell the user:

```
Apex Spec System initialized!

Created:
- state.json (project state tracking)
- PRD/PRD.md (product requirements document)
- PRD/phase_00/README.md (phase tracker)
- specs/ (implementation specs directory)
- archive/ (completed work archive)

Next Steps:
1. Edit PRD/PRD.md with your project requirements
2. Run /nextsession to get your first session recommendation
3. Follow the workflow: /nextsession -> /sessionspec -> /tasks -> /implement -> /validate -> /updateprd
```

## Rules

1. **Never overwrite existing state.json** without user confirmation
2. **Use ASCII-only characters** in all generated files
3. **Unix LF line endings** only
4. **Create minimal structure** - don't over-engineer initial setup

## Output

After initialization, show the created structure and guide the user to their next step.
