---
name: Apex Spec Workflow
description: This skill should be used when the user asks about "spec system", "session workflow", "createprd", "plansession", "implement session", "validate session", "phase build", "session scope", "task checklist", or when working in a project containing .spec_system/ directory. Provides guidance for specification-driven AI development workflows.
version: 1.6.9-beta
---

# Apex Spec Workflow

A specification-driven workflow system for AI-assisted development that breaks large projects into manageable 2-4 hour sessions with 12-25 tasks each.

## Core Philosophy

**1 session = 1 spec = 2-4 hours (12-25 tasks)**

Break large projects into manageable, well-scoped implementation sessions that fit within AI context windows and human attention spans.

A collection of sessions is a phase. A collection of phases is a mature/late technical PRD.

## The 13-Command Workflow

The workflow has **3 distinct stages**:

### Stage 1: INITIALIZATION (One-Time Setup)

```
/initspec          ->  Set up spec system in project
      |
      v
/createprd         ->  Generate PRD from requirements doc (optional)
  OR                   OR
[User Action]      ->  Manually populate PRD with requirements
      |
      v
/createuxprd       ->  Generate UX PRD from design docs (optional)
  OR                   OR
[User Action]      ->  Manually populate UX PRD with requirements
      |
      v
/phasebuild        ->  Create first phase structure (session stubs)
```

### Stage 2: SESSIONS WORKFLOW (Repeat Until Phase Complete)

```
/plansession   ->  Analyze project, create spec + task checklist
      |
      v
/implement     ->  AI-led task-by-task implementation
      |
      v
/validate      ->  Verify session completeness
      |
      v
/updateprd     ->  Sync PRD, mark session complete
      |
      +-------------> Loop back to /plansession
                      until ALL phase sessions complete
```

### Stage 3: PHASE TRANSITION (After All Previous Phase's Sessions Are Complete)

```
/audit             ->  Local dev tooling (formatter, linter, types, tests, observability, hooks)
      |
      v
/pipeline          ->  CI/CD workflows (quality, build, security, integration, ops)
      |
      v
/infra             ->  Production infrastructure (health, security, backup, deploy)
      |
      v
/carryforward      ->  Capture lessons learned (optional but recommended)
      |
      v
/documents         ->  Audit and update documentation
      |
      v
[User Action]      ->  Manual testing (highly recommended)
      |
      v
/phasebuild        ->  Create next phase structure
      |
      v
                   ->  Return to Stage 2 for new phase
```

## Directory Structure

Projects using this system follow this layout:

```
project/
|-- .spec_system/               # All spec system files
|   |-- state.json              # Project state tracking
|   |-- CONSIDERATIONS.md       # Institutional memory (lessons learned)
|   |-- SECURITY-COMPLIANCE.md  # Security posture & GDPR compliance
|   |-- CONVENTIONS.md          # Project coding standards and conventions
|   |-- PRD/                    # Product requirements
|   |   |-- PRD.md              # Master PRD
|   |   \-- phase_NN/           # Phase definitions
|   |-- specs/                  # Implementation specs
|   |   \-- phaseNN-sessionNN-name/
|   |       |-- spec.md
|   |       |-- tasks.md
|   |       |-- implementation-notes.md
|   |       |-- security-compliance.md
|   |       \-- validation.md
|   |-- scripts/                # Bash automation (if copied locally)
|   \-- archive/                # Completed work
\-- (project source files)
```

### Monorepo Directory Structure

Monorepo projects use the **same single `.spec_system/` at the repo root**. Sessions reference their target package in metadata (spec.md header and state.json), not in directory names.

```
monorepo-project/
|-- .spec_system/               # Single spec system at repo root
|   |-- state.json              # Includes monorepo flag + packages array
|   |-- CONVENTIONS.md          # Includes Workspace Structure table
|   |-- CONSIDERATIONS.md
|   |-- SECURITY-COMPLIANCE.md
|   |-- PRD/
|   |   |-- PRD.md              # Includes Package Map section
|   |   \-- phase_00/
|   |       |-- session_01_project_setup.md
|   |       |-- session_02_web_scaffold.md      # Package: apps/web
|   |       \-- session_03_api_models.md        # Package: apps/api
|   |-- specs/
|   |   |-- phase00-session01-project-setup/    # Cross-cutting (no package)
|   |   |-- phase00-session02-web-scaffold/     # Scoped to apps/web
|   |   \-- phase00-session03-api-models/       # Scoped to apps/api
|   \-- archive/
|-- apps/
|   |-- web/                    # Frontend package
|   \-- api/                    # Backend package
\-- packages/
    \-- shared/                 # Shared library
```

