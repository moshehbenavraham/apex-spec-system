# Apex Spec System

A lightweight, specification-driven workflow system for AI-assisted development.

## Philosophy

**1 session = 1 spec = 2-4 hours (15-30 tasks)**

Break large projects into manageable, well-scoped implementation sessions that fit within AI context windows and human attention spans.

## Quick Start

```bash
# 1. Install commands to your AI assistant
cp .spec_system/commands/*.md .claude/commands/

# 2. Make scripts executable
chmod +x .spec_system/scripts/*.sh

# 3. Run the workflow
/nextsession    # Get recommendation for next session
/sessionspec    # Create formal specification
/tasks          # Generate 15-30 task checklist
/implement      # AI-guided implementation
/validate       # Verify completeness
/updateprd      # Mark complete, update docs
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
/phasebuild   ->  (optional) Create new phase structure
```

## Directory Structure

```
project/
├── .spec_system/               # Workflow system (copy this)
│   ├── state.json              # Project state tracking
│   ├── commands/               # Slash commands
│   ├── scripts/                # Bash automation
│   ├── templates/              # Document templates
│   └── PRD/                    # Product requirements
│       ├── PRD.md              # Master PRD
│       └── phase_NN/           # Phase definitions
├── specs/                      # Implementation specs
│   └── phaseNN-sessionNN-name/ # One per session
│       ├── spec.md             # Formal specification
│       ├── tasks.md            # Task checklist
│       ├── implementation-notes.md
│       └── validation.md
└── archive/                    # Completed work
```

## Session Naming Convention

**Format**: `phaseNN-sessionNN-name`

- `phaseNN`: 2-digit phase number (phase00, phase01)
- `sessionNN`: 2-digit session number (session01, session02)
- `name`: lowercase-hyphenated description

**Examples**:
- `phase00-session01-project-setup`
- `phase01-session03-user-authentication`
- `phase02-session08b-refinements` (suffix for sub-sessions)

## Session Scope Rules

### Hard Limits
- Maximum 30 tasks per session
- Maximum 4 hours estimated time
- Single clear objective

### Ideal Targets
- 15-25 tasks (sweet spot: 20-25)
- 2-3 hours typical
- MVP focus only

### MVP vs Full Feature

| Aspect | MVP (Include) | Full (Defer) |
|--------|---------------|--------------|
| Core logic | Essential functionality | Edge cases |
| Error handling | Happy path + basic errors | All edge cases |
| UI | Functional | Polish, animations |
| Testing | Happy path + 1 error case | Comprehensive |
| Config | Hardcoded/simple | Full configurability |

## Critical Requirements

### ASCII Encoding (Non-Negotiable)

All files must use ASCII-only characters (0-127):

- NO Unicode characters
- NO emoji
- NO smart quotes (" ") - use straight quotes (" ')
- NO em-dashes (--) - use hyphens (-)
- Unix LF line endings only (no CRLF)

**Validation**:
```bash
# Check encoding
file filename.txt  # Should show: ASCII text

# Find non-ASCII
grep -P '[^\x00-\x7F]' filename.txt  # Should return nothing
```

## State Tracking

`state.json` tracks project progress:

```json
{
  "version": "2.0",
  "project_name": "My Project",
  "current_phase": 0,
  "current_session": null,
  "phases": {
    "0": {
      "name": "Foundation",
      "status": "in_progress",
      "session_count": 5
    }
  },
  "completed_sessions": [],
  "next_session_history": []
}
```

## Templates

Each session produces 4 documents:

1. **spec.md** - Formal technical specification
2. **tasks.md** - 15-30 task checklist with checkboxes
3. **implementation-notes.md** - Progress log
4. **validation.md** - Completion verification

## Getting Started

1. Copy `.spec_system/` to your project root
2. Edit `state.json` with your project name
3. Create your PRD in `.spec_system/PRD/PRD.md`
4. Define phases in `.spec_system/PRD/phase_00/`
5. Run `/nextsession` to begin

## Best Practices

1. **One session at a time** - Complete before starting next
2. **MVP first** - Defer polish and optimizations
3. **Validate encoding** - Check ASCII before committing
4. **Update tasks as you go** - Mark checkboxes immediately
5. **Trust the system** - Follow workflow, resist scope creep
6. **Read before implementing** - Review spec.md and tasks.md first

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Scope too large | Split session in PRD before /sessionspec |
| ASCII validation fails | Run `grep -P '[^\x00-\x7F]'` to find issues |
| State out of sync | Manually update state.json |
| Commands not working | Verify copied to .claude/commands/ |
