# Detailed Workflow Reference

## Command Workflows

### /nextsession Workflow

**Purpose**: Analyze project state and recommend the next implementation session.

**Steps**:

1. **Read Project State**
   - Read `.spec_system/state.json` for current phase and completed sessions
   - Read `.spec_system/PRD/PRD.md` for master project requirements
   - Read `.spec_system/PRD/phase_XX/` for current phase session definitions

2. **Analyze Progress**
   - Determine current phase status
   - Identify completed sessions
   - Find sessions with unmet prerequisites
   - Determine natural next session based on dependencies

3. **Evaluate Candidates**
   - Check prerequisites are met
   - Verify dependencies completed
   - Assess complexity and scope
   - Consider logical flow

4. **Generate Recommendation**
   - Create `.spec_system/NEXT_SESSION.md` with full recommendation
   - Include session ID, objectives, deliverables
   - List alternatives if primary is blocked

5. **Update State**
   - Add entry to `next_session_history`
   - Set `current_session` if appropriate

**Decision Points**:
- If multiple sessions ready: Choose based on dependencies, complexity, project flow
- If session blocked: Recommend alternative with explanation
- If phase complete: Suggest `/phasebuild` for next phase

---

### /sessionspec Workflow

**Purpose**: Convert session recommendation into detailed technical specification.

**Steps**:

1. **Read Inputs**
   - `.spec_system/NEXT_SESSION.md` - Session recommendation
   - `.spec_system/state.json` - Project state
   - `.spec_system/PRD/phase_XX/session_XX.md` - Session definition (if exists)
   - Scripts from `.spec_system/scripts/` (local) or `${CLAUDE_PLUGIN_ROOT}/scripts/` (plugin)

2. **Create Session Directory**
   ```
   .spec_system/specs/phaseNN-sessionNN-name/
   └── spec.md
   ```

3. **Generate Specification**
   - Fill all sections from template
   - Estimate deliverables and line counts
   - Define success criteria
   - Document technical approach

4. **Archive Recommendation**
   - Move `.spec_system/NEXT_SESSION.md` to session directory

5. **Update State**
   - Set `current_session` to session ID
   - Update `next_session_history` status

**Scope Validation**:
- Reject if > 25 tasks estimated
- Reject if > 4 hours estimated
- Reject if multiple objectives

---

### /tasks Workflow

**Purpose**: Generate detailed, sequenced task checklist (12-25 tasks).

**Steps**:

1. **Read Specification**
   - Read `.spec_system/specs/[session]/spec.md`
   - Get session ID from `.spec_system/state.json`

2. **Analyze Requirements**
   - Identify deliverables
   - Extract success criteria
   - Note technical approach
   - Map testing requirements
   - Determine task dependencies

3. **Generate Task List**
   - Create `tasks.md` in session directory
   - Organize by category (Setup, Foundation, Implementation, Testing)
   - Add parallelization markers where appropriate
   - Include file paths for each task

**Task Sizing Guidelines**:
- Each task: ~20-25 minutes
- Single file focus when possible
- Clear, atomic action
- Verifiable completion

---

### /implement Workflow

**Purpose**: Execute task-by-task implementation with progress tracking.

**Steps**:

1. **Read Session Context**
   - `.spec_system/specs/[session]/spec.md` - Full specification
   - `.spec_system/specs/[session]/tasks.md` - Task checklist
   - `.spec_system/specs/[session]/implementation-notes.md` - Progress log (if exists)
   - `.spec_system/state.json` - Current session

2. **Initialize Notes**
   - Create `implementation-notes.md` if not exists
   - Set up progress tracking

3. **Work Through Tasks**
   For each incomplete task:
   - Identify next task (first unchecked)
   - Implement required changes
   - Update task status to `[x]`
   - Log progress in implementation-notes.md

4. **Handle Blockers**
   - Document in implementation-notes.md
   - Either resolve, skip with documentation, or ask user

5. **Track Decisions**
   - Document design decisions with rationale
   - Note alternatives considered

6. **Continuous Updates**
   - Update progress summary after each task
   - Inform user of status

**Resumption**: If interrupted, read implementation-notes.md for context and resume from next incomplete task.

---

### /validate Workflow

**Purpose**: Verify session completeness against quality gates.

**Validation Checks**:

1. **Task Completion**
   - All tasks in tasks.md marked `[x]`
   - List any incomplete tasks

2. **Deliverables Check**
   - Each file from spec.md exists
   - Files are non-empty

