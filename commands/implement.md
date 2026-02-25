---
name: implement
description: AI-led task-by-task implementation of the current session
---

# /implement Command

Execute each task in the session's task list, updating progress as you go.

## Rules

1. **Make NO assumptions.** Do not be lazy. Pattern match precisely. Do not skim when you need detailed info. Validate systematically.
2. **Follow CONVENTIONS.md** - all code must follow project-specific coding standards
3. **ASCII-only characters** and Unix LF line endings in all output
4. **Implement exactly what's in the spec** - no extra features, no refactoring unrelated code
5. **Update tasks.md immediately** after completing each task - never batch checkbox updates
6. **Write tests as specified** - ensure they pass before moving on
7. **Ensure logging and error handling** - no silent failures

### No Deferral Policy

- NEVER mark a task as "pending", "requires X", or "blocked" if the blocker is something YOU can resolve
- If a service needs to be running, START IT (e.g., `docker compose up -d db`)
- If a dependency needs installing, INSTALL IT
- If a directory needs creating, CREATE IT
- "The environment isn't set up" is NOT a blocker -- setting it up IS the task
- The ONLY valid blocker is something that requires USER input or credentials you don't have
- If you skip a task that was executable, that is a **critical failure**

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
- `current_session` - The session to implement
- `current_session_dir_exists` - Whether specs directory exists
- `current_session_files` - Files already in the session directory

**IMPORTANT**: Use the `current_session` value from this output. If `current_session` is `null`, run `/plansession` yourself to set one up. Only ask the user if that command requires user input.

### 2. Verify Environment Prerequisites (REQUIRED)

Run the prerequisite checker to verify the environment is ready. Use the same local-first pattern:

```bash
# Check for local scripts first, fall back to plugin
if [ -d ".spec_system/scripts" ]; then
  bash .spec_system/scripts/check-prereqs.sh --json --env
else
  bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-prereqs.sh --json --env
fi
```

This verifies:
- `.spec_system/` directory and `state.json` are valid
- `jq` is installed (required for scripts)
- `git` availability (optional)

**If any environment check fails**: FIX the issues yourself. Install missing tools, create missing directories, start required services. The ONLY reason to stop is if you need credentials or input only the user can provide.

**Optional - Tool Verification**: After reading spec.md (next step), if the Prerequisites section lists required tools, also run:

```bash
# Check for local scripts first, fall back to plugin
if [ -d ".spec_system/scripts" ]; then
  bash .spec_system/scripts/check-prereqs.sh --json --tools "tool1,tool2,tool3"
else
  bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-prereqs.sh --json --tools "tool1,tool2,tool3"
fi
```

This catches missing tools BEFORE implementation starts, preventing mid-session failures.

### 3. Read Session Context

Using the `current_session` value from the script output, read:
- `.spec_system/specs/[current-session]/spec.md` - Full specification
- `.spec_system/specs/[current-session]/tasks.md` - Task checklist
- `.spec_system/specs/[current-session]/implementation-notes.md` - Progress log (if exists)
- `.spec_system/specs/[current-session]/security-compliance.md` - Prior security report (if exists from previous validation run)
- `.spec_system/CONVENTIONS.md` - Project coding conventions (if exists)

**Resuming?** If `implementation-notes.md` and completed tasks already exist, read them to understand current state and resume from the next incomplete task.

### 4. Initialize Implementation Notes

If `implementation-notes.md` doesn't exist, create it:

```markdown
# Implementation Notes

**Session ID**: `phase_NN_session_NN_name`
**Started**: [YYYY-MM-DD HH:MM]
**Last Updated**: [YYYY-MM-DD HH:MM]

---

## Session Progress

| Metric | Value |
|--------|-------|
| Tasks Completed | 0 / N |
| Estimated Remaining | X hours |
| Blockers | 0 |

---

## Task Log

### [YYYY-MM-DD] - Session Start

**Environment verified**:
- [x] Prerequisites confirmed
- [x] Tools available
- [x] Directory structure ready

---
```

### 5. Work Through Tasks

For each incomplete task:

#### A. Identify Next Task
Find the first unchecked `- [ ]` task in tasks.md

#### B. Implement Task
- Read the task description carefully
- Follow the spec's technical approach and CONVENTIONS.md standards
- Implement the required changes

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
Add to `.spec_system/specs/[current-session]/implementation-notes.md`:
```markdown
### Task TNNN - [Description]

**Started**: [YYYY-MM-DD HH:MM]
**Completed**: [YYYY-MM-DD HH:MM]
**Duration**: [X] minutes

**Notes**:
- [Implementation details]
- [Decisions made]

**Files Changed**:
- `path/to/file` - [changes made]
```

### 6. Handle Blockers

If you encounter an obstacle, RESOLVE IT YOURSELF before documenting:

- **Service not running?** Start it (e.g., `docker compose up -d db`)
- **Dependency missing?** Install it
- **Directory missing?** Create it
- **Config file missing?** Generate it from the spec
- **"The environment isn't set up"** is NOT a blocker -- setting it up IS the task

The ONLY valid reason to pause and ask the user is when you need credentials, API keys, or decisions only a human can make. If you skip a task that was executable, that is a **critical failure**.

After resolving, document in implementation-notes.md:
```markdown
## Blockers & Solutions

### Blocker N: [Title]

**Description**: [What was blocking]
**Impact**: [Which tasks affected]
**Resolution**: [How YOU resolved it]
**Time Lost**: [Duration]
```

### 7. Track Design Decisions

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

### 8. Track Progress and Checkpoint

After each task:
- Update Progress Summary table in tasks.md
- Update implementation-notes.md
- Report status to user: tasks done (X of Y), next task

**Checkpoint every 3-5 tasks minimum** and before any risky operations. If approaching context limits, document current state and next task in implementation-notes.md.

## Output

When all tasks complete:
```
Session implementation complete!
Tasks: N/N (100%)

Run `/validate` to verify session completeness.
```
