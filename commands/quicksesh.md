---
name: quicksesh
description: Complete session workflow - analyze, spec, tasks, implement, validate, and complete in one command
---

# /quicksesh Command

Execute (or continue) the complete session workflow from analysis through completion in a single command.

## Role & Mindset

You are a **senior engineer** obsessive about pristine code - zero errors, zero warnings, zero lint issues. Known for **clean project scaffolding**, rigorous **structure discipline**, and treating implementation as a craft: methodical, patient, and uncompromising on quality.

## Overview

This command executes 6 phases sequentially:

| Phase | Action | Artifacts Created |
|-------|--------|-------------------|
| 1. Analyze | Recommend next session | `NEXT_SESSION.md` |
| 2. Spec | Create specification | `spec.md` |
| 3. Tasks | Generate task list | `tasks.md` |
| 4. Implement | Execute all tasks | `implementation-notes.md` |
| 5. Validate | Verify completion | `validation.md` |
| 6. Complete | Update PRD, commit | `IMPLEMENTATION_SUMMARY.md` |

---

## Phase 1: Analyze

### 1.1 Get Project State

```bash
if [ -d ".spec_system/scripts" ]; then
  bash .spec_system/scripts/analyze-project.sh --json
else
  bash ${CLAUDE_PLUGIN_ROOT}/scripts/analyze-project.sh --json
fi
```

Returns JSON with: `current_phase`, `current_session`, `completed_sessions`, `candidate_sessions`, `phases`.

Use JSON output as ground truth. If `current_session` is non-null with existing work, ask user whether to continue that session or start fresh.

### 1.2 Read Context

- `.spec_system/PRD/PRD.md` - Master requirements
- Candidate session files from JSON `candidate_sessions[].path`
- `.spec_system/CONSIDERATIONS.md` - Institutional memory (if exists)
- `.spec_system/CONVENTIONS.md` - Coding standards (if exists)

**Focus on understanding:**
- Session objectives and scope
- Prerequisites and dependencies
- Logical ordering
- **Active Concerns** that may influence session priority or approach
- **Lessons Learned** relevant to candidate sessions

### 1.3 Recommend Session

Evaluate candidates by:
- Prerequisites met (check against `completed_sessions`)
- Dependencies completed
- Logical flow in project progression
- MVP focus - core features before polish

### 1.4 Create NEXT_SESSION.md

```markdown
# NEXT_SESSION.md

**Generated**: [YYYY-MM-DD]
**Project State**: Phase NN - [Name]
**Completed Sessions**: [count]

---

## Recommended Next Session

**Session ID**: `phaseNN-sessionNN-name`
**Session Name**: [Title]
**Estimated Duration**: [X-Y] hours
**Estimated Tasks**: [N]

---

## Why This Session Next?

### Prerequisites Met
- [x] [prerequisite 1]
- [x] [prerequisite 2]

### Dependencies
- **Builds on**: [previous session]
- **Enables**: [future session]

### Project Progression
[Explain why this is the logical next step]

---

## Session Overview

### Objective
[Clear single objective]

### Key Deliverables
1. [deliverable 1]
2. [deliverable 2]
3. [deliverable 3]

### Scope Summary
- **In Scope (MVP)**: [included]
- **Out of Scope**: [deferred]

---

## Technical Considerations

### Technologies/Patterns
- [tech 1]
- [tech 2]

### Potential Challenges
- [challenge 1]
- [challenge 2]

### Relevant Considerations
<!-- From CONSIDERATIONS.md - omit section if none apply -->
- [P##] **[Active Concern]**: How it affects this session
- [P##] **[Lesson Learned]**: How to apply it here

---

## Alternative Sessions

If this session is blocked:
1. **[alt session]** - [reason]
2. **[alt session]** - [reason]
```

### 1.5 Update State

Set `current_session` and add to `next_session_history` with status `recommended`.

**Checkpoint**: Inform user of recommendation, then proceed to Phase 2.

---

## Phase 2: Spec

### 2.1 Read Inputs