Key differences from single-repo:
- Session stubs gain optional `Package:` annotation
- spec.md headers include `Package:` and `Package Stack:` fields
- CONVENTIONS.md includes a Workspace Structure table
- Session numbering is global within a phase (interleaved across packages)

## Session Naming Convention

**Format**: `phaseNN-sessionNN-name`

- `phaseNN`: 2-digit phase number (phase00, phase01)
- `sessionNN`: 2-digit session number (session01, session02)
- `name`: lowercase-hyphenated description

**Examples**:
- `phase00-session01-project-setup`
- `phase01-session03-user-authentication`
- `phase02-session08b-refinements`

## Session Scope Rules

### Hard Limits (Reject if Exceeded)

| Limit | Value |
|-------|-------|
| Maximum tasks | 25 |
| Maximum duration | 4 hours |
| Objectives | Single clear objective |

### Ideal Targets

| Target | Value |
|--------|-------|
| Task count | 12-25 (sweet spot: 20) |
| Duration | 2-3 hours |
| Focus | Stable/late MVP |

## Task Design

### Task Format

```
- [ ] TNNN [SNNMM] [P] Action verb + what + where (`path/to/file`)
```

Components:
- `TNNN`: Sequential task ID (T001, T002, ...)
- `[SNNMM]`: Session reference (S0103 = Phase 01, Session 03)
- `[P]`: Optional parallelization marker
- Description: Action verb + clear description
- Path: File being created/modified

### Task Categories

1. **Setup** (2-4 tasks): Environment, directories, config
2. **Foundation** (4-8 tasks): Core types, interfaces, base classes
3. **Implementation** (8-15 tasks): Main feature logic
4. **Testing** (3-5 tasks): Tests, validation, verification

### Parallelization

Mark tasks `[P]` when they:
- Create independent files
- Don't depend on each other's output
- Can be done in any order

## Critical Requirements

### ASCII Encoding (Non-Negotiable)

