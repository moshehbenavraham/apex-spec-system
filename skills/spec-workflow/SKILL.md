---
name: Apex Spec Workflow
description: This skill should be used when the user asks about "spec system", "session workflow", "createprd", "nextsession", "sessionspec", "implement session", "validate session", "phase build", "session scope", "task checklist", or when working in a project containing .spec_system/ directory. Provides guidance for specification-driven AI development workflows.
version: 0.22.0-beta
---

# Apex Spec Workflow

A specification-driven workflow system for AI-assisted development that breaks large projects into manageable 2-4 hour sessions with 15-30 tasks each.

## Core Philosophy

**1 session = 1 spec = 2-4 hours (15-30 tasks)**

Break large projects into manageable, well-scoped implementation sessions that fit within AI context windows and human attention spans.

## The 12-Command Workflow

The workflow has **3 distinct stages**:

### Stage 1: INITIALIZATION (One-Time Setup)

```
/initspec          ->  Set up spec system in project
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
/audit             ->  Dev tooling (recommended)
      |
      v
/documents         ->  Audit and update documentation (recommended)
      |
      v
[User Action]      ->  Manual testing (highly recommended)
      |
      v
/carryforward      ->  Capture lessons learned (optional but recommended)
      |
      v
/phasebuild        ->  Create next phase structure
      |
      v
                   ->  Return to Stage 2 for new phase
```

## Directory Structure

Projects using this system follow this layout:

```
project/
├── .spec_system/               # All spec system files
│   ├── state.json              # Project state tracking
│   ├── CONSIDERATIONS.md       # Institutional memory (lessons learned)
│   ├── PRD/                    # Product requirements
│   │   ├── PRD.md              # Master PRD
│   │   └── phase_NN/           # Phase definitions
│   ├── specs/                  # Implementation specs
│   │   └── phaseNN-sessionNN-name/
│   │       ├── spec.md
│   │       ├── tasks.md
│   │       ├── implementation-notes.md
│   │       └── validation.md
│   ├── scripts/                # Bash automation (if copied locally)
│   └── archive/                # Completed work
└── (project source files)
```

## Session Naming Convention

**Format**: `phaseNN-sessionNN-name`

- `phaseNN`: 2-digit phase number (phase00, phase01)
- `sessionNN`: 2-digit session number (session01, session02)
- `name`: lowercase-hyphenated description

**Examples**:
- `phase00-session01-project-setup`
- `phase01-session03-user-authentication`
- `phase02-session08b-refinements`

## Session Scope Rules

### Hard Limits (Reject if Exceeded)

| Limit | Value |
|-------|-------|
| Maximum tasks | 30 |
| Maximum duration | 4 hours |
| Objectives | Single clear objective |

### Ideal Targets

| Target | Value |
|--------|-------|
| Task count | 15-25 (sweet spot: 20-25) |
| Duration | 2-3 hours |
| Focus | Stable/late MVP |

## Task Design

### Task Format

```
- [ ] TNNN [SNNMM] [P] Action verb + what + where (`path/to/file`)
```

Components:
- `TNNN`: Sequential task ID (T001, T002, ...)
- `[SNNMM]`: Session reference (S0103 = Phase 01, Session 03)
- `[P]`: Optional parallelization marker
- Description: Action verb + clear description
- Path: File being created/modified

### Task Categories

1. **Setup** (2-4 tasks): Environment, directories, config
2. **Foundation** (4-8 tasks): Core types, interfaces, base classes
3. **Implementation** (8-15 tasks): Main feature logic
4. **Testing** (3-5 tasks): Tests, validation, verification

### Parallelization

Mark tasks `[P]` when they:
- Create independent files
- Don't depend on each other's output
- Can be done in any order

## Critical Requirements

### ASCII Encoding (Non-Negotiable)