- `.spec_system/NEXT_SESSION.md` - Session recommendation
- `.spec_system/state.json` - Project state
- `.spec_system/PRD/phase_NN/session_NN_name.md` - Session definition (if exists)
- `.spec_system/CONSIDERATIONS.md` - Institutional memory (if exists)
- `.spec_system/CONVENTIONS.md` - Project coding conventions (if exists)

**From CONSIDERATIONS.md, identify:**
- Active Concerns relevant to this session's scope
- Lessons Learned that should inform implementation approach
- Tool/Library Notes for technologies being used

**From CONVENTIONS.md, incorporate:**
- Naming conventions that affect file/function/variable naming in deliverables
- File structure conventions that inform where deliverables should be placed
- Testing philosophy that shapes the Testing Strategy section
- Any patterns or anti-patterns relevant to the technical approach

### 2.2 Create Session Directory

```
.spec_system/specs/phaseNN-sessionNN-name/
```

### 2.3 Scope Rules (Hard Limits - Reject if Exceeded)

- Maximum 30 tasks
- Maximum 4 hours
- Single clear objective

### 2.4 Generate spec.md

```markdown
# Session Specification

**Session ID**: `phaseNN-sessionNN-name`
**Phase**: NN - Phase Name
**Status**: Not Started
**Created**: [YYYY-MM-DD]

---

## 1. Session Overview

[2-3 paragraphs: what, why, how it fits]

---

## 2. Objectives

1. [Specific, measurable objective]
2. [Specific, measurable objective]
3. [Specific, measurable objective]
4. [Specific, measurable objective]

---

## 3. Prerequisites

### Required Sessions
- [x] `phaseNN-sessionNN-name` - [what it provides]

### Required Tools/Knowledge
- [tool/knowledge item]

### Environment Requirements
- [environment requirement]

---

## 4. Scope

### In Scope (MVP)
- [Feature/functionality to implement]
- [Feature/functionality to implement]

### Out of Scope (Deferred)
- [Feature] - *Reason: [why deferred]*

---

## 5. Technical Approach

### Architecture
[Describe the technical architecture and design]

### Design Patterns
- [Pattern]: [Why using it]

### Technology Stack
- [Technology and version]

---

## 6. Deliverables

### Files to Create
| File | Purpose | Est. Lines |
|------|---------|------------|
| `path/to/file` | Description | ~100 |

### Files to Modify
| File | Changes | Est. Lines |
|------|---------|------------|
| `path/to/file` | Description | ~20 |

---

## 7. Success Criteria

### Functional Requirements
- [ ] [Testable requirement]

### Testing Requirements
- [ ] Unit tests written and passing
- [ ] Manual testing completed

### Quality Gates
- [ ] All files ASCII-encoded
- [ ] Unix LF line endings
- [ ] Code follows project conventions

---

## 8. Implementation Notes

### Key Considerations
- [Important consideration]

### Potential Challenges
- [Challenge]: [Mitigation]

### Relevant Considerations
<!-- From CONSIDERATIONS.md - remove section if none apply -->
- [P##] **[Active Concern]**: How it affects this session and mitigation
- [P##] **[Lesson Learned]**: How we're applying it in this implementation

### ASCII Reminder
All output files must use ASCII-only characters (0-127).

---

## 9. Testing Strategy

### Unit Tests
- [What to test]

### Integration Tests
- [What to test]

### Manual Testing
- [Test scenario]

### Edge Cases
- [Edge case to handle]

---

## 10. Dependencies

### External Libraries
- [Library]: [version]

### Other Sessions
- **Depends on**: [sessions]
- **Depended by**: [sessions]
```

### 2.5 Archive & Update State

Move `NEXT_SESSION.md` to session directory as `NEXT_SESSION_archived.md`.
Update `next_session_history` status to `spec_created`.

**Checkpoint**: Show deliverables summary, then proceed to Phase 3.

---

## Phase 3: Tasks

### 3.1 Analyze Spec

From spec.md identify:
- Deliverables (files to create/modify)
- Success criteria
- Technical approach
- Testing requirements
- Task dependencies

