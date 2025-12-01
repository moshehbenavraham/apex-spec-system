# Session Specification

**Session ID**: `{{SESSION_ID}}`
**Phase**: {{PHASE_NUM}} - {{PHASE_NAME}}
**Status**: Not Started
**Created**: {{DATE}}

---

## 1. Session Overview

{{OVERVIEW_PARAGRAPH_1}}

{{OVERVIEW_PARAGRAPH_2}}

---

## 2. Objectives

1. {{OBJECTIVE_1}}
2. {{OBJECTIVE_2}}
3. {{OBJECTIVE_3}}
4. {{OBJECTIVE_4}}

---

## 3. Prerequisites

### Required Sessions
- [ ] {{PREREQ_SESSION_1}} - {{PREREQ_REASON_1}}
- [ ] {{PREREQ_SESSION_2}} - {{PREREQ_REASON_2}}

### Required Tools/Knowledge
- {{TOOL_1}}
- {{TOOL_2}}

### Environment Requirements
- {{ENV_REQ_1}}
- {{ENV_REQ_2}}

---

## 4. Scope

### In Scope (MVP)
- {{SCOPE_IN_1}}
- {{SCOPE_IN_2}}
- {{SCOPE_IN_3}}
- {{SCOPE_IN_4}}

### Out of Scope (Deferred)
- {{SCOPE_OUT_1}} - *Reason: {{DEFER_REASON_1}}*
- {{SCOPE_OUT_2}} - *Reason: {{DEFER_REASON_2}}*
- {{SCOPE_OUT_3}} - *Reason: {{DEFER_REASON_3}}*

---

## 5. Technical Approach

### Architecture
{{ARCHITECTURE_DESCRIPTION}}

### Design Patterns
- {{PATTERN_1}}: {{PATTERN_REASON_1}}
- {{PATTERN_2}}: {{PATTERN_REASON_2}}

### Technology Stack
- {{TECH_1}}
- {{TECH_2}}
- {{TECH_3}}

---

## 6. Deliverables

### Files to Create
| File | Purpose | Est. Lines |
|------|---------|------------|
| {{FILE_1}} | {{PURPOSE_1}} | {{LINES_1}} |
| {{FILE_2}} | {{PURPOSE_2}} | {{LINES_2}} |
| {{FILE_3}} | {{PURPOSE_3}} | {{LINES_3}} |

### Files to Modify
| File | Changes | Est. Lines Changed |
|------|---------|-------------------|
| {{MOD_FILE_1}} | {{MOD_CHANGES_1}} | {{MOD_LINES_1}} |

---

## 7. Success Criteria

### Functional Requirements
- [ ] {{FUNC_REQ_1}}
- [ ] {{FUNC_REQ_2}}
- [ ] {{FUNC_REQ_3}}

### Testing Requirements
- [ ] Unit tests written and passing
- [ ] Integration tests (if applicable)
- [ ] Manual testing completed

### Quality Gates
- [ ] All files ASCII-encoded (no Unicode)
- [ ] Unix LF line endings
- [ ] Code follows project conventions
- [ ] No linting errors

---

## 8. Implementation Notes

### Key Considerations
- {{CONSIDERATION_1}}
- {{CONSIDERATION_2}}

### Potential Challenges
- {{CHALLENGE_1}}: {{MITIGATION_1}}
- {{CHALLENGE_2}}: {{MITIGATION_2}}

### ASCII Reminder
All output files must use ASCII-only characters (0-127). No Unicode, emoji, or smart quotes.

---

## 9. Testing Strategy

### Unit Tests
- {{UNIT_TEST_1}}
- {{UNIT_TEST_2}}

### Integration Tests
- {{INTEGRATION_TEST_1}}

### Manual Testing
- {{MANUAL_TEST_1}}
- {{MANUAL_TEST_2}}

### Edge Cases
- {{EDGE_CASE_1}}
- {{EDGE_CASE_2}}

---

## 10. Dependencies

### External Libraries
- {{LIB_1}}: {{LIB_VERSION_1}}
- {{LIB_2}}: {{LIB_VERSION_2}}

### System Requirements
- {{SYS_REQ_1}}

### Other Sessions
- **Depends on**: {{DEPENDS_ON}}
- **Depended by**: {{DEPENDED_BY}}

---

## Next Steps

Run `/tasks` to generate the implementation task checklist.
