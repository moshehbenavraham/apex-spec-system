---
name: nextsession
description: Analyze project state and recommend the next session to implement
---

# /nextsession Command

You are an AI assistant helping to identify the next implementation session for a spec-driven project.

## Your Task

Analyze the current project state and recommend the most appropriate next session to implement.

## Steps

### 1. Read Project State

Read the following files to understand current progress:
- `.spec_system/state.json` - Current phase, completed sessions
- `.spec_system/PRD/PRD.md` - Master project requirements
- `.spec_system/PRD/phase_XX/` - Current phase session definitions

### 2. Analyze Progress

Determine:
- Current phase and its status
- Which sessions are completed
- Which sessions have unmet prerequisites
- Natural next session based on dependencies

### 3. Evaluate Candidates

For each candidate session:
- Check prerequisites are met
- Verify dependencies completed
- Assess complexity and scope
- Consider logical flow

### 4. Generate Recommendation

Create `NEXT_SESSION.md` in `.spec_system/` with:

```markdown
# NEXT_SESSION.md

## Session Recommendation

**Generated**: [DATE]
**Project State**: Phase [N] - [Name]
**Completed Sessions**: [count]

---

## Recommended Next Session

**Session ID**: `phaseNN-sessionNN-name`
**Session Name**: [Title]
**Estimated Duration**: [X-Y] hours
**Estimated Tasks**: [N]

---

## Why This Session Next?

### Prerequisites Met
- [x] [prerequisite 1]
- [x] [prerequisite 2]

### Dependencies
- **Builds on**: [previous session]
- **Enables**: [future session]

### Project Progression
[Explain why this is the logical next step]

---

## Session Overview

### Objective
[Clear single objective]

### Key Deliverables
1. [deliverable 1]
2. [deliverable 2]
3. [deliverable 3]

### Scope Summary
- **In Scope (MVP)**: [what's included]
- **Out of Scope**: [what's deferred]

---

## Technical Considerations

### Technologies/Patterns
- [tech 1]
- [tech 2]

### Potential Challenges
- [challenge 1]
- [challenge 2]

---

## Alternative Sessions

If this session is blocked:
1. **[alt session]** - [reason]
2. **[alt session]** - [reason]

---

## Next Steps

Run `/sessionspec` to generate the formal specification.
```

### 5. Update State

Update `.spec_system/state.json`:
- Add entry to `next_session_history`
- Set `current_session` if appropriate

## Rules

1. **One session at a time** - Only recommend one session
2. **Respect dependencies** - Don't skip prerequisites
3. **MVP focus** - Recommend core features before polish
4. **Scope discipline** - Sessions should be 15-30 tasks, 2-4 hours
5. **Logical progression** - Follow natural build order

## Output

After analysis, create the NEXT_SESSION.md file and summarize your recommendation to the user.