### 3.2 Task Design Rules

**Quantity**: 15-30 tasks (sweet spot: 20-25)
**Sizing**: ~20-25 minutes per task, single file focus, clear atomic action

**Categories**:
1. **Setup** (2-4 tasks): Environment, directories, config
2. **Foundation** (4-8 tasks): Core types, interfaces, base classes
3. **Implementation** (8-15 tasks): Main feature logic
4. **Testing** (3-5 tasks): Tests, validation, verification

**Task Format**: `- [ ] TNNN [SPPSS] [P] Action verb + what + where (path/file)`

**Parallelization `[P]`**: Mark when tasks create independent files, don't depend on each other, can be done in any order.

### 3.3 Generate tasks.md

```markdown
# Task Checklist

**Session ID**: `phaseNN-sessionNN-name`
**Total Tasks**: [N]
**Estimated Duration**: [X-Y] hours
**Created**: [YYYY-MM-DD]

---

## Legend

- `[x]` = Completed
- `[ ]` = Pending
- `[P]` = Parallelizable (can run with other [P] tasks)
- `[SNNMM]` = Session reference (NN=phase, MM=session)
- `TNNN` = Task ID

---

## Progress Summary

| Category | Total | Done | Remaining |
|----------|-------|------|-----------|
| Setup | N | 0 | N |
| Foundation | N | 0 | N |
| Implementation | N | 0 | N |
| Testing | N | 0 | N |
| **Total** | **N** | **0** | **N** |

---

## Setup (N tasks)

Initial configuration and environment preparation.

- [ ] T001 [SPPSS] Verify prerequisites met (tools, dependencies)
- [ ] T002 [SPPSS] Create directory structure for deliverables

---

## Foundation (N tasks)

Core structures and base implementations.

- [ ] T003 [SPPSS] [P] Create [component] (`path/to/file`)
- [ ] T004 [SPPSS] [P] Define [interface/type] (`path/to/file`)
- [ ] T005 [SPPSS] Implement [base functionality] (`path/to/file`)

---

## Implementation (N tasks)

Main feature implementation.

- [ ] T006 [SPPSS] Implement [feature part 1] (`path/to/file`)
- [ ] T007 [SPPSS] Implement [feature part 2] (`path/to/file`)
- [ ] T008 [SPPSS] [P] Add [component A] (`path/to/file`)
- [ ] T009 [SPPSS] [P] Add [component B] (`path/to/file`)
- [ ] T010 [SPPSS] Wire up [integration] (`path/to/file`)
- [ ] T011 [SPPSS] Add error handling (`path/to/file`)

---

## Testing (N tasks)

Verification and quality assurance.

- [ ] T012 [SPPSS] [P] Write unit tests for [component] (`tests/path`)
- [ ] T013 [SPPSS] [P] Write unit tests for [component] (`tests/path`)
- [ ] T014 [SPPSS] Run test suite and verify passing
- [ ] T015 [SPPSS] Validate ASCII encoding on all files
- [ ] T016 [SPPSS] Manual testing and verification

---

## Completion Checklist

Before marking session complete:

- [ ] All tasks marked `[x]`
- [ ] All tests passing
- [ ] All files ASCII-encoded
- [ ] implementation-notes.md updated
- [ ] Ready for `/validate`

---

## Notes

### Parallelization
Tasks marked `[P]` can be worked on simultaneously.

### Task Timing
Target ~20-25 minutes per task.

### Dependencies
Complete tasks in order unless marked `[P]`.
```

### 3.4 Update State

Update `next_session_history` status to `tasks_created`.

**Checkpoint**: Show task count and breakdown, then proceed to Phase 4.

---

## Phase 4: Implement

### 4.1 Verify Environment

```bash
if [ -d ".spec_system/scripts" ]; then
  bash .spec_system/scripts/check-prereqs.sh --json --env
else
  bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-prereqs.sh --json --env
fi
```

**STOP if environment check fails** - report issues to user and do NOT proceed.

If spec.md Prerequisites lists required tools, also run `--tools "tool1,tool2"` to catch missing tools BEFORE implementation starts.

