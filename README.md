# Apex Spec System

**Version: 0.18.0-beta**

A Claude Code plugin providing a specification-driven workflow system for AI-assisted development. Think Github Spec Kit (our source inspiration) simplified.

## Overview

The Apex Spec System breaks large projects into manageable, well-scoped implementation sessions that fit within AI context windows and human attention spans.

**Philosophy**: `1 session = 1 spec = 2-4 hours (15-30 tasks)`

**Video Tutorial**: [Watch on YouTube](https://youtu.be/iY6ySesmOCg) - Installation and workflow walkthrough

## Installation

```bash
# Install from local directory
claude --plugin-dir /path/to/apex-spec-system

# Or copy to your plugins directory
cp -r apex-spec-system ~/.claude/plugins/
```

## Requirements

| Dependency | Required | Install |
|------------|----------|---------|
| **jq** | Yes | `apt install jq` or `brew install jq` |
| **git** | Optional | Usually pre-installed |

The scripts use `jq` for JSON parsing. Verify with: `bash scripts/check-prereqs.sh --env`

## Quick Start

1. **Install the plugin** (see above)

2. **Initialize in your project**:
   ```
   /apex-spec:init
   ```
   This creates the spec system structure in your project.

3. **Run the workflow**:
   ```
   /apex-spec:nextsession    # Get recommendation for next session
   /apex-spec:sessionspec    # Create formal specification
   /apex-spec:tasks          # Generate task checklist
   /apex-spec:implement      # Start implementation
   /apex-spec:validate       # Verify completeness
   /apex-spec:updateprd      # Mark complete
   ```

## Features

- **11-Command Workflow**: Structured process from initialization to completion
- **Session Scoping**: Keep work manageable with 15-30 tasks per session
- **Progress Tracking**: State file and checklists track progress
- **Validation Gates**: Verify completeness before marking done
- **ASCII Enforcement**: Avoid encoding issues that break code generation
- **Auto-Activating Skill**: Provides workflow guidance automatically

## Plugin Components

### Commands (11 total)

| Command | Purpose |
|---------|---------|
| `/init` | Initialize spec system in current project |
| `/createprd` | Generate master PRD from requirements document |
| `/nextsession` | Analyze project and recommend next session |
| `/sessionspec` | Create formal technical specification |
| `/tasks` | Generate 15-30 task checklist |
| `/implement` | AI-led task-by-task implementation |
| `/validate` | Verify session completeness |
| `/updateprd` | Mark session complete, sync documentation |
| `/documents` | Audit and update project documentation |
| `/phasebuild` | Create structure for new phase |
| `/audit` | Analyze tech stack, run dev tooling, auto-fix issues |

### Skill

The **spec-workflow** skill auto-activates when:
- Working in projects with `.spec_system/` directory
- User mentions spec system concepts
- User asks about session workflow

### Bundled Resources

- **scripts/**: Bash utilities for project analysis

## The Workflow

The workflow has **3 distinct stages**:

### Stage 1: INITIALIZATION (One-Time Setup)

```
/init              ->  Set up spec system in project
      |
      v
/createprd         ->  Generate PRD from requirements doc (optional)
  OR                   OR
[User Action]      ->  Manually populate PRD with requirements
      |
      v
/phasebuild        ->  Create first phase structure (session stubs)
```

### Stage 2: SESSIONS WORKFLOW (Repeat Until Phase Complete)

```
/nextsession   ->  Analyze project, recommend next session
      |
      v
/sessionspec   ->  Convert to formal specification
      |
      v
/tasks         ->  Generate 15-30 task checklist
      |
      v
/implement     ->  AI-led task-by-task implementation
      |
      v
/validate      ->  Verify session completeness
      |
      v
/updateprd     ->  Sync PRD, mark session complete
      |
      +-------------> Loop back to /nextsession
                      until ALL phase sessions complete
```

### Stage 3: PHASE TRANSITION (After Phase Complete)

```
/documents         ->  Audit and update documentation (recommended)
      |
      v
/phasebuild        ->  Create next phase structure
      |
      v
[User Action]      ->  Manual testing (highly recommended)
      |
      v
                   ->  Return to Stage 2 for new phase
```

## Project Structure

After running `/init`, your project will have:

```
your-project/
├── .spec_system/               # All spec system files
│   ├── state.json              # Project state tracking
│   ├── PRD/                    # Product requirements
│   │   ├── PRD.md              # Master PRD
│   │   └── phase_00/           # Phase definitions
│   ├── specs/                  # Implementation specs
│   │   └── phaseNN-sessionNN-name/
│   │       ├── spec.md
│   │       ├── tasks.md
│   │       ├── implementation-notes.md
│   │       └── validation.md
│   └── archive/                # Completed work
└── (your project source files)
```

## Session Scope

### Hard Limits
- Maximum 30 tasks per session
- Maximum 4 hours estimated time
- Single clear objective

### Ideal Targets
- 15-25 tasks (sweet spot: 20-25)
- 2-3 hours typical
- MVP focus only

## Session Naming

**Format**: `phaseNN-sessionNN-name`

Examples:
- `phase00-session01-project-setup`
- `phase01-session03-user-authentication`

## Critical Rules

### ASCII Encoding (Non-Negotiable)

All files must use ASCII-only characters (0-127):
- NO Unicode characters
- NO emoji
- NO smart quotes - use straight quotes
- Unix LF line endings only

## Best Practices

1. **One session at a time** - Complete before starting next
2. **MVP first** - Defer polish and optimizations
3. **Validate encoding** - Check ASCII before committing
4. **Update tasks continuously** - Mark checkboxes immediately
5. **Trust the system** - Follow workflow, resist scope creep

## License

MIT License - Use freely in your projects.
