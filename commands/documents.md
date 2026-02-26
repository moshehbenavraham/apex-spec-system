---
name: documents
description: Create and maintain project documentation according to monorepo standards
---

# /documents Command

Audit, create, and update project documentation. Documentation is code - stale docs are worse than no docs.

## Rules

1. **Never invent technical details** - only document what actually exists in the codebase
2. **ASCII-only characters** and Unix LF line endings
3. **Current over complete** - a smaller, accurate doc beats a comprehensive stale one
4. **One source of truth** - don't duplicate information; link instead
5. **README naming** - only root gets `README.md`; subdirectories use `README_<dirname>.md`
6. **One command runs everything** - document it prominently in root README

## Steps

### 1. Get Project State (REQUIRED FIRST STEP)

Run the analysis script to understand current project progress:

```bash
# Check for local scripts first, fall back to plugin
if [ -d ".spec_system/scripts" ]; then
  bash .spec_system/scripts/analyze-project.sh --json
else
  bash ${CLAUDE_PLUGIN_ROOT}/scripts/analyze-project.sh --json
fi
```

The JSON output includes:
- `current_phase` - Current phase number
- `completed_sessions` - List of completed session IDs
- `monorepo` - true/false/null from state.json
- `packages` - Array of registered packages (empty if not monorepo)
- `active_package` - Resolved package context (null if not applicable)

Also read:
- `.spec_system/state.json` - Project state and phase/session progress
- `.spec_system/PRD/PRD.md` - Product requirements for context

### 2. Determine Audit Scope (Phase-Focused vs Full)

Check if a phase was recently completed:

1. **Identify recently completed phase**: Look at `completed_sessions` in state.json - if all sessions for a phase are complete but the next phase hasn't started, that phase was "just completed"
2. **Collect phase artifacts**: For the completed phase, read all `implementation-notes.md` files from `.spec_system/specs/phaseNN-session*/`
3. **Extract change manifest**: Build a list of files/directories created or modified during that phase

**Phase-Focused Mode** (when a phase was just completed):
- Prioritize documenting changes from the completed phase
- Focus README updates on newly added packages/services
- Update ARCHITECTURE.md with new components added in the phase
- Still verify all standard files exist, but deep-audit only changed areas
- **Monorepo**: Check which packages had sessions in the completed phase (use `completed_sessions` object format with `package` field). Focus per-package README updates on packages that changed.

**Full Audit Mode** (initial setup, major milestones, or explicit request):
- Audit all documentation comprehensively
- Use when: first run, after multiple phases, or user requests full audit
- **Monorepo**: Verify all packages have README files and that root documentation covers workspace structure

Report the audit mode to the user before proceeding:
```
Audit Mode: Phase-Focused (Phase 01 just completed)
Focus Areas:
- apps/api/ (new - session 01-03)
- packages/auth/ (new - session 04)
- src/middleware/ (modified - session 02, 05)
```

### 3. Audit Existing Documentation

Check for the presence and quality of standard documentation files.

> **Naming Convention**: `README.md` is reserved for project root only. All other README files use `README_<directory-name>.md` (e.g., `apps/web/README_web.md`). This prevents duplicate filenames when searching.

#### Root Level (Required)

| File | Purpose | Check |
|------|---------|-------|
| `README.md` | What this is, repo map, one-command quickstart | Exists? Current? |
| `CONTRIBUTING.md` | Branch conventions, PR rules, commit style | Exists? Current? |
| `LICENSE` | Legal clarity | Exists? |

#### `/docs/` Directory

```
docs/
|-- ARCHITECTURE.md        # System diagram, service relationships, tech stack
|-- CODEOWNERS             # Who owns what
|-- onboarding.md          # Zero-to-hero checklist
|-- development.md         # Local environment, dev scripts
|-- environments.md        # Dev/staging/prod differences
|-- deployment.md          # CI/CD pipelines, release process
|-- adr/                   # Architecture Decision Records
|   \-- NNNN-title.md
|-- runbooks/              # "If X breaks, do Y"
|   \-- incident-response.md
\-- api/                   # API contracts, OpenAPI links
```

#### Per-Package/Service READMEs

Check for `README_<dirname>.md` in each significant directory:

```
apps/web/README_web.md           # Web app specifics
apps/api/README_api.md           # API app specifics
packages/shared/README_shared.md # Shared package usage
services/auth/README_auth.md     # Auth service details
```

Pattern: `[parent]/[dirname]/README_[dirname].md`

**Monorepo**: When `monorepo: true`, use the `packages` array from state.json as the authoritative list of packages needing READMEs. For each package entry, check for `README_<name>.md` in its `path` directory. This ensures documentation tracks the registered packages rather than relying on directory scanning alone.

