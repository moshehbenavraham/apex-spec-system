---
name: sessionspec
description: Create a formal specification for the recommended session
---

# /sessionspec Command

Convert the session recommendation (`NEXT_SESSION.md`) into a detailed, actionable specification (`spec.md`).

## Rules

1. **ASCII-only characters** and Unix LF line endings in all output
2. **Hard limits**: max 25 tasks, max 4 hours, single clear objective
3. **Do not invent scope** - derive everything from NEXT_SESSION.md, PRD, and session stub
4. **Incorporate CONVENTIONS.md** - naming, file structure, and testing philosophy must be reflected in the spec
5. **Incorporate CONSIDERATIONS.md** - address relevant active concerns and lessons learned

## Steps

### 1. Read Inputs

Read the following:
- `.spec_system/NEXT_SESSION.md` - Session recommendation
- `.spec_system/state.json` - Project state
- `.spec_system/PRD/phase_NN/session_NN_name.md` - Session definition (if exists)
- `.spec_system/CONSIDERATIONS.md` - Institutional memory (if exists)
- `.spec_system/CONVENTIONS.md` - Project coding conventions (if exists)

Use CONSIDERATIONS.md to identify active concerns, relevant lessons, and tool notes. Use CONVENTIONS.md to inform naming, file placement, and testing approach in the spec.

### 2. Create Session Directory

Create the session directory structure:
```
.spec_system/specs/phaseNN-sessionNN-name/
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
**Created**: [YYYY-MM-DD]

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

### Relevant Considerations
<!-- From CONSIDERATIONS.md - omit section if none apply -->
- [P##] **[Active Concern]**: How it affects this session and mitigation
- [P##] **[Lesson Learned]**: How we're applying it in this implementation

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

Move `.spec_system/NEXT_SESSION.md` to `.spec_system/specs/phaseNN-sessionNN-name/NEXT_SESSION_archived.md`

### 5. Update State

Update `.spec_system/state.json`:

```json
{
  "current_session": "phaseNN-sessionNN-name",
  "next_session_history": [
    {
      "date": "YYYY-MM-DD",
      "session": "phaseNN-sessionNN-name",
      "status": "spec_created"
    }
  ]
}
```

- Set `current_session` to the session ID
- Update `next_session_history` entry status to `spec_created`

## Output

Create spec.md and confirm to the user. Show the session overview and deliverables summary.