All files must use ASCII-only characters (0-127):
- NO Unicode characters
- NO emoji
- NO smart quotes - use straight quotes (" ')
- NO em-dashes - use hyphens (-)
- Unix LF line endings only (no CRLF)

Validate with:
```bash
file filename.txt        # Should show: ASCII text
grep -P '[^\x00-\x7F]' filename.txt  # Should return nothing
```

### Over-Arching Rules

- Complete one session at a time before starting next
- Update task checkboxes immediately as work progresses
- Follow workflow sequence - resist scope creep
- Read spec.md and tasks.md before implementing

## State Tracking

The `.spec_system/state.json` file tracks project progress:

```json
{
  "version": "2.0",
  "project_name": "Project Name",
  "current_phase": 0,
  "current_session": null,
  "phases": {
    "0": {
      "name": "Foundation",
      "status": "in_progress",
      "session_count": 5
    }
  },
  "completed_sessions": [],
  "next_session_history": []
}
```

### Monorepo State Tracking

When `monorepo` is confirmed `true`, state.json gains a `packages` array and uses object-form `completed_sessions`:

```json
{
  "version": "2.0",
  "project_name": "Acme Platform",
  "monorepo": true,
  "packages": [
    { "name": "web", "path": "apps/web", "type": "frontend", "stack": "TypeScript + React" },
    { "name": "api", "path": "apps/api", "type": "backend", "stack": "Python 3.12 + FastAPI" },
    { "name": "shared", "path": "packages/shared", "type": "library", "stack": "TypeScript" }
  ],
  "current_phase": 0,
  "current_session": "phase00-session04-api-models",
  "phases": {
    "0": { "name": "Foundation", "status": "in_progress", "session_count": 6 }
  },
  "completed_sessions": [
    { "id": "phase00-session01-project-setup", "package": null },
    { "id": "phase00-session02-web-scaffold", "package": "apps/web" },
    { "id": "phase00-session03-shared-types", "package": "packages/shared" }
  ],
  "next_session_history": []
}
```

The `monorepo` field uses three states:

| Value | Meaning | Behavior |
|-------|---------|----------|
| `null` (or absent) | Unknown / not yet determined | Commands look for signals, prompt if found |
| `true` | Confirmed monorepo | Commands use package-aware logic |
| `false` | Confirmed single-repo | Commands skip package logic entirely |

Single-repo projects see no `packages` field and keep string-form `completed_sessions`. Existing state files without `monorepo` are treated as `null` (unknown), which behaves identically to classic single-repo until the user confirms otherwise.

## Command Quick Reference

| Command | Purpose | Input | Output |
|---------|---------|-------|--------|
| `/initspec` | Initialize spec system | Project info | .spec_system/ structure |
| `/createprd` | Generate master PRD | Requirements doc or user text | PRD/PRD.md |
| `/createuxprd` | Generate UX PRD | Design docs or user text | PRD/PRD_UX.md |
| `/plansession` | Analyze, spec, and task list | state.json, PRD | specs/.../spec.md + tasks.md |
| `/implement` | Code implementation | spec.md, tasks.md | implementation-notes.md |
| `/validate` | Verify completeness | All session files | security-compliance.md, validation.md |
| `/updateprd` | Mark complete | validation.md | Updated state.json |
| `/audit` | Local dev tooling | CONVENTIONS.md | Updated tools, report |
| `/pipeline` | CI/CD workflows | CONVENTIONS.md | Workflow files, report |
| `/infra` | Production infra | CONVENTIONS.md | Configs, report |
| `/documents` | Audit/update docs | state.json, PRD, codebase | Updated docs, docs-audit.md |
| `/carryforward` | Capture lessons & security posture | Completed phase artifacts | CONSIDERATIONS.md, SECURITY-COMPLIANCE.md |
| `/phasebuild` | Create new phase | PRD | PRD/phase_NN/ |

## Utility Commands

Standalone helpers that operate outside the session workflow. They do not affect session state and can be run at any time. See [docs/UTILITIES.md](../../docs/UTILITIES.md) for the full reference and conventions for adding new utility commands.

## Additional Resources

### Scripts Directory

Utility scripts are available at two locations:
- **Plugin**: `${CLAUDE_PLUGIN_ROOT}/scripts/` (default, always up-to-date)
- **Local**: `.spec_system/scripts/` (optional, for per-project customization)

**Local scripts take precedence** - if `.spec_system/scripts/` exists, commands use local scripts instead of plugin scripts.

Available scripts:
- `analyze-project.sh` - Project state analysis (supports `--json` for structured output)
- `check-prereqs.sh` - Environment and tool verification (supports `--json` for structured output)
- `common.sh` - Shared functions

To copy scripts locally during `/initspec`, choose "copy locally" when prompted. To revert to plugin scripts, delete `.spec_system/scripts/`.

### Hybrid Architecture

Commands use a **hybrid approach** for reliability:

1. **Deterministic State** (`analyze-project.sh --json`): Authoritative state facts
2. **Environment Verification** (`check-prereqs.sh --json`): Tool and prerequisite validation
3. **Semantic Analysis** (Claude): Interprets PRD content, makes recommendations

**Why this matters:**
- Script output is deterministic - same input always gives same output
- Eliminates risk of Claude misreading state.json
- Tool verification catches missing dependencies BEFORE implementation starts
- Users can run scripts independently to debug
- Claude focuses on what it does best: understanding context and reasoning

**analyze-project.sh JSON Output:**
```json
{
  "project": "project-name",
  "monorepo": true,
  "packages": [
    {"name": "web", "path": "apps/web", "type": "frontend", "stack": "TypeScript + React"}
  ],
  "active_package": {"name": "web", "path": "apps/web"},
  "monorepo_detection": null,
  "current_phase": 1,
  "current_session": "phase01-session02-feature",
  "completed_sessions": [
    {"id": "phase00-session01-setup", "package": null}
  ],
  "candidate_sessions": [
    {"file": "session_01_auth", "completed": false, "package": "apps/web"}
  ]
}
```

For single-repo projects: `monorepo` is `null` or `false`, `packages` is `[]`, `active_package` is `null`, and `completed_sessions` uses the string array format.

**check-prereqs.sh JSON Output:**
```json
{
  "overall": "pass",
  "environment": {
    "spec_system": {"status": "pass"},
    "jq": {"status": "pass", "info": "jq-1.7"}
  },
  "tools": {
    "node": {"status": "pass", "info": "v20.10.0"},
    "docker": {"status": "fail", "info": "not installed"}
  },
  "package": {
    "registered": {"status": "pass", "info": "apps/web"},
    "directory": {"status": "pass", "info": "apps/web"},
    "manifest": {"status": "pass", "info": "package.json"},
    "stack": {"status": "pass", "info": "TypeScript"}
  },
  "workspace": {
    "status": {"status": "pass", "info": "monorepo detected"},
    "manager": {"status": "pass", "info": "pnpm"},
    "runner": {"status": "pass", "info": "turbo"}
  },
  "database": {
    "type": {"status": "pass", "info": "PostgreSQL"},
    "migration_tool": {"status": "pass", "info": "prisma"},
    "tool_available": {"status": "pass", "info": "npx prisma"},
    "seed_script": {"status": "warn", "info": "no seed script found"}
  },
  "issues": [
    {"type": "tool", "name": "docker", "message": "required tool not installed"}
  ]
}
```

The `package` and `workspace` sections appear only when `--package` is used or monorepo is detected. The `database` section only appears when DB signals are detected in the project. For single-repo projects without databases, these sections are empty objects (`{}`).

**Commands and their script usage:**
| Command | analyze-project.sh | check-prereqs.sh |
|---------|-------------------|------------------|
| `/plansession` | State + candidates | - |
| `/implement` | Current session | Environment + tools |
| `/validate` | Current session | - |
| `/documents` | State + progress | - |

## Monorepo Support

The system supports monorepo projects through a "gentle assumption" -- it auto-detects multi-package structures and offers package-aware workflows, but never requires them. Single-repo projects see zero behavioral change.

### How It Works

1. **Detection is layered across commands:**
   - `/initspec` (brownfield): Detects existing workspace configs (pnpm, npm, turbo, nx, cargo, go, lerna)
   - `/createprd` (greenfield): Parses PRD content for multi-package signals
   - `/phasebuild`: Checkpoint -- warns if PRD references packages but state lacks them
   - Later commands: Opportunistic detection if workspace configs appear

2. **Package context flows through sessions:**
   - `/plansession` determines the target package (user input, stub annotation, or prompt)
   - spec.md headers include `Package:` and `Package Stack:` fields
   - Task file paths are scoped to the package directory (e.g., `apps/web/src/auth.ts`)
   - `/implement` validates files stay within declared package scope
   - `/updateprd` records package in completed_sessions

3. **Session numbering is global within a phase:**
   - Sessions interleave across packages (session 02 might be `apps/web`, session 03 `apps/api`)
   - Phase completion requires ALL sessions done, regardless of which packages they target
   - One ordered list of sessions per phase -- simple progress tracking

4. **Scripts accept `--package` flag for scoped operations:**
   - `analyze-project.sh --json --package apps/web` -- filters candidates by package
   - `check-prereqs.sh --json --package apps/web` -- validates package-specific tools

### Supported Workspace Managers

| Manager | Detection File |
|---------|---------------|
| pnpm | `pnpm-workspace.yaml` |
| npm/yarn | `package.json` with `"workspaces"` field |
| Turborepo | `turbo.json` |
| Nx | `nx.json` |
| Cargo | `Cargo.toml` with `[workspace]` |
| Go | `go.work` |
| Lerna | `lerna.json` |

### Per-Package Stack Detection

Each package gets a `stack` field based on its manifest files:

| Stack | Indicator |
|-------|-----------|
| TypeScript | `tsconfig.json` |
| JavaScript | `package.json` (no tsconfig) |
| Rust | `Cargo.toml` |
| Go | `go.mod` |
| Python | `pyproject.toml`, `setup.py`, or `requirements.txt` |
| Ruby | `Gemfile` |
| Java | `pom.xml`, `build.gradle`, or `build.gradle.kts` |

## Best Practices

1. **Start with /plansession** - Always analyze state before choosing work
2. **One session at a time** - Complete before starting next
3. **MVP first** - Defer polish and optimizations
4. **Validate encoding** - Check ASCII before committing
5. **Update tasks continuously** - Mark checkboxes immediately
6. **Trust the system** - Follow workflow, resist scope creep
7. **Read before implementing** - Review spec.md and tasks.md first
8. **Keep docs current** - Run `/documents` after completing a phase or adding packages

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Scope too large | Split session in PRD before /plansession |
| ASCII validation fails | Run `grep -P '[^\x00-\x7F]'` to find issues |
| State out of sync | Manually update .spec_system/state.json |
| Commands not found | Verify plugin is enabled |
| Tasks taking too long | Reduce scope, defer non-MVP items |
| Missing tools | Run `check-prereqs.sh --tools "tool1,tool2"` to verify |
| Environment issues | Run `check-prereqs.sh --env` to diagnose |
| Stale documentation | Run `/documents` to audit and update |
| Missing docs | Run `/documents` to create standard files |
| Lint/format issues | Run `/audit` to add tooling and auto-fix |
| CI failures | Run `/pipeline` to add workflows and fix errors |
| Infra not validated | Run `/infra` to configure health, security, backup, deploy |
| Monorepo not detected | Run `/initspec` on an existing repo or describe packages in PRD for `/createprd` |
| Wrong package context | Specify package when running `/plansession` (e.g., "plan for apps/web") |
| Cross-package session | Set package to null for sessions spanning multiple packages |
| Package tools missing | Run `check-prereqs.sh --json --package apps/web` to diagnose |

### Monorepo Error Recovery

**Monorepo not detected by `/initspec`**: Workspace config may have been added after init, or uses a non-standard layout. Manually set `"monorepo": true` in state.json, add a `packages` array, add the Workspace Structure table to CONVENTIONS.md, then run `/createprd` or `/plansession` to pick up the config.

**Session planned for wrong package**: If caught before `/updateprd`, delete the session spec directory and re-run `/plansession` with the correct package. If caught after `/updateprd`, manually edit the `package` field in the relevant `completed_sessions` entry in state.json.

**Package added mid-project**: Add the package entry to state.json's `packages` array, update CONVENTIONS.md's Workspace Structure table, add session stubs to `PRD/phase_NN/` with `Package:` annotations, and increment `session_count` in the phase's state entry.

**Cross-package dependency discovered mid-session**: Complete the current session with stubs/interfaces, note the dependency in implementation-notes.md, and plan the shared package session next. Use a cross-cutting session (package: null) when work genuinely spans packages.

**Different packages need different tool versions**: Use workspace-level version management (`.nvmrc` per package, `engines` in package.json). `/audit` handles shared tools at root with per-package overrides. Validate with `check-prereqs.sh --package apps/web`.

**State disagrees with workspace configs**: Run `analyze-project.sh --json` -- it reports both the state.json `monorepo` flag and live `monorepo_detection`. Compare them and update state.json manually if needed.

### Decision Quick Reference

| Situation | Action |
|-----------|--------|
| New empty project | `/initspec` sets `monorepo: null`, deferred to `/createprd` |
| Existing monorepo project | `/initspec` auto-detects, confirms with user |
| PRD describes multiple services | `/createprd` prompts to confirm monorepo |
| Session targets one package | `/plansession` scopes spec and tasks to that package |
| Session spans packages | Use cross-cutting session (package: null) |
| Need to add a package mid-project | Manually update state.json and CONVENTIONS.md |
| Phase has mixed-package sessions | Normal -- sessions interleave, phase completes when all done |
| Different stacks per package | `/audit` and `/pipeline` handle per-package tool config |
