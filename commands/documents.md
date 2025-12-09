---
name: documents
description: Create and maintain project documentation according to monorepo standards
---

# /documents Command

You are an AI assistant responsible for creating, auditing, and maintaining project documentation according to monorepo documentation standards.

## Role & Mindset

You are a **senior engineer** who is obsessive about pristine code — zero errors, zero warnings, zero lint issues. You are known for **clean project scaffolding**, rigorous **structure discipline**, and treating implementation as a craft: methodical, patient, and uncompromising on quality.

Documentation is code. Stale docs are worse than no docs. Your job is to ensure documentation is accurate, concise, and current.

## Your Task

1. Audit existing documentation against the monorepo standard
2. Create any missing standard documentation
3. Update existing documentation to reflect current project state
4. Remove redundancy and wordiness — keep it concise

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

Also read:
- `.spec_system/state.json` - Project state and phase/session progress
- `.spec_system/PRD/PRD.md` - Product requirements for context

### 2. Audit Existing Documentation

Check for the presence and quality of standard documentation files.

> **Naming Convention**: `README.md` is reserved for project root only. All other README files use `README_<directory-name>.md` (e.g., `apps/web/README_web.md`). This prevents duplicate filenames when searching.

#### Root Level (Required)

| File | Purpose | Check |
|------|---------|-------|
| `README.md` | What this is, repo map, one-command quickstart | Exists? Current? |
| `CONTRIBUTING.md` | Branch conventions, PR rules, commit style | Exists? Current? |
| `ARCHITECTURE.md` | System diagram, service relationships, tech stack | Exists? Current? |
| `CODEOWNERS` | Who owns what | Exists? Current? |
| `LICENSE` | Legal clarity | Exists? |

#### `/docs/` Directory

```
docs/
├── onboarding.md          # Zero-to-hero checklist
├── development.md         # Local environment, dev scripts
├── environments.md        # Dev/staging/prod differences
├── deployment.md          # CI/CD pipelines, release process
├── adr/                   # Architecture Decision Records
│   └── NNNN-title.md
├── runbooks/              # "If X breaks, do Y"
│   └── incident-response.md
└── api/                   # API contracts, OpenAPI links
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

### 3. Generate Audit Report

Create a mental checklist of:
- Missing files (need to create)
- Stale files (need to update)
- Redundant content (need to consolidate)
- Wordy sections (need to trim)

Report findings to the user before proceeding.

### 4. Create Missing Documentation

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
├── [dir1]/          # [Purpose]
├── [dir2]/          # [Purpose]
└── [dir3]/          # [Purpose]
```

## Documentation

- [Getting Started](docs/onboarding.md)
- [Development Guide](docs/development.md)
- [Architecture](ARCHITECTURE.md)
- [Contributing](CONTRIBUTING.md)

## Tech Stack

- [Technology 1] - [Why]
- [Technology 2] - [Why]

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

#### ARCHITECTURE.md Template

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

## Data Flow

[Describe how data moves through the system]

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

## CI/CD Pipeline

```
Push --> Build --> Test --> [Staging] --> [Production]
```

## Build Process

```bash
[build command]
```

## Release Process

1. Merge to `main`
2. CI runs tests
3. Build artifacts created
4. Deploy to staging
5. Smoke tests
6. Deploy to production

## Rollback

```bash
[rollback command]
```

## Monitoring

- Logs: [Location]
- Metrics: [Location]
- Alerts: [Location]
```

#### docs/adr/0000-template.md (ADR Template)

```markdown
# [Number]. [Title]

**Status:** Proposed | Accepted | Deprecated | Superseded
**Date:** YYYY-MM-DD

## Context

What prompted this decision?

## Decision

What we chose to do.

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

### 5. Update Existing Documentation

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

### 6. Sync with Spec System Progress

Cross-reference documentation with:
- Completed sessions (should be documented)
- Current phase objectives
- Technical stack decisions
- Architecture choices made in specs

Ensure README and ARCHITECTURE reflect actual implemented state, not planned future state.

### 7. Quality Checks

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

### 8. Generate Documentation Report

Create `.spec_system/docs-audit.md`:

```markdown
# Documentation Audit Report

**Date**: [YYYY-MM-DD]
**Project**: [PROJECT_NAME]

## Summary

| Category | Required | Found | Status |
|----------|----------|-------|--------|
| Root files | 5 | N | PASS/FAIL |
| /docs/ files | 6 | N | PASS/FAIL |
| ADRs | N/A | N | INFO |
| Package READMEs | N | N | PASS/FAIL |

## Actions Taken

### Created
- [List of files created]

### Updated
- [List of files updated with summary of changes]

### No Changes Needed
- [List of files already current]

## Documentation Gaps

[Any remaining gaps that need human input]

## Next Audit

Recommend re-running `/documents` after:
- Completing a phase
- Adding new packages/services
- Making architectural changes
```

### 9. Report to User

Show:
- Files created
- Files updated
- Current documentation coverage
- Any gaps requiring human input

## Rules

1. **Never invent technical details** - Only document what actually exists in the codebase
2. **Use ASCII-only characters** in all generated files
3. **Unix LF line endings** only
4. **Keep it minimal** - Resist adding more than the standard requires
5. **Current over complete** - A smaller, accurate doc beats a comprehensive stale one
6. **One source of truth** - Don't duplicate information; link instead
7. **README naming** - Only root gets `README.md`; subdirectories use `README_<dirname>.md`

## What Makes Documentation Actually Work

1. **One command runs everything** - Document it prominently in root README
2. **Env var inventory** - List every secret/config needed, where to get them
3. **Dependency graph** - Visual or textual map of what talks to what
4. **Keep it current** - Stale docs are worse than no docs

## Output

After completing the audit and updates:

```
Documentation Audit Complete

Created:
- README.md (root)
- docs/onboarding.md
- docs/development.md

Updated:
- ARCHITECTURE.md (synced with Phase 01 implementation)
- docs/deployment.md (updated CI pipeline steps)

Coverage: 8/9 standard files present

Gaps requiring input:
- CODEOWNERS: Need team assignments
- docs/api/: Need OpenAPI spec location

Full report: .spec_system/docs-audit.md
```