### 4.2 Read Session Context

- `.spec_system/specs/[current-session]/spec.md` - Full specification
- `.spec_system/specs/[current-session]/tasks.md` - Task checklist
- `.spec_system/specs/[current-session]/implementation-notes.md` - Progress log (if exists)
- `.spec_system/CONVENTIONS.md` - Project coding conventions (if exists)

**CONVENTIONS.md** contains project-specific coding standards (naming, file structure, error handling, testing philosophy, git practices). All code MUST follow these conventions.

### 4.3 Initialize implementation-notes.md

```markdown
# Implementation Notes

**Session ID**: `phaseNN-sessionNN-name`
**Started**: [YYYY-MM-DD HH:MM]
**Last Updated**: [YYYY-MM-DD HH:MM]

---

## Session Progress

| Metric | Value |
|--------|-------|
| Tasks Completed | 0 / N |
| Estimated Remaining | X hours |
| Blockers | 0 |

---

## Task Log

### [YYYY-MM-DD] - Session Start

**Environment verified**:
- [x] Prerequisites confirmed
- [x] Tools available
- [x] Directory structure ready

---
```

### 4.4 Execute Tasks

For each task in order:

**A. Implement**
- Follow CLAUDE.md guidelines
- Follow CONVENTIONS.md standards (naming, structure, error handling, comments)
- ASCII-only output, LF line endings
- Implement exactly what's in spec - no extras

**B. Update tasks.md**
Change `- [ ]` to `- [x]` immediately after completing.

**C. Log Progress**
```markdown
### Task TNNN - [Description]

**Started**: [YYYY-MM-DD HH:MM]
**Completed**: [YYYY-MM-DD HH:MM]
**Duration**: [X] minutes

**Notes**:
- [Implementation details]
- [Decisions made]

**Files Changed**:
- `path/to/file` - [changes made]
```

**D. Handle Blockers**
```markdown
## Blockers & Solutions

### Blocker N: [Title]

**Description**: [What's blocking]
**Impact**: [Which tasks affected]
**Resolution**: [How resolved / workaround]
**Time Lost**: [Duration]
```

**E. Track Design Decisions**
```markdown
## Design Decisions

### Decision N: [Title]

**Context**: [Why decision needed]
**Options Considered**:
1. [Option A] - [pros/cons]
2. [Option B] - [pros/cons]

**Chosen**: [Option]
**Rationale**: [Why]
```

### 4.5 Checkpoint Every 3-5 Tasks

- Save all changes
- Update tasks.md and implementation-notes.md
- If approaching context limits, document state for resumption

### 4.6 Progress Communication

After completing tasks, report:
- Tasks done (X of Y)
- Current progress percentage
- Next task preview
- Any blockers or concerns

### 4.7 Resuming Implementation

If implementation was interrupted:
1. Read implementation-notes.md for context
2. Check tasks.md for last completed task
3. Resume from next incomplete task
4. Continue logging progress

**After all tasks complete**: Proceed to Phase 5.

---

## Phase 5: Validate

### 5.1 Run Validation Checks

| Check | Action |
|-------|--------|
| **A. Tasks** | Verify 100% marked `[x]` |
| **B. Deliverables** | Each file exists and non-empty |
| **C. Encoding** | ASCII-only, LF line endings |
| **D. Tests** | Run suite, record pass/fail |
| **E. Criteria** | Check spec.md success criteria |
| **F. Conventions** | Spot-check CONVENTIONS.md compliance |

### 5.2 ASCII Encoding Check Commands

```bash
# Check encoding
file [filename]  # Should show: ASCII text

# Find non-ASCII characters (GNU grep)
grep -P '[^\x00-\x7F]' [filename]

# Alternative for macOS/BSD
LC_ALL=C grep '[^[:print:][:space:]]' [filename]

# Check for CRLF line endings
grep -l $'\r' [filename]
```

### 5.3 Generate validation.md

