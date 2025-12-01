---
name: updateprd
description: Mark session complete and sync documentation
---

# /updateprd Command

You are an AI assistant marking a session as complete and updating project documentation.

## Your Task

After successful validation, mark the session complete and update all tracking documents.

## Prerequisites

- Session must have passed `/validate`
- `validation.md` must show PASS status

## Steps

### 1. Verify Validation Passed

Read `specs/[current-session]/validation.md`:
- Confirm overall result is PASS
- If FAIL, instruct user to fix issues first

### 2. Update State

Update `.spec_system/state.json`:

```json
{
  "completed_sessions": [
    "...existing...",
    "phaseNN-sessionNN-name"  // Add this session
  ],
  "current_session": null,  // Clear current
  "next_session_history": [
    {
      "date": "YYYY-MM-DD",
      "session": "phaseNN-sessionNN-name",
      "status": "completed"  // Update status
    }
  ],
  "phases": {
    "N": {
      "status": "in_progress",  // or "complete" if last session
      "session_count": N  // Update if needed
    }
  }
}
```

### 3. Update Phase README

Update `.spec_system/PRD/phase_NN/README.md`:
- Mark session as Complete
- Add completion date
- Update progress percentage

### 4. Create Implementation Summary

Create `IMPLEMENTATION_SUMMARY.md` in the session directory:

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

### 5. Check Phase Completion

If this was the last session in the phase:
- Update phase status to "complete"
- Move phase PRD to archive if desired
- Update master PRD.md

### 6. Archive Session

Optionally move completed session to archive:
```
archive/sessions/phaseNN-sessionNN-name/
```

### 7. Report Completion

Tell the user:
- Session marked complete
- Updated files list
- Phase progress
- Next recommended action

## State Updates

### state.json Changes
```json
{
  "completed_sessions": ["...add session..."],
  "current_session": null,
  "phases": {
    "N": {
      "status": "complete" | "in_progress"
    }
  }
}
```

### Phase README Updates
```markdown
| Session | Name | Status | Validated |
|---------|------|--------|-----------|
| 01 | Name | Complete | 2025-01-15 |
```

## Output

Report to user:

```
Session Completed: phaseNN-sessionNN-name

Updates Made:
- state.json: Added to completed_sessions
- Phase README: Marked session complete
- Created: IMPLEMENTATION_SUMMARY.md

Phase Progress: N/M sessions (X%)

Next Steps:
- Run `/nextsession` to get next recommendation
- Or run `/phasebuild` if starting new phase
```

## Error Handling

If validation not passed:
```
Cannot mark session complete.

Validation status: FAIL

Please fix validation issues and run `/validate` again.
```

If state inconsistent:
```
State inconsistency detected.

Current session in state.json doesn't match.
Please verify state.json and try again.
```
