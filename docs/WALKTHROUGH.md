# Apex Spec System Walkthrough

A real-world walkthrough based on an actual project: **NJ Title Intelligence Platform**.

> This walkthrough uses artifacts from a production project that processed 4M+ parcels across 16 phases and 79+ sessions over 3 weeks.

---

## The Project

**NJ Title Intelligence Platform** - A property intelligence system for NJ title insurance that unifies parcel, lien, environmental, and corporate data using free public data sources.

| Metric | Value |
|--------|-------|
| Total Phases | 16 |
| Completed Sessions | 79+ |
| Records Processed | 4M+ parcels, 105M+ historical records |
| Development Time | ~3 weeks |
| Tech Stack | Python/Litestar, PostgreSQL/PostGIS, React/Next.js |

---

## Stage 1: Initialization

### Step 1: /initspec

```
User: /initspec
```

Claude creates the spec system structure:

```
title_clerk/
├── .spec_system/
│   ├── state.json              # Tracks progress
│   ├── CONSIDERATIONS.md       # Lessons learned
│   ├── CONVENTIONS.md          # Coding standards
│   └── PRD/
│       └── PRD.md              # Empty template
```

### Step 2: /createprd

```
User: /createprd "A property intelligence platform for NJ title insurance
      that maximizes FREE public data, covering 21 NJ counties, 564
      municipalities, and ~4M parcels with $0 data acquisition cost."
```

Claude generates a comprehensive PRD with phase breakdown:

```markdown
# NJ Title Intelligence Platform - PRD

## Phase Map
| Phase | Name | Sessions |
|-------|------|----------|
| 01 | Infrastructure & Project Setup | 7 |
| 02 | MOD-IV Data Pipeline | 6 |
| 03 | Core Parcel API | 4 |
| 04 | Federal Lien Integration | 5 |
| 05 | Frontend Application (Foundation) | 6 |
| 06 | Environmental Risk | 5 |
| ... | ... | ... |
| 16 | Frontend: Corporate & Admin Features | 5 |
```

### Step 3: /phasebuild

```
User: /phasebuild
```

Creates Phase 01 structure with session stubs:

```
.spec_system/PRD/phase_01/
├── README.md
├── session_01_project_structure_python_setup.md
├── session_02_docker_compose_postgresql.md
├── session_03_database_extensions_init.md
├── session_04_litestar_application_skeleton.md
├── session_05_alembic_migrations_framework.md
├── session_06_redis_celery_configuration.md
└── session_07_development_tooling_documentation.md
```

---

## Stage 2: Session Workflow

This is where the real work happens. Repeat for each session until the phase is complete.

### Step 4: /nextsession

```
User: /nextsession
```

Claude analyzes project state and recommends the next session:

```markdown
# Next Session Recommendation

**Recommended**: phase09-session01-rutgers-modiv-analysis

## Why This Session
- Phase 09 is next in sequence
- Session 01 establishes historical data foundation
- Prerequisites met: Phase 02 bulk loader patterns available

## Objective
Document Rutgers MOD-IV portal structure and design partitioned
storage for 105M+ historical parcel records (1989-present).

## Estimated Duration
2-3 hours (24 tasks)
```

### Step 5: /sessionspec

```
User: /sessionspec
```

Creates formal specification in the specs directory:

```
.spec_system/specs/phase09-session01-rutgers-modiv-analysis/
└── spec.md
```

**Actual spec.md excerpt:**

```markdown
# Session Specification

**Session ID**: phase09-session01-rutgers-modiv-analysis
**Phase**: 09 - Historical Data + Workflow
**Created**: 2025-12-21

## 1. Session Overview

This session establishes the foundation for loading 105M+ historical
parcel records from Rutgers University's MOD-IV data archive (1989-present).

## 2. Objectives

1. Document Rutgers MOD-IV portal structure and data access patterns
2. Create comprehensive field mapping across tax years (1989-2024)
3. Design parcel_history table with PostgreSQL RANGE partitioning
4. Estimate data volumes and storage requirements per partition
5. Define chunked download strategy for 105M+ records

## 3. Prerequisites

### Required Sessions
- [x] phase02-session02-parcels-schema-migration
- [x] phase02-session04-bulk-loader-implementation

## 4. Scope

### In Scope (MVP)
- Analyze Rutgers MOD-IV data portal structure
- Document available data files by year and county
- Design parcel_history table with 44+ core fields
- Define partition boundaries: 1989-1999, 2000-2009, 2010-2019, 2020+

### Out of Scope
- Actual data loading (Session 03)
- Graph integration (Session 04-05)
```

### Step 6: /tasks

```
User: /tasks
```

Generates detailed task checklist (12-25 tasks):

**Actual tasks.md excerpt:**