All files must use ASCII-only characters (0-127):
- NO Unicode characters
- NO emoji
- NO smart quotes - use straight quotes (" ')
- NO em-dashes - use hyphens (-)
- Unix LF line endings only (no CRLF)

Validate with:
```bash
file filename.txt        # Should show: ASCII text
grep -P '[^\x00-\x7F]' filename.txt  # Should return nothing
```

### Over-Arching Rules

- Complete one session at a time before starting next
- Update task checkboxes immediately as work progresses
- Follow workflow sequence - resist scope creep
- Read spec.md and tasks.md before implementing

## State Tracking

The `.spec_system/state.json` file tracks project progress:

```json
{
  "version": "2.0",
  "project_name": "Project Name",
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

## Command Quick Reference

| Command | Purpose | Input | Output |
|---------|---------|-------|--------|
| `/initspec` | Initialize spec system | Project info | .spec_system/ structure |
| `/createprd` | Generate master PRD | Requirements doc or user text | PRD/PRD.md |
| `/nextsession` | Recommend next session | state.json, PRD | NEXT_SESSION.md |
| `/sessionspec` | Create specification | NEXT_SESSION.md | specs/.../spec.md |
| `/tasks` | Generate task list | spec.md | specs/.../tasks.md |
| `/implement` | Code implementation | spec.md, tasks.md | implementation-notes.md |
| `/validate` | Verify completeness | All session files | validation.md |
| `/updateprd` | Mark complete | validation.md | Updated state.json |
| `/carryforward` | Capture lessons | Completed phase artifacts | CONSIDERATIONS.md |
| `/documents` | Audit/update docs | state.json, PRD, codebase | Updated docs, docs-audit.md |
| `/phasebuild` | Create new phase | PRD | PRD/phase_NN/ |
| `/audit` | Code quality audit | Codebase | Console report |

## Additional Resources

### Reference Files

For detailed guidance, consult:
- **`references/templates.md`** - All document templates with field descriptions
- **`references/workflow.md`** - Detailed command workflows and decision points

### Scripts Directory

Utility scripts are available at two locations:
- **Plugin**: `${CLAUDE_PLUGIN_ROOT}/scripts/` (default, always up-to-date)
- **Local**: `.spec_system/scripts/` (optional, for per-project customization)

**Local scripts take precedence** - if `.spec_system/scripts/` exists, commands use local scripts instead of plugin scripts.

Available scripts:
- `analyze-project.sh` - Project state analysis (supports `--json` for structured output)
- `check-prereqs.sh` - Environment and tool verification (supports `--json` for structured output)
- `common.sh` - Shared functions

To copy scripts locally during `/initspec`, choose "copy locally" when prompted. To revert to plugin scripts, delete `.spec_system/scripts/`.

### Hybrid Architecture

Commands use a **hybrid approach** for reliability:

1. **Deterministic State** (`analyze-project.sh --json`): Authoritative state facts
2. **Environment Verification** (`check-prereqs.sh --json`): Tool and prerequisite validation
3. **Semantic Analysis** (Claude): Interprets PRD content, makes recommendations

**Why this matters:**
- Script output is deterministic - same input always gives same output
- Eliminates risk of Claude misreading state.json
- Tool verification catches missing dependencies BEFORE implementation starts
- Users can run scripts independently to debug
- Claude focuses on what it does best: understanding context and reasoning

**analyze-project.sh JSON Output:**
```json
{
  "project": "project-name",
  "current_phase": 1,
  "current_session": "phase01-session02-feature",
  "completed_sessions": ["phase00-session01-setup"],
  "candidate_sessions": [
    {"file": "session_01_auth", "completed": false}
  ]
}
```

**check-prereqs.sh JSON Output:**
```json
{
  "overall": "pass",
  "environment": {
    "spec_system": {"status": "pass"},
    "jq": {"status": "pass", "info": "jq-1.7"}
  },
  "tools": {
    "node": {"status": "pass", "info": "v20.10.0"},
    "docker": {"status": "fail", "info": "not installed"}
  },
  "issues": [
    {"type": "tool", "name": "docker", "message": "required tool not installed"}
  ]
}
```

**Commands and their script usage:**
| Command | analyze-project.sh | check-prereqs.sh |
|---------|-------------------|------------------|
| `/nextsession` | State + candidates | - |
| `/implement` | Current session | Environment + tools |
| `/validate` | Current session | - |
| `/documents` | State + progress | - |

## Best Practices

1. **Start with /nextsession** - Always analyze state before choosing work
2. **One session at a time** - Complete before starting next
3. **MVP first** - Defer polish and optimizations
4. **Validate encoding** - Check ASCII before committing
5. **Update tasks continuously** - Mark checkboxes immediately
6. **Trust the system** - Follow workflow, resist scope creep
7. **Read before implementing** - Review spec.md and tasks.md first
8. **Keep docs current** - Run `/documents` after completing a phase or adding packages

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Scope too large | Split session in PRD before /sessionspec |
| ASCII validation fails | Run `grep -P '[^\x00-\x7F]'` to find issues |
| State out of sync | Manually update .spec_system/state.json |
| Commands not found | Verify plugin is enabled |
| Tasks taking too long | Reduce scope, defer non-MVP items |
| Missing tools | Run `check-prereqs.sh --tools "tool1,tool2"` to verify |
| Environment issues | Run `check-prereqs.sh --env` to diagnose |
| Stale documentation | Run `/documents` to audit and update |
| Missing docs | Run `/documents` to create standard files |
| Lint/format issues | Run `/audit` to detect stack and auto-fix |
| Test failures | Run `/audit` to attempt simple fixes |
