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
[Initialized] --User populates PRD--> [PRD Ready]
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
[Phase Complete] --/documents--> [Docs Updated] (recommended)
[Docs Updated] --/phasebuild--> [New Phase Created]
[New Phase Created] --user manual testing--> (highly recommended)
[New Phase Created] --> Return to Stage 2
```

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

### Documentation Issues

Common fixes:
- **Stale documentation**: Run `/documents` to audit and update
- **Missing required files**: Run `/documents` to create from templates
- **Docs out of sync with code**: Run `/documents` after any major implementation
- **Redundant information**: Run `/documents` to consolidate
- **Invalid links or paths**: Run `/documents` quality checks
