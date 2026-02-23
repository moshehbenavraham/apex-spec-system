---
name: updateprd
description: Mark session complete and sync documentation
---

# /updateprd Command

After successful validation, mark the session complete, update all tracking documents, increment the project version, and commit to the repository.

## Rules

1. **Validation must have PASSED** - if `validation.md` shows FAIL, stop and instruct user to fix issues first
2. **ASCII-only characters** and Unix LF line endings in all output
3. **No co-authors or attributions** in commit messages
4. **Increment patch version** by default (X.Y.Z -> X.Y.Z+1), preserve pre-release suffixes

## Steps

### 1. Verify Validation Passed

Read `.spec_system/specs/[current-session]/validation.md`:
- Confirm overall result is PASS
- If FAIL, instruct user to fix issues first

### 2. Update State

Update `.spec_system/state.json`:

```json
{
  "completed_sessions": [
    "...existing...",
    "phaseNN-sessionNN-name"
  ],
  "current_session": null,
  "next_session_history": [
    {
      "date": "YYYY-MM-DD",
      "session": "phaseNN-sessionNN-name",
      "status": "completed"
    }
  ],
  "phases": {
    "N": {
      "status": "in_progress",
      "session_count": N
    }
  }
}
```

### 3. Update Phase PRD

Update `.spec_system/PRD/phase_NN/PRD_phase_NN.md`:
- Mark session as Complete in Progress Tracker
- Add completion date
- Update progress percentage

### 4. Create Implementation Summary

Create `.spec_system/specs/[session]/IMPLEMENTATION_SUMMARY.md`:

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
- Update phase status to "complete" in state.json
- Archive phase: move `.spec_system/PRD/phase_NN/` to `.spec_system/archive/phases/phase_NN/`
- Update master `.spec_system/PRD/PRD.md`

### 6. Increment Project Version

Increment the project's patch version in standard version files. Check for these files in order and update the first one found:

| File | Version Location | Example |
|------|------------------|---------|
| `package.json` | `"version": "X.Y.Z"` | `1.2.3` -> `1.2.4` |
| `pyproject.toml` | `version = "X.Y.Z"` | `1.2.3` -> `1.2.4` |
| `setup.py` | `version="X.Y.Z"` | `1.2.3` -> `1.2.4` |
| `Cargo.toml` | `version = "X.Y.Z"` | `1.2.3` -> `1.2.4` |
| `version.txt` | Plain version string | `1.2.3` -> `1.2.4` |
| `VERSION` | Plain version string | `1.2.3` -> `1.2.4` |

**Version increment rules:**
- Increment the **patch** version by default (X.Y.Z -> X.Y.Z+1)
- If version has pre-release suffix (e.g., `-alpha`, `-beta`), preserve it
- If no version file found, skip this step and note it in the report

**Also update version in documentation** if the project follows the monorepo documentation standard (see `/documents`):
- `README.md` - if it contains a version badge or version line
- Any other files that reference the project version

### 7. Commit and Push to Repo

Commit and push all non-gitignored repo changes (implementation work, state/PRD updates, version increment).

Commit message format:
```
Complete phaseNN-sessionNN-name: [brief description]

- [key deliverable 1]
- [key deliverable 2]
- Version: X.Y.Z -> X.Y.Z+1
```

### 8. Report Completion

Tell the user:
- Session marked complete
- Updated files list
- Version change (old -> new)
- Phase progress
- Next recommended action

## Output

Report: session marked complete, updated files, version change, phase progress, and next action (`/plansession` if phase continues, `/audit` if phase complete).
