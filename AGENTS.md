# Apex Spec System v1.0.1-beta

A specification-driven workflow system for AI-assisted development.

## Core Philosophy

**1 session = 1 spec = 2-4 hours (12-25 tasks) = safe context window**

Break large projects into manageable, well-scoped implementation sessions.

## 3-Stage Workflow

```
PLAN  -->  BUILD  -->  HARDEN
 |          |           |
 v          v           v
initspec    nextsession audit
createprd   sessionspec pipeline
phasebuild  tasks       infra
            implement   documents
            validate    carryforward
            updateprd
```

**PLAN**: Initialize project, create PRD, define phases and sessions.
**BUILD**: Iterate sessions -- spec, task, implement, validate, update.
**HARDEN**: Between phases -- audit code, add CI/CD, infra, docs, carry forward lessons.

## Command Reference

| Command | Description |
|---------|-------------|
| `/audit` | Analyze tech stack, run dev tooling, and remediate code quality issues |
| `/carryforward` | Extract lessons learned and update CONSIDERATIONS.md between phases |
| `/createprd` | Generate the master PRD from a user-provided requirements document |
| `/documents` | Create and maintain project documentation according to monorepo standards |
| `/implement` | AI-led task-by-task implementation of the current session |
| `/infra` | Add and validate production infrastructure one bundle at a time |
| `/initspec` | Initialize the Apex Spec System in the current project |
| `/nextsession` | Analyze project state and recommend the next session to implement |
| `/phasebuild` | Create structure for a new phase |
| `/pipeline` | Add and validate CI/CD workflows one bundle at a time |
| `/sessionspec` | Create a formal specification for the recommended session |
| `/tasks` | Generate a 12-25 task checklist for the current session |
| `/updateprd` | Mark session complete and sync documentation |
| `/validate` | Verify session completeness and quality gates |

## Directory Structure

After running `/initspec`, the project contains:

```
your-project/
  .spec_system/
    state.json              # Project state tracking
    CONSIDERATIONS.md       # Lessons learned
    CONVENTIONS.md          # Coding standards
    PRD/
      PRD.md                # Master PRD
      phase_NN/             # Phase definitions
    specs/
      phaseNN-sessionNN-name/
        spec.md
        tasks.md
        implementation-notes.md
        validation.md
    archive/                # Completed work
```

## Session Scope Rules

- Maximum 25 tasks per session
- Maximum 4 hours estimated time
- Single clear objective per session
- Ideal: 12-25 tasks (sweet spot: 20)

## Task Format

Tasks use markdown checklists in `tasks.md`:

```markdown
- [ ] Task 1: Description of what to do
- [x] Task 2: Completed task
```

Mark tasks complete immediately as you finish them.

## Scripts

Bundled bash utilities in `scripts/`:
- `analyze-project.sh` -- Project structure analysis
- `check-prereqs.sh` -- Verify required tools are installed
- `common.sh` -- Shared utility functions

## Session Naming

Format: `phaseNN-sessionNN-name`

Examples: `phase00-session01-project-setup`, `phase01-session03-user-auth`

## ASCII Requirement (Non-Negotiable)

All generated files must use ASCII-only characters (bytes 0-127):
- No Unicode, emoji, or smart quotes
- Use straight quotes only
- Unix LF line endings

## Troubleshooting

- **Session too large?** Split into multiple sessions with `/nextsession`
- **Lost context?** Resume with `/implement` -- it reads task state
- **Bad session?** `git revert <commit>` after `/updateprd`
- **Between phases?** Run `/audit`, `/pipeline`, `/infra` before `/phasebuild`
