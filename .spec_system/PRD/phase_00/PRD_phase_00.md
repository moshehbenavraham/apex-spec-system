# PRD Phase 00: Foundation

**Status**: In Progress
**Sessions**: 4
**Estimated Duration**: 8-16 hours (2-4 days)

**Progress**: 1/4 sessions (25%)

---

## Overview

Bring the Apex Spec System plugin from its current functional state to production quality through automated linting, testing, CI/CD pipelines, security hardening, and documentation cleanup. The codebase consists of 3 Bash scripts (~2280 lines), 1 Python CLI (~994 lines), 22 Markdown command specifications, and plugin manifests.

---

## Progress Tracker

| Session | Name | Status | Est. Tasks | Validated |
|---------|------|--------|------------|-----------|
| 01 | Linting and Formatting | Complete | 20 | 2026-03-09 |
| 02 | Test Infrastructure | Not Started | ~20 | - |
| 03 | CI/CD Quality Gates | Not Started | ~18 | - |
| 04 | Security Hardening and Documentation | Not Started | ~18 | - |

---

## Completed Sessions

- **Session 01: Linting and Formatting** - Completed 2026-03-09 (20 tasks)

---

## Upcoming Sessions

- Session 02: Test Infrastructure

---

## Objectives

1. Establish lint and format tooling (shellcheck, black, pylint, markdownlint) with zero violations
2. Create test infrastructure with pytest, contract tests, and 80%+ Python coverage
3. Build CI/CD pipeline enforcing quality gates on every PR
4. Harden apex-infinite-cli input validation and dependency security
5. Clean up documentation (AGENTS.md, GEMINI.md symlinks, missing docs)

---

## Prerequisites

- None (this is the first phase)

---

## Technical Considerations

### Architecture
- Bash scripts use `set -euo pipefail` and output JSON via jq
- Python CLI uses Click + Rich, SQLite for history, subprocess for Claude Code
- Plugin manifests must stay synchronized across 4 files

### Technologies
- shellcheck for Bash linting
- black + pylint + mypy for Python quality
- markdownlint for Markdown consistency
- pytest + coverage for Python testing
- GitHub Actions for CI/CD
- pip-audit for dependency security scanning

### Risks
- **Shellcheck fixes may change script behavior**: Run contract tests after each fix to verify output unchanged
- **Black formatting may create large diffs**: Apply formatting in a single dedicated commit
- **CI may be slow with full test suite**: Parallelize lint and test jobs, cache dependencies
- **Existing scripts may have undocumented behaviors**: Write contract tests first to capture current behavior

### Relevant Considerations
<!-- No active concerns or lessons learned yet - first phase -->

---

## Success Criteria

Phase complete when:
- [ ] All 4 sessions completed and validated
- [ ] shellcheck passes on all 3 Bash scripts with zero warnings
- [ ] pylint scores apex_infinite.py at 8.0+ with zero errors
- [ ] black reports no formatting changes needed
- [ ] pytest passes with 80%+ coverage on apex_infinite.py
- [ ] Contract tests validate JSON output schema for analyze-project.sh and check-prereqs.sh
- [ ] CI pipeline runs on every PR and blocks merge on failure
- [ ] Version consistency check passes (4 files match)
- [ ] ASCII validation passes on all scripts, commands, and skills
- [ ] markdownlint passes on all command specification files
- [ ] No pip-audit findings in Python dependencies
- [ ] AGENTS.md and GEMINI.md clarified or removed

---

## Dependencies

### Depends On
- None (first phase)

### Enables
- Future phases: feature development, integration testing, advanced security scanning
