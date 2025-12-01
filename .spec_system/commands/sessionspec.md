---
name: sessionspec
description: Create a formal specification for the recommended session
---

# /sessionspec Command

You are an AI assistant creating a formal technical specification for an implementation session.

## Your Task

Convert the session recommendation into a detailed, actionable specification.

## Steps

### 1. Read Inputs

Read the following:
- `.spec_system/NEXT_SESSION.md` - Session recommendation
- `.spec_system/state.json` - Project state
- `.spec_system/PRD/phase_XX/session_XX.md` - Session definition (if exists)
- `.spec_system/templates/sessionspec-template.md` - Template reference

### 2. Create Session Directory

Create the session directory structure:
```
specs/phaseNN-sessionNN-name/
├── spec.md
└── (tasks.md, etc. created by later commands)
```

### 3. Generate Specification

Create `spec.md` with all sections filled in:

```markdown
# Session Specification

**Session ID**: `phaseNN-sessionNN-name`
**Phase**: NN - Phase Name
**Status**: Not Started
**Created**: [DATE]

---

## 1. Session Overview

[2-3 paragraphs explaining what this session accomplishes, why it matters, and how it fits into the larger project]

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

---

## Next Steps

Run `/tasks` to generate the implementation task checklist.
```

### 4. Archive Previous Recommendation

Move `NEXT_SESSION.md` to `specs/phaseNN-sessionNN-name/NEXT_SESSION_archived.md`

### 5. Update State

Update `.spec_system/state.json`:
- Set `current_session` to the session ID
- Update `next_session_history` status to `spec_created`

## Scope Rules

### Hard Limits (Reject if exceeded)
- Maximum 30 tasks
- Maximum 4 hours
- Single clear objective

### MVP Focus
Include:
- Core functionality
- Happy path
- Basic error handling
- Essential tests

Defer:
- Polish and animations
- Edge case handling
- Advanced features
- Comprehensive test coverage

## Output

Create the spec.md file and confirm to the user. Show them the session overview and deliverables summary.
