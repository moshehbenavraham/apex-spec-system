# Template Reference

This document provides quick reference for all templates used in the Apex Spec System.

## Session Specification (spec.md)

**Location**: `specs/phaseNN-sessionNN-name/spec.md`

### Header Fields

| Field | Format | Example |
|-------|--------|---------|
| Session ID | `phaseNN-sessionNN-name` | `phase01-session03-auth` |
| Phase | `NN - Phase Name` | `01 - Core Features` |
| Status | Not Started / In Progress / Complete | Not Started |
| Created | YYYY-MM-DD | 2025-01-15 |

### Required Sections

1. **Session Overview** - 2-3 paragraphs on purpose and context
2. **Objectives** - 3-5 specific, measurable objectives
3. **Prerequisites** - Required sessions, tools, environment
4. **Scope** - In scope (MVP) vs out of scope (deferred)
5. **Technical Approach** - Architecture, patterns, stack
6. **Deliverables** - Files to create/modify with line estimates
7. **Success Criteria** - Functional, testing, quality gates
8. **Implementation Notes** - Considerations, challenges, ASCII reminder
9. **Testing Strategy** - Unit, integration, manual, edge cases
10. **Dependencies** - External libraries, system requirements

---

## Task Checklist (tasks.md)

**Location**: `specs/phaseNN-sessionNN-name/tasks.md`

### Header Fields

| Field | Format | Example |
|-------|--------|---------|
| Session ID | `phaseNN-sessionNN-name` | `phase01-session03-auth` |
| Total Tasks | N | 22 |
| Estimated Duration | X-Y hours | 2-3 hours |
| Created | YYYY-MM-DD | 2025-01-15 |

### Task Format

```markdown
- [ ] TNNN [SNNMM] [P] Description (`path/to/file`)
```

| Component | Description | Example |
|-----------|-------------|---------|
| Checkbox | Status indicator | `[ ]` or `[x]` |
| TNNN | Task ID | T001, T015 |
| [SNNMM] | Session reference | [S0103] |
| [P] | Parallelization marker (optional) | [P] |
| Description | Action verb + what | Create user model |
| Path | File being changed | `src/models/user.ts` |

### Categories

| Category | Task Count | Purpose |
|----------|------------|---------|
| Setup | 2-4 | Environment, directories, config |
| Foundation | 4-8 | Core types, interfaces, base classes |
| Implementation | 8-15 | Main feature logic |
| Testing | 3-5 | Tests, validation, verification |

### Progress Summary Table

```markdown
| Category | Total | Done | Remaining |
|----------|-------|------|-----------|
| Setup | N | 0 | N |
| Foundation | N | 0 | N |
| Implementation | N | 0 | N |
| Testing | N | 0 | N |
| **Total** | **N** | **0** | **N** |
```

---

## Implementation Notes (implementation-notes.md)

**Location**: `specs/phaseNN-sessionNN-name/implementation-notes.md`

### Header Fields

| Field | Format | Example |
|-------|--------|---------|
| Session ID | `phaseNN-sessionNN-name` | `phase01-session03-auth` |
| Started | YYYY-MM-DD HH:MM | 2025-01-15 09:00 |
| Last Updated | YYYY-MM-DD HH:MM | 2025-01-15 11:30 |

### Session Progress Table

```markdown
| Metric | Value |
|--------|-------|
| Tasks Completed | 0 / N |
| Estimated Remaining | X hours |
| Blockers | 0 |
```

### Task Log Entry Format

```markdown
### Task TNNN - [Description]

**Started**: HH:MM
**Completed**: HH:MM
**Duration**: X minutes

**Notes**:
- Implementation detail 1
- Decision made

**Files Changed**:
- `path/to/file` - changes made
```

### Blocker Entry Format

```markdown
### Blocker N: [Title]

**Description**: What's blocking
**Impact**: Which tasks affected
**Resolution**: How resolved / workaround
**Time Lost**: Duration
```

### Design Decision Format

```markdown
### Decision N: [Title]

**Context**: Why decision needed
**Options Considered**:
1. Option A - pros/cons
2. Option B - pros/cons

**Chosen**: Option
**Rationale**: Why
```

---

## Validation Report (validation.md)

**Location**: `specs/phaseNN-sessionNN-name/validation.md`

### Header Fields