### 4. Generate Audit Report

Create a mental checklist of:
- Missing files (need to create)
- Stale files (need to update)
- Redundant content (need to consolidate)
- Wordy sections (need to trim)

Report findings to the user before proceeding.

### 5. Create Missing Documentation

For each missing required file:

1. **Check for local override**: `.spec_system/doc-templates/<filename>` (e.g., `.spec_system/doc-templates/README.md`)
2. **If exists**: Use local template
3. **Otherwise**: Use default templates below

> **Local templates take precedence** - same pattern as scripts. Users can customize specific templates without modifying the plugin.

#### README.md Template

```markdown
# [PROJECT_NAME]

[One-line description of what this project does]

## Quick Start

```bash
# One command to run everything
[COMMAND]
```

## Repository Structure

```
.
|-- [dir1]/          # [Purpose]
|-- [dir2]/          # [Purpose]
\-- [dir3]/          # [Purpose]
```

## Documentation

- [Getting Started](docs/onboarding.md)
- [Development Guide](docs/development.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Contributing](CONTRIBUTING.md)

## Tech Stack

- [Technology 1] - [Why]
- [Technology 2] - [Why]

[MONOREPO ONLY - include when monorepo: true]
## Packages

| Package | Path | Description | Stack |
|---------|------|-------------|-------|
| [name] | [path] | [Purpose] | [Stack] |

> Populate from `packages` array in `.spec_system/state.json`
[END MONOREPO ONLY]

## Project Status

See [PRD](.spec_system/PRD/PRD.md) for current progress and roadmap.
```

#### CONTRIBUTING.md Template