```markdown
# Validation Report

**Session ID**: `phaseNN-sessionNN-name`
**Validated**: [YYYY-MM-DD]
**Result**: PASS / FAIL

---

## Validation Summary

| Check | Status | Notes |
|-------|--------|-------|
| Tasks Complete | PASS/FAIL | X/Y tasks |
| Files Exist | PASS/FAIL | X/Y files |
| ASCII Encoding | PASS/FAIL | [issues] |
| Tests Passing | PASS/FAIL | X/Y tests |
| Quality Gates | PASS/FAIL | [issues] |
| Conventions | PASS/SKIP | [issues or "No CONVENTIONS.md"] |

**Overall**: PASS / FAIL

---

## 1. Task Completion

### Status: PASS/FAIL

| Category | Required | Completed | Status |
|----------|----------|-----------|--------|
| Setup | N | N | PASS |
| Foundation | N | N | PASS |
| Implementation | N | N | PASS |
| Testing | N | N | PASS |

### Incomplete Tasks
[List any incomplete tasks or "None"]

---

## 2. Deliverables Verification

### Status: PASS/FAIL

#### Files Created
| File | Found | Status |
|------|-------|--------|
| `path/file1` | Yes | PASS |
| `path/file2` | Yes | PASS |

### Missing Deliverables
[List any missing or "None"]

---

## 3. ASCII Encoding Check

### Status: PASS/FAIL

| File | Encoding | Line Endings | Status |
|------|----------|--------------|--------|
| `path/file1` | ASCII | LF | PASS |

### Encoding Issues
[List issues or "None"]

---

## 4. Test Results

### Status: PASS/FAIL

| Metric | Value |
|--------|-------|
| Total Tests | N |
| Passed | N |
| Failed | 0 |
| Coverage | X% |

### Failed Tests
[List failures or "None"]

---

## 5. Success Criteria

From spec.md:

### Functional Requirements
- [x] [Requirement 1]
- [x] [Requirement 2]

### Testing Requirements
- [x] Unit tests written and passing
- [x] Manual testing completed

### Quality Gates
- [x] All files ASCII-encoded
- [x] Unix LF line endings
- [x] Code follows project conventions

---

## 6. Conventions Compliance

### Status: PASS/SKIP

*Skipped if no `.spec_system/CONVENTIONS.md` exists.*

| Category | Status | Notes |
|----------|--------|-------|
| Naming | PASS/FAIL | [issues] |
| File Structure | PASS/FAIL | [issues] |
| Error Handling | PASS/FAIL | [issues] |
| Comments | PASS/FAIL | [issues] |
| Testing | PASS/FAIL | [issues] |

### Convention Violations
[List violations or "None" or "Skipped - no CONVENTIONS.md"]

---

## Validation Result

### PASS / FAIL

[Summary of validation outcome]

### Required Actions (if FAIL)
[List what needs to be fixed]

---

## Next Steps

[If PASS]: Run `/updateprd` to mark session complete.
[If FAIL]: Address required actions and run `/validate` again.
```

### 5.4 Validation Criteria

**PASS Requirements** (all must be true):
- 100% of tasks completed
- All deliverable files exist
- All files ASCII-encoded with LF endings
- All tests passing
- All success criteria met

**FAIL Conditions** (any triggers FAIL):
- Incomplete tasks
- Missing deliverables
- Non-ASCII characters in files
- CRLF line endings
- Failing tests
- Unmet success criteria

### 5.5 Update State

Update `next_session_history` status to `validated` or `validation_failed`.

**If FAIL**: Report issues and STOP. User must fix and re-run `/quicksesh --from 5`.

**If PASS**: Proceed to Phase 6.

---

## Phase 6: Complete

### 6.1 Verify Validation Passed

Read `.spec_system/specs/[current-session]/validation.md`:
- Confirm overall result is PASS
- If FAIL, instruct user to fix issues first

### 6.2 Update State

```json
{
  "completed_sessions": ["...existing...", "phaseNN-sessionNN-name"],
  "current_session": null,
  "next_session_history": [{"status": "completed", ...}],
  "phases": {"N": {"status": "in_progress", "session_count": N}}
}
```