```markdown
# Task Checklist

**Session ID**: phase09-session01-rutgers-modiv-analysis
**Total Tasks**: 24
**Estimated Duration**: 2-3 hours

## Legend
- [x] = Completed
- [ ] = Pending
- [P] = Parallelizable
- [S0901] = Session reference (Phase 09, Session 01)

## Progress Summary

| Category | Total | Done | Remaining |
|----------|-------|------|-----------|
| Setup | 3 | 0 | 3 |
| Portal Analysis | 5 | 0 | 5 |
| Field Analysis | 5 | 0 | 5 |
| Schema Design | 5 | 0 | 5 |
| Documentation | 4 | 0 | 4 |
| Validation | 2 | 0 | 2 |
| **Total** | **24** | **0** | **24** |

## Setup (3 tasks)

- [ ] T001 [S0901] Create `docs/historical-data/` directory structure
- [ ] T002 [S0901] Verify access to Rutgers MOD-IV portal
- [ ] T003 [S0901] Review existing Parcel model schema for reference

## Portal Analysis (5 tasks)

- [ ] T004 [S0901] Document portal navigation structure
- [ ] T005 [S0901] Identify all available tax years (1989-2024)
- [ ] T006 [S0901] Document available file formats per year
- [ ] T007 [S0901] [P] Analyze county-level data organization
- [ ] T008 [S0901] [P] Document download mechanisms and rate limits
```

### Step 7: /implement

```
User: /implement
```

Claude works through tasks one by one:

- Reads spec.md and tasks.md for context
- Implements each task sequentially
- Marks tasks `[x]` as completed
- Logs progress in implementation-notes.md
- Handles blockers with documentation

**Progress tracking in real-time:**

```markdown
## Implementation Progress

### T001 - Create directory structure
Status: Complete
Created: docs/historical-data/

### T002 - Verify portal access
Status: Complete
Portal accessible at https://modiv.rutgers.edu/
Identified: 21 counties, years 1989-2024

### T003 - Review Parcel model
Status: Complete
Reference: 44 fields in current schema
```

### Step 8: /validate

```
User: /validate
```

Claude verifies session completeness:

**Actual validation.md:**

```markdown
# Validation Report

**Session ID**: phase09-session01-rutgers-modiv-analysis
**Validated**: 2025-12-21
**Result**: PASS

## Validation Summary

| Check | Status | Notes |
|-------|--------|-------|
| Tasks Complete | PASS | 24/24 tasks |
| Files Exist | PASS | 7/7 files |
| ASCII Encoding | PASS | All ASCII |
| Line Endings | PASS | All LF |
| Quality Gates | PASS | No issues |

**Overall**: PASS

## 1. Task Completion

| Category | Required | Completed | Status |
|----------|----------|-----------|--------|
| Setup | 3 | 3 | PASS |
| Portal Analysis | 5 | 5 | PASS |
| Field Analysis | 5 | 5 | PASS |
| Schema Design | 5 | 5 | PASS |
| Documentation | 4 | 4 | PASS |
| Validation | 2 | 2 | PASS |
| **Total** | **24** | **24** | **PASS** |

## 2. Deliverables Verification

| File | Found | Lines | Status |
|------|-------|-------|--------|
| docs/historical-data/rutgers-portal-analysis.md | Yes | 237 | PASS |
| docs/historical-data/field-mapping.md | Yes | 302 | PASS |
| docs/historical-data/partition-design.md | Yes | 189 | PASS |
```

### Step 9: /updateprd

```
User: /updateprd
```

Claude marks session complete and commits:

- Adds session to `completed_sessions` in state.json
- Updates phase README with completion status
- **Commits and pushes** (your recovery safety net!)
- Clears `current_session`
- Reports next steps

```
Session phase09-session01-rutgers-modiv-analysis marked COMPLETE.

Phase 09 Progress: 1/8 sessions complete (12.5%)

Next: Run /nextsession for session 02 recommendation.
```

### Repeat Until Phase Complete

Continue the cycle:
```
/nextsession -> /sessionspec -> /tasks -> /implement -> /validate -> /updateprd
```

Until all sessions in the phase are done.

---

## Stage 3: Phase Transition

After completing all sessions in a phase, run the phase transition commands.

### /audit

```
User: /audit
```

Adds local dev tooling one bundle at a time:
1. Formatting (Prettier, Ruff)
2. Linting (ESLint, Ruff)
3. Type Safety (TypeScript, mypy)
4. Testing (Jest, pytest + coverage)
5. Git Hooks (husky, pre-commit)

Run multiple times until all bundles are configured.

### /pipeline

```
User: /pipeline
```

