# Commands Reference

Slash commands for the Apex Spec System workflow.

## Installation

Copy commands to your AI assistant's command directory:

```bash
# For Claude Code
cp .spec_system/commands/*.md .claude/commands/

# Verify installation
ls .claude/commands/
```

## Command Overview

| Command | Purpose | Creates/Updates |
|---------|---------|-----------------|
| `/nextsession` | Analyze project, recommend next session | `NEXT_SESSION.md` |
| `/sessionspec` | Create formal specification | `specs/.../spec.md` |
| `/tasks` | Generate 15-30 task checklist | `specs/.../tasks.md` |
| `/implement` | AI-guided implementation | `specs/.../implementation-notes.md` |
| `/validate` | Verify completeness | `specs/.../validation.md` |
| `/updateprd` | Mark complete, sync docs | `state.json`, phase README |
| `/phasebuild` | Create new phase structure | `PRD/phase_NN/` |

## Standard Workflow

```
/nextsession    ->  Get recommendation
      |
/sessionspec    ->  Create specification
      |
/tasks          ->  Generate task list
      |
/implement      ->  Execute tasks
      |
/validate       ->  Verify completion
      |
/updateprd      ->  Mark complete
      |
/phasebuild     ->  (when starting new phase)
      |
[repeat]
```

## Command Details

### /nextsession

**Purpose**: Analyze project state and recommend the next implementation session.

**Reads**:
- `.spec_system/state.json`
- `.spec_system/PRD/PRD.md`
- Phase definitions

**Creates**:
- `.spec_system/NEXT_SESSION.md`

**When to use**: At the start of a new work session, or after completing a session.

---

### /sessionspec

**Purpose**: Convert session recommendation into a formal technical specification.

**Reads**:
- `.spec_system/NEXT_SESSION.md`
- Session definition in PRD

**Creates**:
- `specs/phaseNN-sessionNN-name/spec.md`
- Archives `NEXT_SESSION.md`

**When to use**: After `/nextsession` when ready to start implementation planning.

---

### /tasks

**Purpose**: Generate a detailed, sequenced task checklist (15-30 tasks).

**Reads**:
- `specs/.../spec.md`

**Creates**:
- `specs/.../tasks.md`

**When to use**: After `/sessionspec` to break down work into manageable tasks.

---

### /implement

**Purpose**: Guide task-by-task implementation with progress tracking.

**Reads**:
- `specs/.../spec.md`
- `specs/.../tasks.md`

**Creates/Updates**:
- `specs/.../implementation-notes.md`
- Updates checkboxes in `tasks.md`

**When to use**: To execute the session implementation with AI guidance.

---

### /validate

**Purpose**: Verify all session requirements are met.

**Reads**:
- All session files
- Deliverable files

**Creates**:
- `specs/.../validation.md`

**Checks**:
- Task completion (100%)
- File existence
- ASCII encoding
- Test results
- Success criteria

**When to use**: After completing all tasks, before marking session done.

---

### /updateprd

**Purpose**: Mark session complete and update project tracking.

**Reads**:
- `validation.md` (must be PASS)

**Updates**:
- `.spec_system/state.json`
- Phase README
- Creates `IMPLEMENTATION_SUMMARY.md`

**When to use**: After validation passes.

---

### /phasebuild

**Purpose**: Create structure for a new project phase.

**Creates**:
- `.spec_system/PRD/phase_NN/`
- Phase README
- Session stub files
- Updates state.json

**When to use**: When starting a new phase of work.

## Tips

1. **Follow the order** - Commands build on each other
2. **Don't skip validation** - Ensures quality
3. **One session at a time** - Complete before starting next
4. **Update tasks.md live** - Mark checkboxes as you go
5. **Use implementation-notes.md** - Track decisions and blockers

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Command not found | Verify copied to `.claude/commands/` |
| Wrong session | Check `state.json` current_session |
| Validation fails | Fix issues, run `/validate` again |
| State out of sync | Manually update `state.json` |