3. **ASCII Encoding**
   ```bash
   file [filename]              # Should show: ASCII text
   grep -P '[^\x00-\x7F]' [filename]  # Should return nothing
   ```

4. **Test Verification**
   - Run project test suite
   - Record pass/fail counts
   - Note any failures

5. **Success Criteria**
   - Check each functional requirement from spec
   - Verify testing requirements
   - Confirm quality gates

**Output**: Create `validation.md` with PASS/FAIL status and detailed breakdown.

**PASS Requirements** (all must be true):
- 100% tasks completed
- All deliverable files exist
- All files ASCII-encoded with LF endings
- All tests passing
- All success criteria met

---

### /updateprd Workflow

**Purpose**: Mark session complete and sync documentation.

**Prerequisites**: Session must have passed `/validate`

**Steps**:

1. **Verify Validation**
   - Confirm `validation.md` shows PASS
   - If FAIL, instruct user to fix first

2. **Update State**
   - Add session to `completed_sessions`
   - Clear `current_session`
   - Update `next_session_history` status

3. **Update Phase README**
   - Mark session as Complete
   - Add completion date
   - Update progress percentage

4. **Create Summary**
   - Generate `IMPLEMENTATION_SUMMARY.md`
   - Document deliverables, decisions, lessons

5. **Check Phase Completion**
   - If last session: Update phase status to "complete"

6. **Report Completion**
   - Show updated files
   - Display phase progress
   - Suggest next action

---

### /audit Workflow

**Purpose**: Add and validate local dev tooling one bundle at a time.

**Master List (6 Bundles)**:
1. Formatting (Prettier, Biome, Ruff)
2. Linting (ESLint, Biome, Ruff, Clippy)
3. Type Safety (TypeScript, mypy, Pyright)
4. Testing (Jest, Vitest, pytest + coverage)
5. Observability (structlog, pino, tracing, slog)
6. Git Hooks (husky, pre-commit, lefthook)

**Universal 9-Step Flow**:

1. **DETECT** - Read CONVENTIONS.md for stack, scan for existing configs
2. **COMPARE** - Check Local Dev Tools table against master list
3. **SELECT** - Pick highest-priority missing bundle
4. **IMPLEMENT** - Install tool, generate config
5. **VALIDATE** - Run ALL configured tools
6. **FIX** - Fix ALL errors (auto-fix where possible)
7. **RECORD** - Update CONVENTIONS.md with new tool
8. **REPORT** - Summary of added, fixed, remaining
9. **RECOMMEND** - "Rerun /audit" or "Run /pipeline"

**Key Rules**:
- One bundle per run
- Validate everything after adding
- Fix everything before reporting
- Never leave syntax broken
- Respect known-issues.md

---

### /pipeline Workflow

**Purpose**: Add and validate CI/CD workflows one bundle at a time.

**Master List (5 Bundles)**:
1. Code Quality (lint + format + type check)
2. Build & Test (build + unit tests + coverage)
3. Security (secrets scanning + SAST/CodeQL + dependency review)
4. Integration (E2E + integration tests + DB migration dry-run)
5. Operations (notifications + Dependabot/Renovate + release tagging)

**Universal 9-Step Flow**:

1. **DETECT** - Read CONVENTIONS.md, scan .github/workflows/, check open PRs
2. **COMPARE** - Check CI/CD table against master list
3. **SELECT** - Pick highest-priority missing bundle
4. **IMPLEMENT** - Generate workflow YAML, commit, push
5. **VALIDATE** - Poll `gh run list`, check ALL workflows, check PR status
6. **FIX** - Fix CI failures, address PR review comments
7. **RECORD** - Update CONVENTIONS.md CI/CD table
8. **REPORT** - Summary of added, fixed, PR status
9. **RECOMMEND** - "Rerun /pipeline" or "Run /infra"

**PR Handling**:
- Use `--pr <number>` to focus on specific PR
- Fetches review comments and addresses actionable ones
- Fixes CI failures on PR branch
- Reports PR readiness for merge

**Key Rules**:
- One bundle per run
- GitHub Actions first (GitLab CI limited support)
- Document secrets, never create them
- 3-minute CI timeout, then report and exit
- Address reviews but don't over-engineer

---

### /infra Workflow

**Purpose**: Add and validate production infrastructure one bundle at a time.

**Master List (4 Bundles)**:
1. Health (/health endpoint + platform probes)
2. Security (WAF rules + rate limiting)
3. Backup (DB backup + storage + retention)
4. Deploy (CD webhook/trigger from main)

**Universal 9-Step Flow**:

