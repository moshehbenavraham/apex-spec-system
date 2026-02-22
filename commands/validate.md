---
name: validate
description: Verify session completeness and quality gates
---

# /validate Command

Verify that all session requirements are met before marking the session complete.

## Rules

1. **PASS requires ALL of**: 100% tasks complete, all deliverables exist, all files ASCII-encoded with LF endings, all tests passing, all success criteria met
2. **Any single failure = overall FAIL** - no partial passes
3. **Script first** - run `analyze-project.sh --json` before any analysis
4. Conventions compliance is a spot-check, not exhaustive - flag obvious violations only

### No Deferral Policy

- If a validation check fails and YOU can fix it (encoding issues, missing directories, failing tests with obvious fixes), FIX IT and re-validate
- The ONLY valid reason to report a FAIL back to the user is when the fix requires their input, credentials, or decisions only a human can make
- "The environment isn't set up" is NOT a valid FAIL -- setting it up IS the task
- If you report a FAIL for something you could have fixed, that is a **critical failure**

## Steps

### 1. Get Deterministic Project State (REQUIRED FIRST STEP)

Run the analysis script to get reliable state facts. Local scripts (`.spec_system/scripts/`) take precedence over plugin scripts if they exist:

```bash
# Check for local scripts first, fall back to plugin
if [ -d ".spec_system/scripts" ]; then
  bash .spec_system/scripts/analyze-project.sh --json
else
  bash ${CLAUDE_PLUGIN_ROOT}/scripts/analyze-project.sh --json
fi
```

This returns structured JSON including:
- `current_session` - The session to validate
- `current_session_dir_exists` - Whether specs directory exists
- `current_session_files` - Files already in the session directory

**IMPORTANT**: Use the `current_session` value from this output. If `current_session` is `null`, run `/nextsession` yourself to set one up. Only ask the user if `/nextsession` itself requires user input.

### 2. Read Session Files

Using the `current_session` value from the script output, read all session documents:
- `.spec_system/specs/[current-session]/spec.md` - Requirements
- `.spec_system/specs/[current-session]/tasks.md` - Task checklist
- `.spec_system/specs/[current-session]/implementation-notes.md` - Progress log
- `.spec_system/CONVENTIONS.md` - Project coding conventions (if exists)

**CONVENTIONS.md** is used in the Quality Gates check (section 3.E) to verify code follows project conventions for naming, structure, error handling, testing, etc.

### 3. Run Validation Checks

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

# Find non-ASCII characters (GNU grep)
grep -P '[^\x00-\x7F]' [filename]

# Alternative for macOS/BSD (using LC_ALL)
LC_ALL=C grep '[^[:print:][:space:]]' [filename]

# Check for CRLF line endings
grep -l $'\r' [filename]
```
- Report any non-ASCII characters found
- Report any CRLF line endings

#### D. Test Verification
Run the project's test suite:
- Record total tests
- Record passed/failed
- Calculate coverage if available
- Note any failures

**CRITICAL -- NO "PRE-EXISTING" EXCUSE**: If ANY test fails, you MUST:
1. Investigate the root cause -- determine whether the session's changes caused or contributed to the failure
2. NEVER dismiss a failure as "pre-existing" or "environment issue" -- if tests passed before this session and fail now, THIS SESSION BROKE THEM
3. FIX the failure before continuing validation. If you changed a Docker image, a dependency, a config file, or any shared code, failures in existing tests are YOUR responsibility
4. Only after all tests pass (0 failures) may you mark Test Verification as PASS
5. If a failure is genuinely unrelated (e.g., flaky network test), you must PROVE it by showing the test also fails on the pre-session commit -- do not assume

#### E. Success Criteria
From spec.md success criteria:
- Check each functional requirement
- Verify testing requirements met
- Confirm quality gates passed

#### F. Conventions Compliance (if CONVENTIONS.md exists)
Spot-check deliverables against project conventions:
- **Naming**: Functions, variables, files follow naming conventions
- **Structure**: Files are organized according to file structure conventions
- **Error Handling**: Follows the project's error handling approach
- **Comments**: Explain "why" not "what", no commented-out code
- **Testing**: Tests follow project testing philosophy

Note: This is a spot-check, not exhaustive. Flag obvious violations only.

### 4. Generate Validation Report

Create `validation.md` in the session directory:

```markdown
# Validation Report

**Session ID**: `phase_NN_session_NN_name`
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

### 5. Update State

Update `.spec_system/state.json` based on validation result:

**If PASS:**
```json
{
  "current_session": "phase_NN_session_NN_name",
  "next_session_history": [
    {
      "date": "YYYY-MM-DD",
      "session": "phase_NN_session_NN_name",
      "status": "validated"
    }
  ]
}
```

**If FAIL:**
```json
{
  "next_session_history": [
    {
      "date": "YYYY-MM-DD",
      "session": "phase_NN_session_NN_name",
      "status": "validation_failed"
    }
  ]
}
```

- Update `next_session_history` entry status to `validated` or `validation_failed`

## Output

Report PASS/FAIL with a summary of each check. If PASS, prompt `/updateprd`. If FAIL, list issues with suggested fixes and prompt re-run of `/validate`.
