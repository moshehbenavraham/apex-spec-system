---
name: phasebuild
description: Create structure for a new phase
---

# /phasebuild Command

You are an AI assistant creating the structure for a new project phase.

## Your Task

Set up the directory structure and documentation for a new phase.

## Steps

### 1. Gather Phase Information

Ask the user for (or derive from PRD):
- Phase number (next sequential)
- Phase name
- Phase description
- Estimated session count
- High-level objectives

### 2. Create Phase Directory

Create `.spec_system/PRD/phase_NN/`:
```
.spec_system/PRD/phase_NN/
├── README.md
├── session_01_name.md
├── session_02_name.md
└── ...
```

### 3. Create Phase PRD

Create `PRD_phase_NN.md` (or in phase directory):

```markdown
# PRD Phase NN: Phase Name

**Status**: Not Started
**Sessions**: N (estimated)
**Estimated Duration**: X-Y days

---

## Phase Overview

[Description of what this phase accomplishes and why it matters]

---

## Objectives

1. [Primary objective]
2. [Secondary objective]
3. [Tertiary objective]

---

## Prerequisites

- Phase NN-1 completed
- [Other prerequisites]

---

## Sessions

| # | Session ID | Name | Status | Est. Tasks |
|---|------------|------|--------|------------|
| 1 | `phaseNN-session01-name` | Title | Not Started | ~20 |
| 2 | `phaseNN-session02-name` | Title | Not Started | ~20 |
| 3 | `phaseNN-session03-name` | Title | Not Started | ~20 |

---

## Session Details

### Session 1: [Title]

**ID**: `phaseNN-session01-name`
**Estimated Tasks**: ~20

**Scope**:
- [Scope item 1]
- [Scope item 2]

**Deliverables**:
- [Deliverable 1]
- [Deliverable 2]

---

### Session 2: [Title]

[Same format...]

---

## Technical Considerations

### Architecture
[Architecture notes for this phase]

### Technologies
- [Technology 1]
- [Technology 2]

### Risks
- [Risk 1]: [Mitigation]

---

## Success Criteria

Phase complete when:
- [ ] All N sessions completed
- [ ] [Criterion 1]
- [ ] [Criterion 2]

---

## Dependencies

### Depends On
- Phase NN-1: [Name]

### Enables
- Phase NN+1: [Name]
```

### 4. Create Phase README

Create `.spec_system/PRD/phase_NN/README.md`:

```markdown
# Phase NN: Phase Name

**Status**: Not Started
**Progress**: 0/N sessions (0%)

---

## Overview

[Phase description]

---

## Progress Tracker

| Session | Name | Status | Validated |
|---------|------|--------|-----------|
| 01 | [Name] | Not Started | - |
| 02 | [Name] | Not Started | - |
| 03 | [Name] | Not Started | - |

---

## Completed Sessions

[None yet]

---

## Upcoming Sessions

- Session 01: [Name]

---

## Links

- [Phase PRD](./PRD_phase_NN.md)
- [Specs Directory](../../specs/)
```

### 5. Create Session Stubs

For each session, create `session_NN_name.md`:

```markdown
# Session NN: Session Name

**Session ID**: `phaseNN-sessionNN-name`
**Status**: Not Started
**Estimated Tasks**: ~20
**Estimated Duration**: 2-3 hours

---

## Objective

[Clear single objective for this session]

---

## Scope

### In Scope (MVP)
- [Feature 1]
- [Feature 2]

### Out of Scope
- [Deferred item 1]

---

## Prerequisites

- [ ] [Prerequisite 1]

---

## Deliverables

1. [Deliverable 1]
2. [Deliverable 2]

---

## Success Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
```

### 6. Update State

Update `.spec_system/state.json`:

```json
{
  "phases": {
    "NN": {
      "name": "Phase Name",
      "description": "Phase description",
      "status": "not_started",
      "session_count": N
    }
  }
}
```

### 7. Update Master PRD

Add phase reference to `.spec_system/PRD/PRD.md`:

```markdown
## Phases

| Phase | Name | Sessions | Status |
|-------|------|----------|--------|
| ... | ... | ... | ... |
| NN | Phase Name | N | Not Started |
```

## Phase Planning Guidelines

### Session Count
- Typical phase: 4-8 sessions
- Small phase: 2-3 sessions
- Large phase: Consider splitting

### Session Sizing
- Each session: 15-30 tasks
- Each session: 2-4 hours
- Single clear objective per session

### Dependency Management
- Sessions within phase can depend on each other
- Early sessions provide foundation
- Later sessions build complexity

## Output

Report to user:

```
Phase NN Created: Phase Name

Structure:
- .spec_system/PRD/phase_NN/
  - README.md
  - session_01_name.md
  - session_02_name.md
  - session_03_name.md

State Updated:
- Phase added to state.json
- Master PRD updated

Sessions Defined: N

Next Steps:
- Review session definitions
- Adjust scope as needed
- Run `/nextsession` to begin
```