| Field | Format | Example |
|-------|--------|---------|
| Session ID | `phaseNN-sessionNN-name` | `phase01-session03-auth` |
| Validated | YYYY-MM-DD | 2025-01-15 |
| Result | PASS / FAIL | PASS |

### Validation Summary Table

```markdown
| Check | Status | Notes |
|-------|--------|-------|
| Tasks Complete | PASS/FAIL | X/Y tasks |
| Files Exist | PASS/FAIL | X/Y files |
| ASCII Encoding | PASS/FAIL | [issues] |
| Tests Passing | PASS/FAIL | X/Y tests |
| Quality Gates | PASS/FAIL | [issues] |
```

### Check Sections

1. **Task Completion** - Category breakdown, incomplete list
2. **Deliverables Verification** - File existence check
3. **ASCII Encoding Check** - Encoding and line ending verification
4. **Test Results** - Total, passed, failed, coverage
5. **Success Criteria** - Functional, testing, quality gates

---

## Next Session Recommendation (NEXT_SESSION.md)

**Location**: `NEXT_SESSION.md` (project root)

### Header Fields

| Field | Format | Example |
|-------|--------|---------|
| Generated | YYYY-MM-DD | 2025-01-15 |
| Project State | Phase N - Name | Phase 1 - Core |
| Completed Sessions | count | 5 |

### Required Sections

1. **Recommended Session** - ID, name, duration, task estimate
2. **Why This Session** - Prerequisites, dependencies, progression
3. **Session Overview** - Objective, deliverables, scope
4. **Technical Considerations** - Technologies, challenges
5. **Alternative Sessions** - Backup options if blocked

---

## Phase PRD (PRD_phase_NN.md)

**Location**: `PRD/PRD_phase_NN.md`

### Header Fields

| Field | Format | Example |
|-------|--------|---------|
| Status | Not Started / In Progress / Complete | Not Started |
| Sessions | N (estimated) | 5 |
| Duration | X-Y days | 5-7 days |

### Required Sections

1. **Phase Overview** - Purpose and importance
2. **Objectives** - Primary, secondary, tertiary
3. **Prerequisites** - Previous phases, requirements
4. **Sessions Table** - ID, name, status, task estimate
5. **Session Details** - Scope and deliverables per session
6. **Technical Considerations** - Architecture, technologies, risks
7. **Success Criteria** - Phase completion requirements
8. **Dependencies** - What phase depends on and enables

---

## Phase README (README.md)

**Location**: `PRD/phase_NN/README.md`

### Header Fields

| Field | Format | Example |
|-------|--------|---------|
| Status | Not Started / In Progress / Complete | In Progress |
| Progress | N/M sessions (X%) | 3/5 (60%) |

### Required Sections

1. **Overview** - Phase description
2. **Progress Tracker** - Session status table
3. **Completed Sessions** - List with dates
4. **Upcoming Sessions** - Next session info
5. **Links** - Phase PRD, specs directory

---

## Session Stub (session_NN_name.md)

**Location**: `PRD/phase_NN/session_NN_name.md`

### Header Fields

| Field | Format | Example |
|-------|--------|---------|
| Session ID | `phaseNN-sessionNN-name` | `phase01-session03-auth` |
| Status | Not Started | Not Started |
| Tasks | ~N | ~20 |
| Duration | X-Y hours | 2-3 hours |

### Required Sections

1. **Objective** - Single clear objective
2. **Scope** - In scope (MVP), out of scope
3. **Prerequisites** - Required completions
4. **Deliverables** - What will be created
5. **Success Criteria** - Completion requirements

---

## Implementation Summary (IMPLEMENTATION_SUMMARY.md)

**Location**: `specs/phaseNN-sessionNN-name/IMPLEMENTATION_SUMMARY.md`

### Header Fields

| Field | Format | Example |
|-------|--------|---------|
| Session ID | `phaseNN-sessionNN-name` | `phase01-session03-auth` |
| Completed | YYYY-MM-DD | 2025-01-15 |
| Duration | X hours | 2.5 hours |

### Required Sections

1. **Overview** - Brief summary of accomplishments
2. **Deliverables** - Files created and modified
3. **Technical Decisions** - Key decisions with rationale
4. **Test Results** - Test metrics and coverage
5. **Lessons Learned** - Insights from implementation
6. **Future Considerations** - Items for future sessions
7. **Session Statistics** - Tasks, files, tests, blockers
