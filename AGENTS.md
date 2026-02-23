# Apex Spec System v1.0.2-beta

A specification-driven workflow system for AI-assisted development.

## Core Philosophy

**1 session = 1 spec = 2-4 hours (12-25 tasks) = safe context window**

Break large projects into manageable, well-scoped implementation sessions.

## High Level Workflow

```
START  -->  BUILD  -->  HARDEN (between Phases)
 |          |           |
 v          v           v
initspec    plansession audit
createprd   implement   pipeline
phasebuild  validate    infra
            updateprd   carryforward
                        documents
```

**PLAN**: Initialize project, create PRD, define phases and sessions.
**BUILD**: Iterate sessions -- spec, task, implement, validate, update.
**HARDEN**: Between phases -- audit code, add CI/CD, infra, carry forward lessons, update docs.

### Detailed Workflow

```
Start a project:
/initspec        # Initialize spec system
/createprd       # Generate PRD from requirements
/phasebuild      # Set up initial phase and sessions for that phase

Process a session:
/plansession     # Analyze, spec, and generate task checklist
/implement       # AI-led implementation
/validate        # Verify completeness, security & compliance
/updateprd       # Mark complete, sync docs

<repeat /plansession /implement /validate /updateprd until all sessions of a phase are complete>

Between Phases:
/audit            # Local dev tooling (formatter, linter, types, tests, observability, hooks)
/pipeline         # CI/CD workflows (quality, build, security, integration, ops)
/infra            # Production infrastructure (health, security, backup, deploy)
/carryforward     # Lessons learned, security/compliance records
/documents        # Create/update project documentation
/phasebuild       # Set up next phase

<Return to 'Process a session'>

<Repeat until project complete (PRD fulfilled)>
```

## Command Reference

| Command | Description |
|---------|-------------|
| `/audit` | Analyze tech stack, run dev tooling, and remediate code quality issues |
| `/carryforward` | Extract lessons learned, update CONSIDERATIONS.md, and maintain SECURITY-COMPLIANCE.md between phases |
| `/createprd` | Generate the master PRD from a user-provided requirements document |
| `/documents` | Create and maintain project documentation according to monorepo standards |
| `/implement` | AI-led task-by-task implementation of the current session |
| `/infra` | Add and validate production infrastructure one bundle at a time |
| `/initspec` | Initialize the Apex Spec System in the current project |
| `/phasebuild` | Create structure for a new phase |
| `/pipeline` | Add and validate CI/CD workflows one bundle at a time |
| `/plansession` | Analyze project state, create session spec and task checklist |
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
    SECURITY-COMPLIANCE.md  # Security posture & GDPR compliance
    PRD/
      PRD.md                # Master PRD
      phase_NN/             # Phase definitions
    specs/
      phaseNN-sessionNN-name/
        spec.md
        tasks.md
        implementation-notes.md
        security-compliance.md
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

- **Session too large?** Split into multiple sessions with `/plansession`
- **Lost context?** Ask the AI Agent or resume with `/implement` -- it reads task state
- **Bad session?** `git revert <commit>` after `/updateprd`
- **Between phases?** Run `/audit`, `/pipeline`, `/infra`, `/carryforward`, `/documents` before `/phasebuild`
