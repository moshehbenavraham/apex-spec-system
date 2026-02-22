---
name: tasks
description: Generate a 12-25 task checklist for the current session
---

# /tasks Command

Generate a sequenced, 12-25 task checklist for implementing the current session specification.

## Rules

1. **Task count**: 12 minimum, 25 maximum, 20 sweet spot
2. **Task sizing**: ~20-25 minutes each, single file focus when possible, clear atomic action
3. **ASCII-only characters** and Unix LF line endings
4. **Every task must have**: task ID (`TNNN`), session ref (`[SPPSS]`), action verb, target file path
5. **Mark `[P]`** when tasks create independent files with no interdependency
6. **Sequence by**: dependencies first, then setup -> foundation -> implementation -> testing

## Steps

### 1. Read Specification

Read the current session spec:
- `.spec_system/specs/[current-session]/spec.md` - Full specification
- `.spec_system/state.json` - Get current session ID

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
**Created**: [YYYY-MM-DD]

---

## Legend

- `[x]` = Completed
- `[ ]` = Pending
- `[P]` = Parallelizable (can run with other [P] tasks)
- `[SNNMM]` = Session reference (NN=phase number, MM=session number)
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

## Next Steps

Run `/implement` to begin AI-led implementation.
```

## Category Budgets

| Category | Tasks | Purpose |
|----------|-------|---------|
| Setup | 2-4 | Environment, directories, config |
| Foundation | 4-8 | Core types, interfaces, base classes |
| Implementation | 8-15 | Main feature logic |
| Testing | 3-5 | Tests, validation, verification |

## 4. Update State

Update `.spec_system/state.json`:

```json
{
  "current_session": "phaseNN-sessionNN-name",
  "next_session_history": [
    {
      "date": "YYYY-MM-DD",
      "session": "phaseNN-sessionNN-name",
      "status": "tasks_created"
    }
  ]
}
```

- Update `next_session_history` entry status to `tasks_created`

## Output

Create the tasks.md file and show the user:
- Total task count
- Category breakdown
- Estimated duration
- Key parallelization opportunities