1. **DETECT** - Read CONVENTIONS.md Infrastructure table, detect platform
2. **COMPARE** - Check against master list
3. **SELECT** - Pick highest-priority missing bundle
4. **IMPLEMENT** - Create endpoint, config, or script
5. **VALIDATE** - curl /health, test rate limiting, verify backup exists
6. **FIX** - Fix connectivity, configs, or scripts
7. **RECORD** - Update CONVENTIONS.md Infrastructure table
8. **REPORT** - Summary of added, validated, manual steps needed
9. **RECOMMEND** - "Rerun /infra" or "Run /documents"

**Stack-Agnostic**: Works with any platform (Cloudflare, AWS, Vercel, Coolify, etc.)

**Key Rules**:
- One bundle per run
- Read platform from CONVENTIONS.md
- Document manual steps for platform UIs
- Don't store secrets, document env vars needed
- Validate that infra actually works

---

### /documents Workflow

**Purpose**: Audit, create, and maintain project documentation according to monorepo standards.

**When to Run**:
- After completing a phase
- After adding new packages or services
- When documentation may be stale
- Any time documentation coverage needs verification

**Steps**:

1. **Get Project State**
   - Run `analyze-project.sh --json` to understand current progress
   - Read `.spec_system/state.json` for phase/session status
   - Read `.spec_system/PRD/PRD.md` for project context

2. **Audit Existing Documentation**
   Check for standard documentation files:

   **Root Level (Required)**:
   - `README.md` - Project overview, repo map, quickstart
   - `CONTRIBUTING.md` - Branch conventions, PR rules, commit style
   - `LICENSE` - Legal clarity

   **docs/ Directory**:
   - `docs/ARCHITECTURE.md` - System diagram, tech stack, component relationships
   - `docs/CODEOWNERS` - Code ownership assignments
   - `docs/onboarding.md` - Zero-to-hero setup checklist
   - `docs/development.md` - Local environment, dev scripts
   - `docs/environments.md` - Dev/staging/prod differences
   - `docs/deployment.md` - CI/CD pipelines, release process
   - `docs/adr/` - Architecture Decision Records
   - `docs/runbooks/` - Incident response procedures
   - `docs/api/` - API contracts, OpenAPI specs

   **Per-Package READMEs**:
   - Pattern: `[parent]/[dirname]/README_[dirname].md`
   - Only root gets `README.md`; subdirectories use `README_<dirname>.md`

3. **Generate Audit Report**
   Identify:
   - Missing files (need to create)
   - Stale files (need to update)
   - Redundant content (need to consolidate)
   - Wordy sections (need to trim)

4. **Create Missing Documentation**
   - Check for local override: `.spec_system/doc-templates/<filename>`
   - If exists, use local template; otherwise use default templates
   - Fill with actual project information
   - Never invent technical details

5. **Update Existing Documentation**
   - Compare against actual project state
   - Fix discrepancies between docs and implementation
   - Remove outdated information
   - Keep content concise

6. **Quality Checks**
   - All commands work
   - All paths exist
   - All links valid
   - No TODO placeholders
   - ASCII-only characters

7. **Generate Audit Report**
   Create `.spec_system/docs-audit.md` with:
   - Summary of required vs found files
   - List of files created
   - List of files updated
   - Remaining gaps requiring human input

**Key Rules**:
- Never invent technical details - only document what exists
- ASCII-only characters in all files
- One source of truth - link instead of duplicating
- Current over complete - accurate and small beats comprehensive and stale

---

### /carryforward Workflow

**Purpose**: Capture lessons learned and institutional memory between phases.

**When to Run**:
- After completing all sessions in a phase
- Before starting /phasebuild for the next phase

**Steps**:

1. **Gather Phase Artifacts**
   - Read all session implementation-notes.md files
   - Read all session validation.md files
   - Identify patterns, blockers, and decisions

2. **Extract Lessons**
   - What worked well?
   - What caused problems?
   - What would we do differently?
   - What patterns emerged?

3. **Update CONSIDERATIONS.md**
   - Add phase-specific learnings
   - Update general guidelines if patterns are universal
   - Keep concise and actionable

4. **Archive Phase**
   - Move completed phase artifacts to archive if needed

**Key Rules**:
- Focus on actionable insights
- Don't repeat what's in CONVENTIONS.md
- Keep entries concise

---

### /phasebuild Workflow

**Purpose**: Create structure for a new project phase.

**Steps**:

1. **Gather Information**
   - Phase number (next sequential)
   - Phase name and description
   - Estimated session count
   - High-level objectives

