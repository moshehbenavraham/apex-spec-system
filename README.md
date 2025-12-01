# Apex Spec System

A lightweight, specification-driven workflow system for AI-assisted development.

## Overview

The Apex Spec System breaks large projects into manageable, well-scoped implementation sessions that fit within AI context windows and human attention spans.

**Philosophy**: `1 session = 1 spec = 2-4 hours (15-30 tasks)`

## Features

- **7-Command Workflow**: Structured process from analysis to completion
- **Session Scoping**: Keep work manageable with 15-30 tasks per session
- **Progress Tracking**: State file and checklists track progress
- **Validation Gates**: Verify completeness before marking done
- **ASCII Enforcement**: Avoid encoding issues that break code generation
- **Flexible Templates**: Adapt to any project type

## Quick Start

### 1. Copy to Your Project

```bash
# Copy the spec system
cp -r .spec_system /path/to/your/project/

# Copy slash commands to Claude Code
cp .spec_system/commands/*.md /path/to/your/project/.claude/commands/

# Make scripts executable
chmod +x /path/to/your/project/.spec_system/scripts/*.sh
```

### 2. Initialize

Edit `.spec_system/state.json` with your project info:

```json
{
  "project_name": "Your Project Name",
  "description": "Project description"
}
```

### 3. Create Your PRD

Edit `.spec_system/PRD/PRD.md` with your project requirements.

### 4. Run the Workflow

```bash
/nextsession    # Get recommendation for next session
/sessionspec    # Create formal specification
/tasks          # Generate 15-30 task checklist
/implement      # AI-guided implementation
/validate       # Verify completeness
/updateprd      # Mark complete, update docs
```

## Directory Structure

```
your-project/
├── .spec_system/               # Spec system (copy this)
│   ├── state.json              # Project state tracking
│   ├── commands/               # Slash commands (7 total)
│   ├── scripts/                # Bash automation
│   ├── templates/              # Document templates
│   └── PRD/                    # Product requirements
│       ├── PRD.md              # Master PRD
│       ├── PRD_phase_00.md     # Phase definitions
│       └── phase_00/           # Session definitions
├── specs/                      # Implementation specs
│   └── phaseNN-sessionNN-name/ # One per session
│       ├── spec.md
│       ├── tasks.md
│       ├── implementation-notes.md
│       └── validation.md
└── archive/                    # Completed work
```

## The 7-Command Workflow

```
/nextsession  ->  Analyze project, recommend next feature
      |
      v
/sessionspec  ->  Convert to formal specification
      |
      v
/tasks        ->  Generate 15-30 task checklist
      |
      v
/implement    ->  AI-guided task-by-task implementation
      |
      v
/validate     ->  Verify session completeness
      |
      v
/updateprd    ->  Sync PRD, mark session complete
      |
      v
/phasebuild   ->  (optional) Create new phase structure once previous phase and all sessions completed
```

## Session Naming

**Format**: `phaseNN-sessionNN-name`

- `phaseNN`: 2-digit phase number (phase00, phase01)
- `sessionNN`: 2-digit session number (session01, session02)
- `name`: lowercase-hyphenated description

**Examples**:
- `phase00-session01-project-setup`
- `phase01-session03-user-authentication`
- `phase02-session08b-refinements`

## Session Scope

### Hard Limits
- Maximum 30 tasks per session
- Maximum 4 hours estimated time
- Single clear objective

### Ideal Targets
- 15-25 tasks (sweet spot: 20-25)
- 2-3 hours typical
- MVP focus only

## Critical Rules

### ASCII Encoding (Non-Negotiable)

All files must use ASCII-only characters (0-127):
- NO Unicode characters
- NO emoji
- NO smart quotes - use straight quotes
- Unix LF line endings only

### Over-Arching Rules

- You must only use valid ASCII UTF-8 LF characters and formatting
- You can't run SUDO - pause and ask the user when needed
- Never add co-authors or attributions to AI systems

## Documentation

- [System Overview](.spec_system/README_spec-system.md)
- [Commands Reference](.spec_system/commands/README_spec-system_commands.md)
- [Scripts Reference](.spec_system/scripts/README_spec-system_scripts.md)
- [Templates Reference](.spec_system/templates/README_spec-system_templates.md)

## Requirements

- **Bash**: 4.0+ (for scripts)
- **jq**: For JSON operations (optional but recommended)
- **Claude Code**: Or compatible AI assistant

Install jq:
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq
```

## Best Practices

1. **One session at a time** - Complete before starting next
2. **MVP first** - Defer polish and optimizations
3. **Validate encoding** - Check ASCII before committing
4. **Update tasks as you go** - Mark checkboxes immediately
5. **Trust the system** - Follow workflow, resist scope creep
6. **Read before implementing** - Review spec.md and tasks.md first

## Why This Works for AI

- **Clear scope**: 15-30 tasks prevents context window overload
- **Structured guidance**: Templates provide consistent prompts
- **Progress tracking**: State and checkboxes enable resumption
- **Validation gates**: Ensures quality before moving on
- **ASCII-only**: Removes encoding issues that break generation

## License

MIT License - Use freely in your projects.
