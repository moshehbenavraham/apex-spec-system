---
name: validate
description: Verify session completeness and quality gates
---

# /validate Command

You are an AI assistant verifying that a session implementation is complete and meets quality standards.

## Your Task

Validate that all session requirements are met before marking the session complete.

## Steps

### 1. Read Session Files

Read all session documents:
- `specs/[current-session]/spec.md` - Requirements
- `specs/[current-session]/tasks.md` - Task checklist
- `specs/[current-session]/implementation-notes.md` - Progress log
- `.spec_system/state.json` - Current session

### 2. Run Validation Checks

#### A. Task Completion
Verify all tasks in tasks.md are marked `[x]`:
- Count total tasks
- Count completed tasks
- List any incomplete tasks

#### B. Deliverables Check
From spec.md deliverables section:
- Verify each file exists
- Check file is non-empty
- Note any missing files

#### C. ASCII Encoding Check
For each deliverable file:
```bash
# Check encoding
file [filename]  # Should show: ASCII text

# Find non-ASCII characters
grep -P '[^\x00-\x7F]' [filename]
```
- Report any non-ASCII characters found
- Report any CRLF line endings

#### D. Test Verification
Run the project's test suite:
- Record total tests
- Record passed/failed
- Calculate coverage if available
- Note any failures

#### E. Success Criteria
From spec.md success criteria:
- Check each functional requirement
- Verify testing requirements met
- Confirm quality gates passed

### 3. Generate Validation Report

Create `validation.md` in the session directory:

```markdown
# Validation Report

**Session ID**: `phaseNN-sessionNN-name`
**Validated**: [DATE]
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

### 4. Report Results

Tell the user:
- Overall PASS/FAIL status
- Summary of each check
- Any issues found
- Next steps

## Validation Criteria

### PASS Requirements
All of these must be true:
- 100% of tasks completed
- All deliverable files exist
- All files ASCII-encoded with LF endings
- All tests passing
- All success criteria met

### FAIL Conditions
Any of these triggers FAIL:
- Incomplete tasks
- Missing deliverables
- Non-ASCII characters in files
- CRLF line endings
- Failing tests
- Unmet success criteria

## Handling Failures

If validation fails:

1. Clearly list all issues
2. Prioritize by severity
3. Suggest fixes
4. User can fix and re-run `/validate`

## Output

Create validation.md and report:
```
Validation Result: PASS

All checks passed:
- Tasks: 22/22 complete
- Files: 8/8 exist
- Encoding: All ASCII, LF endings
- Tests: 45/45 passing (98% coverage)
- Criteria: All met

Run `/updateprd` to mark session complete.
```

Or if failed:
```
Validation Result: FAIL

Issues found:
1. [Issue 1] - [how to fix]
2. [Issue 2] - [how to fix]

Fix issues and run `/validate` again.
```