2. **Create Directory Structure**
   ```
   .spec_system/PRD/phase_NN/
   ├── README.md
   ├── session_01_name.md
   ├── session_02_name.md
   └── ...
   ```

3. **Create Phase PRD**
   - Full phase specification
   - Session overview table
   - Technical considerations

4. **Create Phase README**
   - Progress tracker
   - Session status table

5. **Create Session Stubs**
   - One file per session
   - Objective, scope, deliverables

6. **Update State**
   - Add phase to `phases` object
   - Set status to "not_started"

7. **Update Master PRD**
   - Add phase reference

---

## State Machine

The workflow has **3 distinct stages**:

### Stage 1: INITIALIZATION (One-Time)

```
[New Project] --/initspec--> [Initialized]
[Initialized] --/createprd or manual--> [PRD Ready]
[PRD Ready] --/phasebuild--> [Phase Created]
```

### Stage 2: SESSIONS WORKFLOW (Repeat Until Phase Complete)

```
[Phase Created] --/nextsession--> [Recommended]
[Recommended] --/sessionspec--> [Specified]
[Specified] --/tasks--> [Ready]
[Ready] --/implement--> [In Progress]
[In Progress] --/validate--> [Validated]
[Validated:PASS] --/updateprd--> [Session Complete]
[Validated:FAIL] --fix issues--> [In Progress]
[Session Complete] --more sessions?--> /nextsession --> [Recommended]
[Session Complete] --all sessions done--> [Phase Complete]
```

### Stage 3: PHASE TRANSITION (After All Previous Phase's Sessions Are Complete)

```
[Phase Complete] --/audit--> [Dev Tooling Ready] (optional)
    |
    v
[Dev Tooling Ready] --/pipeline--> [CI/CD Ready] (optional)
    |
    v
[CI/CD Ready] --/infra--> [Infrastructure Ready] (optional)
    |
    v
[Infrastructure Ready] --/documents--> [Docs Updated]
    |
    v
[Docs Updated] --manual testing--> (highly recommended)
    |
    v
[Tested] --/carryforward--> [Lessons Captured] (optional)
    |
    v
[Ready] --/phasebuild--> [New Phase Created]
    |
    v
--> Return to Stage 2
```

**Phase Transition Commands** (universal 9-step flow):
- `/audit` - Local dev tooling (6 bundles: format, lint, types, test, observability, hooks)
- `/pipeline` - CI/CD workflows (5 bundles: quality, build, security, integration, ops)
- `/infra` - Production infrastructure (4 bundles: health, security, backup, deploy)

Each command adds ONE bundle per run, validates ALL configured items, fixes ALL errors.

---

## Error Recovery

### Incomplete Session

If session abandoned mid-way:
1. Run `/implement` to resume from last task
2. Or manually update `.spec_system/state.json` to clear session

### State Corruption

If `.spec_system/state.json` becomes invalid:
1. Check completed sessions against `.spec_system/specs/` directory
2. Reconstruct state from existing files
3. Validate with phase README files

### Validation Failures

Common fixes:
- **Incomplete tasks**: Return to `/implement`
- **Missing files**: Create missing deliverables
- **ASCII errors**: Fix encoding issues
- **Test failures**: Fix tests, re-run suite

### Local Dev Tooling Issues

Common fixes:
- **Missing tools**: Run `/audit` to detect and install
- **Lint/format errors**: Run `/audit` to auto-fix
- **Type errors**: Run `/audit` to attempt fixes
- **Config issues**: Check CONVENTIONS.md Local Dev Tools table

### CI/CD Issues

Common fixes:
- **Failing workflows**: Run `/pipeline` to fix errors
- **PR review comments**: Run `/pipeline --pr <number>` to address
- **Missing workflows**: Run `/pipeline` to add next bundle
- **Secrets needed**: Check REPORT output for required secrets

### Infrastructure Issues

Common fixes:
- **Health check failing**: Run `/infra` to fix endpoint or connectivity
- **Backup missing**: Run `/infra` to configure backup script
- **Rate limiting broken**: Check platform WAF settings
- **Deploy not triggering**: Verify webhook URL in platform

### Documentation Issues

Common fixes:
- **Stale documentation**: Run `/documents` to audit and update
- **Missing required files**: Run `/documents` to create from templates
- **Docs out of sync with code**: Run `/documents` after any major implementation
- **Redundant information**: Run `/documents` to consolidate
- **Invalid links or paths**: Run `/documents` quality checks
