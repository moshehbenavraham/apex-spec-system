---
name: implement
description: AI-guided task-by-task implementation of the current session
---

# /implement Command

You are an AI assistant implementing a session specification task by task.

## Your Task

Guide the implementation of each task in the session's task list, updating progress as you go.

## Steps

### 1. Read Session Context

Read the following files:
- `specs/[current-session]/spec.md` - Full specification
- `specs/[current-session]/tasks.md` - Task checklist
- `specs/[current-session]/implementation-notes.md` - Progress log (if exists)
- `state.json` - Current session

### 2. Initialize Implementation Notes

If `implementation-notes.md` doesn't exist, create it:

```markdown
# Implementation Notes

**Session ID**: `phaseNN-sessionNN-name`
**Started**: [DATE]
**Last Updated**: [DATE]

---

## Session Progress

| Metric | Value |
|--------|-------|
| Tasks Completed | 0 / N |
| Estimated Remaining | X hours |
| Blockers | 0 |

---

## Task Log

### [DATE] - Session Start

**Environment verified**:
- [x] Prerequisites confirmed
- [x] Tools available
- [x] Directory structure ready

---
```

### 3. Work Through Tasks

For each incomplete task:

#### A. Identify Next Task
Find the first unchecked `- [ ]` task in tasks.md

#### B. Implement Task
- Read the task description carefully
- Implement the required changes
- Follow the spec's technical approach
- Ensure ASCII-only output

#### C. Update Task Status
In `tasks.md`, change:
```markdown
- [ ] T001 [S0101] Task description
```
To:
```markdown
- [x] T001 [S0101] Task description
```

#### D. Log Progress
Add to `implementation-notes.md`:
```markdown
### Task TNNN - [Description]

**Started**: [TIME]
**Completed**: [TIME]
**Duration**: [X] minutes

**Notes**:
- [Implementation details]
- [Decisions made]

**Files Changed**:
- `path/to/file` - [changes made]
```

### 4. Handle Blockers

If you encounter a blocker:

1. Document in implementation-notes.md:
```markdown
## Blockers & Solutions

### Blocker N: [Title]

**Description**: [What's blocking]
**Impact**: [Which tasks affected]
**Resolution**: [How resolved / workaround]
**Time Lost**: [Duration]
```

2. Either:
   - Resolve and continue
   - Skip and document for later
   - Ask user for guidance

### 5. Track Design Decisions

When making implementation choices:

```markdown
## Design Decisions

### Decision N: [Title]

**Context**: [Why decision needed]
**Options Considered**:
1. [Option A] - [pros/cons]
2. [Option B] - [pros/cons]

**Chosen**: [Option]
**Rationale**: [Why]
```

### 6. Continuous Progress Updates

After each task or group of tasks:
- Update the Progress Summary table in tasks.md
- Update implementation-notes.md Session Progress
- Inform user of status

## Implementation Rules

### Code Quality
- Follow project conventions
- ASCII-only characters
- Unix LF line endings
- Clear, readable code
- Appropriate comments (not excessive)

### Scope Discipline
- Implement exactly what's in the spec
- Don't add extra features
- Don't refactor unrelated code
- MVP focus

### Testing
- Write tests as specified
- Ensure tests pass
- Document test results

### Progress Communication
After completing tasks, report:
- Tasks done (X of Y)
- Current progress percentage
- Next task preview
- Any blockers or concerns

## Resuming Implementation

If implementation was interrupted:
1. Read implementation-notes.md for context
2. Check tasks.md for last completed task
3. Resume from next incomplete task
4. Continue logging progress

## Output

As you implement:
1. Show task being worked on
2. Show implementation progress
3. Mark tasks complete in tasks.md
4. Update implementation-notes.md
5. Report status to user

When all tasks complete:
```
Session implementation complete!
Tasks: N/N (100%)

Run `/validate` to verify session completeness.
```
