# Apex Spec System

**Version: 0.20.9-beta**

A Claude Code plugin providing a specification-driven workflow system for AI-assisted development. Think Github Spec Kit (our source inspiration) simplified.

## Overview

The Apex Spec System breaks large projects into manageable, well-scoped implementation sessions that fit within AI context windows and human attention spans.

**Philosophy**: `1 session = 1 spec = 2-4 hours (15-30 tasks) = safe context window of AI`

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
   /initspec OR /apex-spec:initspec
   ```
   This creates the spec system structure in your project.

   ```
   /createprd OR /apex-spec:createprd OR Manually fill out .spec_system/PRD/PRD.md
   ```
   Optional:  Turn argument or file path into a technical PRD for development.
   Example: /createprd "a habit trackker app"
            /createprd @docs/requirements.md

   ```
   /phasebuild OR /apex-spec:phasebuild
   ```
   This will set up the initial Phase and Sessions for that initial Phase

3. **Run the session workflow and repeat until all sessions inside the Phase are completed, thus completing the Phase**:
   ```
   /nextsession OR /apex-spec:nextsession    # Get recommendation for next session
   /sessionspec OR /apex-spec:sessionspec    # Create formal specification
   /tasks OR /apex-spec:tasks                # Generate task checklist
   /implement OR /apex-spec:implement        # Start implementation
   /validate OR /apex-spec:validate          # Verify completeness
   /updateprd OR /apex-spec:updateprd        # Mark complete, update system
   ```

 4. **Between Phases**
   ```
   /audit OR /apex-spec:audit                # Dev tooling
   /documents OR /apex-spec:documents        # Create, maintain project documentation
   -- Optional but recommended, do manual testing HERE --
   /phasebuild OR /apex-spec:phasebuild      # Set up next Phase and Phase's sessions
   ```

 5. **Repeat until all phases complete!**

## Features

- **11-Command Workflow**: Structured process from initialization to completion
- **Session Scoping**: Keep work manageable with 15-30 tasks per session
- **Progress Tracking**: State file and checklists track progress
- **Validation Gates**: Verify completeness before marking done
- **Auto-Activating Skill**: Provides workflow guidance automatically
- **Dev Tooling**: Regular code quality audits
- **Documentation Maintenance**: Keep project documentation up to date
- **ASCII Enforcement**: Avoid encoding issues that break code generation

## Plugin Components

### Commands (11 total)

| Command | Purpose |
|---------|---------|
| `/initspec` | Initialize spec system in current project |
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

## Project Structure

After running `/initspec`, your project will have:

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
- Stable/late MVP focus

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
5. **Do manual testing** - Best judgment, but at least manaul testing per Phase
6. **Trust the system** - Follow workflow, resist scope creep

## License

MIT License - Use freely in your projects.
