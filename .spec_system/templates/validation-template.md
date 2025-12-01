# Validation Report

**Session ID**: `{{SESSION_ID}}`
**Validated**: {{DATE}}
**Result**: {{RESULT}} <!-- PASS or FAIL -->

---

## Validation Summary

| Check | Status | Notes |
|-------|--------|-------|
| Tasks Complete | {{TASK_STATUS}} | {{TASK_NOTES}} |
| Files Exist | {{FILE_STATUS}} | {{FILE_NOTES}} |
| ASCII Encoding | {{ASCII_STATUS}} | {{ASCII_NOTES}} |
| Tests Passing | {{TEST_STATUS}} | {{TEST_NOTES}} |
| Quality Gates | {{QUALITY_STATUS}} | {{QUALITY_NOTES}} |

**Overall**: {{RESULT}}

---

## 1. Task Completion

### Status: {{TASK_STATUS}}

| Category | Required | Completed | Status |
|----------|----------|-----------|--------|
| Setup | {{SETUP_REQ}} | {{SETUP_DONE}} | {{SETUP_STATUS}} |
| Foundation | {{FOUND_REQ}} | {{FOUND_DONE}} | {{FOUND_STATUS}} |
| Implementation | {{IMPL_REQ}} | {{IMPL_DONE}} | {{IMPL_STATUS}} |
| Testing | {{TEST_REQ}} | {{TEST_DONE}} | {{TEST_STATUS}} |

### Incomplete Tasks
{{INCOMPLETE_TASKS}}

---

## 2. Deliverables Verification

### Status: {{FILE_STATUS}}

#### Files Created
| File | Expected | Found | Status |
|------|----------|-------|--------|
| {{FILE_1}} | Yes | {{FOUND_1}} | {{STATUS_1}} |
| {{FILE_2}} | Yes | {{FOUND_2}} | {{STATUS_2}} |
| {{FILE_3}} | Yes | {{FOUND_3}} | {{STATUS_3}} |

#### Files Modified
| File | Changes Expected | Verified | Status |
|------|-----------------|----------|--------|
| {{MOD_1}} | {{EXPECTED_1}} | {{VERIFIED_1}} | {{MOD_STATUS_1}} |

### Missing Deliverables
{{MISSING_FILES}}

---

## 3. ASCII Encoding Check

### Status: {{ASCII_STATUS}}

```
Validation Command: grep -rP '[^\x00-\x7F]' <files>
```

#### Results
| File | Encoding | Line Endings | Status |
|------|----------|--------------|--------|
| {{FILE_1}} | {{ENC_1}} | {{EOL_1}} | {{ENC_STATUS_1}} |
| {{FILE_2}} | {{ENC_2}} | {{EOL_2}} | {{ENC_STATUS_2}} |

### Encoding Issues Found
{{ENCODING_ISSUES}}

---

## 4. Test Results

### Status: {{TEST_STATUS}}

#### Test Summary
| Metric | Value |
|--------|-------|
| Total Tests | {{TOTAL_TESTS}} |
| Passed | {{PASSED_TESTS}} |
| Failed | {{FAILED_TESTS}} |
| Skipped | {{SKIPPED_TESTS}} |
| Coverage | {{COVERAGE}}% |

#### Failed Tests
{{FAILED_TEST_LIST}}

#### Test Output
```
{{TEST_OUTPUT}}
```

---

## 5. Quality Gates

### Status: {{QUALITY_STATUS}}

| Gate | Requirement | Actual | Status |
|------|-------------|--------|--------|
| Linting | No errors | {{LINT_ERRORS}} | {{LINT_STATUS}} |
| Type Check | No errors | {{TYPE_ERRORS}} | {{TYPE_STATUS}} |
| Code Style | Consistent | {{STYLE_ISSUES}} | {{STYLE_STATUS}} |
| Documentation | Complete | {{DOC_STATUS}} | {{DOC_CHECK}} |

### Quality Issues
{{QUALITY_ISSUES}}

---

## 6. Success Criteria

From spec.md:

### Functional Requirements
- [{{FC_1}}] {{FUNC_CRITERIA_1}}
- [{{FC_2}}] {{FUNC_CRITERIA_2}}
- [{{FC_3}}] {{FUNC_CRITERIA_3}}

### Testing Requirements
- [{{TC_1}}] Unit tests written and passing
- [{{TC_2}}] Integration tests (if applicable)
- [{{TC_3}}] Manual testing completed

### Quality Gates
- [{{QC_1}}] All files ASCII-encoded
- [{{QC_2}}] Unix LF line endings
- [{{QC_3}}] Code follows project conventions
- [{{QC_4}}] No linting errors

---

## 7. Validation Result

### {{RESULT}}

{{RESULT_SUMMARY}}

### Required Actions (if FAIL)
{{REQUIRED_ACTIONS}}

---

## Next Steps

{{NEXT_STEPS}}