Adds CI/CD workflows one bundle at a time:
1. Code Quality (lint + format + type check)
2. Build & Test (build + unit tests + coverage)
3. Security (secrets scanning + CodeQL)
4. Integration (E2E tests)
5. Operations (Dependabot, release tagging)

### /infra

```
User: /infra
```

Adds production infrastructure one bundle at a time:
1. Health (/health endpoint + probes)
2. Security (WAF rules + rate limiting)
3. Backup (DB backup + retention)
4. Deploy (CD webhook from main)

### /documents

```
User: /documents
```

Audits and updates documentation:
- README.md
- CONTRIBUTING.md
- docs/ARCHITECTURE.md
- API documentation
- Per-package READMEs

### Manual Testing

**Highly recommended** - Test the phase's features manually before proceeding.

### /carryforward

```
User: /carryforward
```

Captures lessons learned in CONSIDERATIONS.md:

**Actual excerpt from title_clerk:**

```markdown
## Lessons Learned

### What Worked

- [P01] **PostGIS + Apache AGE + pgvector stack**: Single PostgreSQL
  instance with extensions handles spatial, graph, and vector needs.

- [P02] **Idempotent bulk loader pattern**: Loading 4M+ parcels with
  UPSERT ensures reruns are safe. Always build data pipelines rerunnable.

- [P04] **CourtListener hybrid approach**: Bulk S3 dumps for initial
  seeding (unlimited), REST API for real-time (rate-limited).

- [P07] **PyMuPDF before Tesseract**: Always try native PDF text
  extraction first. OCR is 6x slower and should be fallback only.

- [P08] **5s+ delays for NJ Courts**: Respecting rate limits prevents
  WAF blocks. Aggressive scraping causes IP bans - patience wins.

### What To Avoid

- [P08] **Playwright scraper fragility**: NJ Courts scraper depends on
  DOM selectors that may break with site updates.
```

### /phasebuild (Next Phase)

```
User: /phasebuild
```

Creates structure for the next phase, then return to Stage 2.

---

## Real Project Timeline

The title_clerk project progressed through 16 phases:

| Date | Sessions Completed | Phases |
|------|-------------------|--------|
| Dec 8 | 6 | Phase 01 started |
| Dec 9 | 13 | Phases 01-02 complete |
| Dec 10 | 4 | Phase 03 complete |
| Dec 11 | 11 | Phases 04-05 complete |
| Dec 12-13 | 11 | Phases 06-07 complete |
| Dec 21-22 | 14 | Phases 08-09 complete |
| Dec 22-23 | 8 | Phase 10 complete |
| Dec 24 | 6 | Phase 11 complete |
| Dec 25 | 7 | Phase 12 complete |
| Dec 28 | 7 | Phase 13 complete, 14 in progress |

**79+ sessions completed in ~3 weeks** with consistent structure and documentation.

---

## Multi-Tool Workflows

The Apex Spec System is tool-agnostic. The `.spec_system/` directory, `state.json`, specs, and tasks are plain files -- any AI coding tool can read and write them.

**Switching tools mid-project**: You can use Codex CLI for one phase and Cursor for the next. The workflow state lives in `.spec_system/state.json`, not in any tool-specific config.

**Team with mixed tools**: One developer can use Gemini CLI while another uses Copilot. Both read the same specs and update the same task checklists. Run `bash install.sh --tool all` to set up every tool at once.

**MCP as a universal layer**: The MCP server exposes `analyze_project`, `check_prereqs`, `get_state`, `update_state`, and `list_commands` as tools. Any MCP-capable client (Cursor, VS Code, Cline, Windsurf, Codex, Gemini) can call these directly.

See [docs/COMPATIBILITY-MATRIX.md](COMPATIBILITY-MATRIX.md) for feature support across all tools.

## Key Takeaways

1. **Sessions are atomic** - Each session has clear scope (12-25 tasks, 2-4 hours)

2. **State is tracked** - state.json knows exactly where you are

3. **Git is your safety net** - Every /updateprd commits and pushes

4. **Lessons accumulate** - CONSIDERATIONS.md grows with institutional memory

5. **Phase transitions matter** - /audit, /pipeline, /infra ensure production readiness

6. **Trust the system** - Follow the workflow, resist scope creep

7. **Tool-agnostic** - Switch AI tools freely; the workflow state is portable

---

## Quick Reference

```
Stage 1: INITIALIZATION (once)
/initspec -> /createprd -> /phasebuild

Stage 2: SESSION WORKFLOW (repeat per session)
/nextsession -> /sessionspec -> /tasks -> /implement -> /validate -> /updateprd

Stage 3: PHASE TRANSITION (after all phase sessions complete)
/audit -> /pipeline -> /infra -> /documents -> manual testing -> /carryforward -> /phasebuild
```
