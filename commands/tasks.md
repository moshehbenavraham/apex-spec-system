---
name: tasks
description: Generate a 15-30 task checklist for the current session
---

# /tasks Command

You are an AI assistant generating an implementation task checklist.

## Your Task

Create a detailed, sequenced task list (15-30 tasks) for implementing the session specification.

## Steps

### 1. Read Specification

Read the current session spec:
- `specs/[current-session]/spec.md` - Full specification
- `state.json` - Get current session ID

### 2. Analyze Requirements

From the spec, identify:
- Deliverables (files to create/modify)
- Success criteria
- Technical approach
- Testing requirements
- Dependencies between tasks

### 3. Generate Task List

Create `tasks.md` in the session directory:

```markdown
# Task Checklist

**Session ID**: `phaseNN-sessionNN-name`
**Total Tasks**: [N]
**Estimated Duration**: [X-Y] hours
**Created**: [DATE]

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

- [ ] T001 [SNNMM] Verify prerequisites met (tools, dependencies)
- [ ] T002 [SNNMM] Create directory structure for deliverables

---

## Foundation (N tasks)

Core structures and base implementations.

- [ ] T003 [SNNMM] [P] Create [component] (`path/to/file`)
- [ ] T004 [SNNMM] [P] Define [interface/type] (`path/to/file`)
- [ ] T005 [SNNMM] Implement [base functionality] (`path/to/file`)

---

## Implementation (N tasks)

Main feature implementation.

- [ ] T006 [SNNMM] Implement [feature part 1] (`path/to/file`)
- [ ] T007 [SNNMM] Implement [feature part 2] (`path/to/file`)
- [ ] T008 [SNNMM] [P] Add [component A] (`path/to/file`)
- [ ] T009 [SNNMM] [P] Add [component B] (`path/to/file`)
- [ ] T010 [SNNMM] Wire up [integration] (`path/to/file`)
- [ ] T011 [SNNMM] Add error handling (`path/to/file`)

---

## Testing (N tasks)

Verification and quality assurance.

- [ ] T012 [SNNMM] [P] Write unit tests for [component] (`tests/path`)
- [ ] T013 [SNNMM] [P] Write unit tests for [component] (`tests/path`)
- [ ] T014 [SNNMM] Run test suite and verify passing
- [ ] T015 [SNNMM] Validate ASCII encoding on all files
- [ ] T016 [SNNMM] Manual testing and verification

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

---

## Next Steps

Run `/implement` to begin AI-guided implementation.
```

## Task Design Rules

### Quantity
- **Minimum**: 15 tasks
- **Maximum**: 30 tasks
- **Sweet spot**: 20-25 tasks

### Task Sizing
- Each task: ~20-25 minutes
- Single file focus when possible
- Clear, atomic action

### Categories
1. **Setup** (2-4 tasks): Environment, directories, config
2. **Foundation** (4-8 tasks): Core types, interfaces, base classes
3. **Implementation** (8-15 tasks): Main feature logic
4. **Testing** (3-5 tasks): Tests, validation, verification

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

### Parallelization Markers
Mark tasks `[P]` when they:
- Create independent files
- Don't depend on each other's output
- Can be done in any order

### Sequencing
Order tasks by:
1. Dependencies (prerequisite tasks first)
2. Logical flow (setup -> foundation -> implementation -> testing)
3. File dependencies (create before modify)

## Output

Create the tasks.md file and show the user:
- Total task count
- Category breakdown
- Estimated duration
- Key parallelization opportunities