### 6.3 Update Phase PRD

In `.spec_system/PRD/phase_NN/PRD_phase_NN.md`:
- Mark session Complete in Progress Tracker
- Add completion date
- Update progress percentage

### 6.4 Create IMPLEMENTATION_SUMMARY.md

```markdown
# Implementation Summary

**Session ID**: `phaseNN-sessionNN-name`
**Completed**: [DATE]
**Duration**: [X] hours

---

## Overview

[Brief summary of what was accomplished]

---

## Deliverables

### Files Created
| File | Purpose | Lines |
|------|---------|-------|
| `path/file1` | [purpose] | ~N |
| `path/file2` | [purpose] | ~N |

### Files Modified
| File | Changes |
|------|---------|
| `path/file` | [changes] |

---

## Technical Decisions

1. **[Decision]**: [Rationale]
2. **[Decision]**: [Rationale]

---

## Test Results

| Metric | Value |
|--------|-------|
| Tests | N |
| Passed | N |
| Coverage | X% |

---

## Lessons Learned

1. [Lesson]
2. [Lesson]

---

## Future Considerations

Items for future sessions:
1. [Item]
2. [Item]

---

## Session Statistics

- **Tasks**: N completed
- **Files Created**: N
- **Files Modified**: N
- **Tests Added**: N
- **Blockers**: N resolved
```

### 6.5 Check Phase Completion

If last session in phase:
- Update phase status to `complete` in state.json
- Archive: move `PRD/phase_NN/` to `archive/phases/phase_NN/`
- Update master `PRD.md`

### 6.6 Increment Version

Check in order: `package.json`, `pyproject.toml`, `setup.py`, `Cargo.toml`, `version.txt`, `VERSION`

- Increment patch: X.Y.Z -> X.Y.Z+1
- Preserve pre-release suffix (-alpha, -beta)
- Update README.md if contains version badge
- If no version file found, skip and note in report

### 6.7 Commit

**Do NOT add co-authors or attributions!**

```
Complete phaseNN-sessionNN-name: [brief description]

- [key deliverable 1]
- [key deliverable 2]
- Version: X.Y.Z -> X.Y.Z+1
```

### 6.8 Report

```
Session Completed: phaseNN-sessionNN-name

Updates Made:
- state.json: Added to completed_sessions
- Phase PRD: Marked complete
- Created: IMPLEMENTATION_SUMMARY.md
- Version: X.Y.Z -> X.Y.Z+1 (package.json)

Phase Progress: N/M sessions (X%)

Next: Run `/quicksesh` for next session or `/phasebuild` for new phase
```

---

## Error Handling

| Error | Action |
|-------|--------|
| Script fails | Check `.spec_system/` exists, `state.json` valid, `jq` installed |
| Environment check fails | Report issues, STOP - do not proceed |
| Validation FAIL | Report issues, STOP at Phase 5 |
| State inconsistency | Verify `.spec_system/state.json` matches expected state |
| No version file | Skip increment, note in report |

## Resumption

Use `--from <phase>` to resume:
- `--from 1` - Start fresh analysis
- `--from 2` - Skip analysis, create spec
- `--from 3` - Skip spec, generate tasks
- `--from 4` - Skip tasks, implement (reads existing tasks.md)
- `--from 5` - Skip implement, validate
- `--from 6` - Skip validate, complete

Read existing artifacts (tasks.md, implementation-notes.md) to resume mid-phase.

---

## Rules

1. **Script first** - Run analyze-project.sh before any analysis
2. **Trust scripts** - JSON output is authoritative
3. **One session** - Complete fully before starting next
4. **Respect dependencies** - Don't skip prerequisites
5. **MVP focus** - Core features before polish
6. **Scope discipline** - 15-30 tasks, 2-4 hours max, single objective
7. **ASCII only** - All output files 0-127 bytes, LF endings
8. **Checkpoint often** - Update artifacts after each task
9. **No extras** - Implement exactly what's in spec
10. **Follow conventions** - CLAUDE.md and CONVENTIONS.md are mandatory
