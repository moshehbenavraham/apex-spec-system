# Session 03: CI/CD Quality Gates

**Session ID**: `phase00-session03-ci-cd-quality-gates`
**Status**: Not Started
**Estimated Tasks**: ~18
**Estimated Duration**: 2-3 hours

---

## Objective

Build a GitHub Actions CI pipeline that enforces all quality gates (lint, test, version consistency, ASCII encoding) on every push and pull request.

---

## Scope

### In Scope (MVP)
- Create main CI workflow (.github/workflows/ci.yml)
- Shellcheck lint job for all Bash scripts
- Python lint jobs (black --check, pylint)
- Markdownlint job for command specifications
- Pytest job with coverage reporting
- Bash contract test job
- Version consistency check (README.md, plugin.json, marketplace.json, SKILL.md)
- ASCII encoding validation for scripts, commands, and skills directories
- Dependency caching for pip and npm
- Status badges in README.md

### Out of Scope
- Security scanning (trivy, semgrep) - deferred
- Deployment workflows
- Release automation changes (existing release.yml untouched)
- Branch protection configuration (manual setup)

---

## Prerequisites

- [ ] Session 01 completed (all linters configured and passing)
- [ ] Session 02 completed (all tests written and passing)
- [ ] GitHub Actions available on repository

---

## Deliverables

1. .github/workflows/ci.yml with all quality gate jobs
2. scripts/check-versions.sh for version consistency validation
3. scripts/check-ascii.sh for ASCII encoding validation
4. Updated README.md with CI status badges
5. All CI jobs passing on current codebase

---

## Success Criteria

- [ ] CI triggers on push and pull_request events
- [ ] Shellcheck job passes for all Bash scripts
- [ ] Python lint job passes (black + pylint)
- [ ] Markdownlint job passes for all command files
- [ ] Pytest job passes with coverage output
- [ ] Contract test job passes
- [ ] Version consistency check passes (4 files match)
- [ ] ASCII validation passes on scripts/, commands/, skills/
- [ ] Full pipeline completes in under 5 minutes
- [ ] README.md shows CI status badge