```markdown
# Contributing

## Branch Conventions

- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - New features
- `fix/*` - Bug fixes

## Commit Style

Use conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `refactor:` Code refactoring
- `test:` Adding tests

## Pull Request Process

1. Create feature branch from `develop`
2. Make changes with clear commits
3. Write/update tests
4. Update documentation
5. Open PR with description
6. Address review feedback
7. Squash and merge

## Code Review Norms

- Review within 24 hours
- Be constructive and specific
- Approve when ready, request changes when not
```

#### docs/ARCHITECTURE.md Template

```markdown
# Architecture

## System Overview

[High-level description of the system]

## Dependency Graph

```
[Service A] --> [Service B] --> [Database]
     |
     v
[Service C] --> [External API]
```

## Components

### [Component 1]
- **Purpose**: [What it does]
- **Tech**: [Technology used]
- **Location**: `[path/]`

### [Component 2]
- **Purpose**: [What it does]
- **Tech**: [Technology used]
- **Location**: `[path/]`

## Tech Stack Rationale

| Technology | Purpose | Why Chosen |
|------------|---------|------------|
| [Tech 1] | [Purpose] | [Rationale] |
| [Tech 2] | [Purpose] | [Rationale] |

## Data Layer

### Database
- Type: [PostgreSQL / MySQL / MongoDB / etc.]
- Hosting: [self-hosted / managed / serverless]
- Extensions: [PostGIS, pgvector, etc. -- if applicable]

### Schema Overview

| Table/Collection | Purpose | Key Relationships |
|-----------------|---------|-------------------|
| [name] | [purpose] | [relationships] |

### Migration Strategy
- Tool: [name]
- Location: `[path]`
- Naming: `[convention]`

## Data Flow

[Describe how data moves through the system]

[MONOREPO ONLY - include when monorepo: true]
## Package Dependencies

```
[Package A] --> [Package B (shared)]
[Package C] --> [Package B (shared)]
```

| Package | Depends On | Depended By |
|---------|-----------|-------------|
| [name] | [list] | [list] |

> Document cross-package import/dependency relationships.
> Shared libraries should list their consumers.
[END MONOREPO ONLY]

## Key Decisions

See [Architecture Decision Records](docs/adr/) for detailed decision history.
```

#### docs/onboarding.md Template

```markdown
# Onboarding

Zero-to-hero checklist for new developers.

## Prerequisites

- [ ] [Tool 1] installed (`brew install [tool]`)
- [ ] [Tool 2] installed
- [ ] Access to [System/Service]

## Setup Steps

### 1. Clone Repository

```bash
git clone [repo-url]
cd [project-name]
```

### 2. Install Dependencies

```bash
[install command]
```

### 3. Configure Environment

```bash
cp .env.example .env
# Edit .env with your values
```

### 4. Required Secrets

| Variable | Where to Get | Description |
|----------|--------------|-------------|
| `API_KEY` | [Location] | [Purpose] |
| `DB_URL` | [Location] | [Purpose] |

### 5. Start Development

```bash
[start command]
```

### 6. Verify Setup

- [ ] App runs at `http://localhost:[port]`
- [ ] Tests pass: `[test command]`
- [ ] Can access [key feature]

## Common Issues

### [Issue 1]
**Solution**: [Fix]

### [Issue 2]
**Solution**: [Fix]
```

#### docs/development.md Template

```markdown
# Development Guide

## Local Environment

### Required Tools

- [Tool 1] v[version]+
- [Tool 2] v[version]+

### Port Mappings

| Service | Port | URL |
|---------|------|-----|
| [Service 1] | [port] | http://localhost:[port] |
| [Service 2] | [port] | http://localhost:[port] |

## Dev Scripts

| Command | Purpose |
|---------|---------|
| `[cmd]` | [Description] |
| `[cmd]` | [Description] |
| `[cmd]` | [Description] |

## Database

### Setup
1. Start database: `[start command]`
2. Run migrations: `[migration command]`
3. Seed data: `[seed command]`
4. Reset database: `[reset command]`

### Useful Commands

| Action | Command |
|--------|---------|
| Create migration | `[command]` |
| Run migrations | `[command]` |
| Rollback last | `[command]` |
| Reset + seed | `[command]` |
| DB console | `[command]` |

## Development Workflow

1. Pull latest `develop`
2. Create feature branch
3. Make changes
4. Run tests
5. Open PR

## Testing

```bash
# Run all tests
[test command]

# Run specific tests
[specific test command]

# Run with coverage
[coverage command]
```

## Debugging

### [Common scenario 1]
[How to debug]

### [Common scenario 2]
[How to debug]
```

#### docs/environments.md Template

```markdown
# Environments

## Environment Overview

| Environment | URL | Purpose |
|-------------|-----|---------|
| Development | localhost | Local development |
| Staging | [url] | Pre-production testing |
| Production | [url] | Live system |

## Configuration Differences

| Config | Dev | Staging | Prod |
|--------|-----|---------|------|
| [Setting 1] | [value] | [value] | [value] |
| [Setting 2] | [value] | [value] | [value] |

## Environment Variables

### Required in All Environments

- `[VAR_1]`: [Description]
- `[VAR_2]`: [Description]

### Environment-Specific

#### Development
- `[DEV_VAR]`: [Description]

#### Production
- `[PROD_VAR]`: [Description]
```

#### docs/deployment.md Template

```markdown
# Deployment

## Local Dev

### Start Everything

```bash
[one-command start, e.g., docker compose up -d]
```

### Verify

```bash
curl http://localhost:[port]/health
```

### Stop

```bash
[stop command, e.g., docker compose down]
```

## CI/CD Pipeline

```
Push --> Build --> Test --> [Staging] --> [Production]
```

## Build Process

```bash
[build command]
```

## Production Deploy

### Release Process

1. Merge to `main`
2. CI runs tests
3. Build artifacts created
4. Deploy to staging
5. Smoke tests (`curl -f https://[staging-url]/health`)
6. Deploy to production
7. Verify production health (`curl -f https://[production-url]/health`)

### Deploy Command

```bash
[deploy command or "automatic via CI on push to main"]
```

### Rollback

```bash
[rollback command, e.g., platform revert, git revert + redeploy, previous image tag]
```

**When to rollback**: Health check fails post-deploy, error rate spikes, or critical bug reported.

## Environments

| Environment | URL | Deploy Trigger |
|-------------|-----|----------------|
| Local | http://localhost:[port] | Manual |
| Staging | [url] | Push to develop (or manual) |
| Production | [url] | Push to main (after CI passes) |

## Monitoring

- Logs: [Location]
- Metrics: [Location]
- Alerts: [Location]
- Health: [health endpoint URL]
```

#### docs/adr/0000-template.md (ADR Template)

```markdown
# [Number]. [Title]

**Status:** Proposed | Accepted | Deprecated | Superseded
**Date:** YYYY-MM-DD

## Context

What prompted this decision?

## Options Considered

1. [Option A] - [pros/cons]
2. [Option B] - [pros/cons]

## Decision

What we chose to do.

## Rationale

Why this option over the alternatives.

## Consequences

Trade-offs, what this enables, what it prevents.
```

#### docs/runbooks/incident-response.md Template

```markdown
# Incident Response

## Severity Levels

| Level | Description | Response Time |
|-------|-------------|---------------|
| P0 | Complete outage | Immediate |
| P1 | Major feature broken | < 1 hour |
| P2 | Minor feature broken | < 4 hours |
| P3 | Cosmetic/minor | Next business day |

## On-Call Contacts

| Role | Contact |
|------|---------|
| Primary | [Contact] |
| Secondary | [Contact] |

## Common Incidents

### [Incident Type 1]

**Symptoms**: [What you'll see]

**Resolution**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

### [Incident Type 2]

**Symptoms**: [What you'll see]

**Resolution**:
1. [Step 1]
2. [Step 2]
```

#### README_[dirname].md Template (Per-Package/Service)

```markdown
# [PACKAGE_NAME]

[One-line description]

## Usage

```bash
# Install/import
[import/install command]
```

```typescript
// Example usage
[code example]
```

## Run Commands

| Command | Purpose |
|---------|---------|
| `[cmd]` | [Description] |

## Key Dependencies

- [Dependency 1] - [Why]
- [Dependency 2] - [Why]

## API Reference

### [Function/Class 1]
[Brief description and signature]

### [Function/Class 2]
[Brief description and signature]
```

### 6. Update Existing Documentation

For each existing documentation file:

1. **Read current content**
2. **Compare against project state** from `.spec_system/`
3. **Identify discrepancies**:
   - Features documented but not implemented
   - Features implemented but not documented
   - Outdated instructions
   - Broken links
   - Stale information
4. **Update to reflect current state**
5. **Remove redundancy and wordiness**

### 7. Sync with Spec System Progress

Cross-reference documentation with:
- Completed sessions (should be documented)
- Current phase objectives
- Technical stack decisions
- Architecture choices made in specs

Ensure README and ARCHITECTURE reflect actual implemented state, not planned future state.

#### Phase-Focused Sync (when applicable)

When in Phase-Focused Mode, use implementation-notes.md files as the primary source:

1. **Read all implementation notes** for the completed phase:
   ```
   .spec_system/specs/phaseNN-session*/implementation-notes.md
   ```

2. **Extract structured changes**:
   - Files created (need documentation if they're new packages/services)
   - Files modified (may need doc updates if behavior changed)
   - Dependencies added (update tech stack sections)
   - APIs added/changed (update API docs)

3. **Prioritize documentation updates** based on change type:
   | Change Type | Documentation Action |
   |-------------|---------------------|
   | New package/service | Create README_<name>.md |
   | New API endpoints | Update docs/api/ |
   | New dependencies | Update tech stack in README, ARCHITECTURE |
   | Config changes | Update onboarding.md, environments.md |
   | New scripts | Update development.md |

4. **Skip deep-audit** for unchanged areas - verify file exists, don't rewrite content

### 8. Quality Checks

For all documentation files:

#### Accuracy
- All commands work
- All paths exist
- All links valid
- Version numbers current

#### Conciseness
- No redundant sections
- No verbose explanations where a command suffices
- No duplicate information across files

#### Completeness
- All required files present
- All sections filled in (no TODO placeholders left)
- Env var inventory complete

### 9. Generate Documentation Report

Create `.spec_system/docs-audit.md`:

```markdown
# Documentation Audit Report

**Date**: [YYYY-MM-DD]
**Project**: [PROJECT_NAME]
**Audit Mode**: [Phase-Focused (Phase NN) | Full Audit]

## Summary

| Category | Required | Found | Status |
|----------|----------|-------|--------|
| Root files | 3 | N | PASS/FAIL |
| /docs/ files | 8 | N | PASS/FAIL |
| ADRs | N/A | N | INFO |
| Package READMEs | N | N | PASS/FAIL |

## Phase Focus (if applicable)

**Completed Phase**: Phase NN - [Phase Name]
**Sessions Analyzed**: [list of session names]

[MONOREPO ONLY]
### Per-Package Documentation Status

| Package | Path | README | Status |
|---------|------|--------|--------|
| [name] | [path] | README_[name].md | Found / Missing / Updated |

[END MONOREPO ONLY]

### Change Manifest (from implementation-notes.md)

| Session | Files Created | Files Modified |
|---------|---------------|----------------|
| session01-name | path/to/new.ts | path/to/existing.ts |
| session02-name | ... | ... |

## Actions Taken

### Created
- [List of files created]

### Updated
- [List of files updated with summary of changes]

### Verified (No Changes Needed)
- [List of files verified as current]

## Documentation Gaps

[Any remaining gaps that need human input]

## Next Audit

Recommend re-running `/documents` after:
- Completing the next phase
- Adding new packages/services
- Making architectural changes
```

### 10. Report to User

Show:
- Files created
- Files updated
- Current documentation coverage
- Any gaps requiring human input

## Output

Report: audit mode used, files created/updated, documentation coverage, gaps requiring human input, and link to `.spec_system/docs-audit.md`. If all documents are satisfactory, recommend `/phasebuild` for the next phase.
