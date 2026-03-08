# Apex Spec System - Product Requirements Document

## Overview

Audit and harden the Apex Spec System, a Claude Code plugin that provides specification-driven AI development workflows. The plugin breaks large projects into manageable 2-4 hour sessions with 12-25 tasks each, using a 13-command workflow plus 9 utility commands. The codebase consists of Bash scripts (~70KB), a Python CLI (~1000 lines), and 22 Markdown command specifications.

This PRD scopes the work needed to bring the plugin from its current functional state to production quality through automated testing, linting, CI/CD, security hardening, and documentation cleanup.

## Goals

1. Establish automated test coverage for all Bash scripts and the Python CLI
2. Add linting, formatting, and static analysis across all code (shellcheck, pylint/black, markdownlint)
3. Build CI/CD pipelines that enforce quality gates on every PR
4. Harden security by validating inputs, scanning dependencies, and enforcing ASCII encoding
5. Clean up documentation gaps and enforce version consistency across all manifest files

## Non-Goals

- Rewriting existing command specifications (they are already thorough)
- Adding new workflow commands or features
- Changing the plugin architecture or state management design
- Building a web UI or dashboard for the spec system
- Supporting additional LLM providers in apex-infinite-cli beyond current three

## Users and Use Cases

### Primary Users

- **Plugin developer**: Maintains and extends the Apex Spec System plugin
- **AI agent (Claude Code)**: Executes commands autonomously via apex-infinite-cli
- **End user**: Installs the plugin and runs workflow commands in their projects

### Key Use Cases

1. Developer pushes a PR and CI validates scripts, Python code, markdown, ASCII encoding, and version consistency automatically
2. Developer runs shellcheck locally before committing Bash changes
3. AI agent runs apex-infinite-cli without hitting unhandled edge cases or injection vectors
4. End user upgrades to a new plugin version with confidence that quality gates passed

## Requirements

### MVP Requirements

- Developer can run shellcheck on all Bash scripts with zero errors
- Developer can run pylint and black on apex_infinite.py with zero errors
- Developer can run pytest against script output contracts (JSON schema validation)
- CI pipeline validates all quality gates on every push and PR
- CI pipeline enforces version consistency across README.md, plugin.json, marketplace.json, and SKILL.md
- CI pipeline validates ASCII-only encoding in all generated files
- Developer can run markdownlint on all command specifications
- Developer can see test coverage metrics in CI output
- apex-infinite-cli validates and escapes all subprocess arguments
- apex-infinite-cli uses parameterized queries for SQLite operations

### Deferred Requirements

- Developer can run integration tests that simulate full command workflows
- Developer can run security scanning (trivy, semgrep) in CI
- Developer can generate architecture decision records from templates
- Developer can run BATS tests for individual Bash functions in common.sh

## Non-Functional Requirements

- **Test Coverage**: Minimum 80% line coverage for apex_infinite.py, contract tests for all script JSON outputs
- **Lint Compliance**: Zero shellcheck warnings (severity: error+warning), zero pylint errors, zero markdownlint errors on command files
- **CI Speed**: Full CI pipeline completes in under 5 minutes
- **ASCII Compliance**: All files in scripts/, commands/, and skills/ pass `LC_ALL=C grep -P '[^\x00-\x7F]'` with no matches
- **Security**: No known CVEs in Python dependencies (pip-audit clean)

## Constraints and Dependencies

- Bash scripts must remain POSIX-compatible where possible (target: bash 4.4+)
- Python CLI requires Python 3.10+ (existing constraint)
- CI runs on GitHub Actions (existing .github/workflows/ directory)
- Plugin manifests must follow Claude Code plugin specification
- All output files must be ASCII-only with Unix LF line endings (existing project rule)

## Phases

This system delivers the product via phases. Each phase is implemented via multiple 2-4 hour sessions (12-25 tasks each).

| Phase | Name | Sessions | Status |
|-------|------|----------|--------|
| 00 | Foundation | 4 | Not Started |

## Phase 00: Foundation

### Objectives

1. Add linting and formatting tooling for all code (shellcheck, black, pylint, markdownlint)
2. Create test infrastructure (pytest for Python, contract tests for script JSON outputs)
3. Build CI pipeline with quality gates (lint, test, version check, ASCII check)
4. Harden apex-infinite-cli input validation and error handling
5. Clean up documentation (AGENTS.md, GEMINI.md, missing docs)

### Sessions

| Session | Name | Est. Tasks |
|---------|------|------------|
| 01 | Linting and Formatting | ~20 |
| 02 | Test Infrastructure | ~20 |
| 03 | CI/CD Quality Gates | ~18 |
| 04 | Security Hardening and Documentation | ~18 |

See `.spec_system/PRD/phase_00/` for detailed session stubs.

## Technical Stack

- Bash 4.4+ - primary scripting language for project analysis and prerequisite checking
- Python 3.10+ - apex-infinite-cli autonomous workflow manager
- Markdown - command specifications and documentation
- YAML - configuration (config.yaml)
- JSON - state files (state.json) and plugin manifests (plugin.json, marketplace.json)
- GitHub Actions - CI/CD platform
- SQLite - history database for apex-infinite-cli

## Success Criteria

- [ ] shellcheck passes on all 3 Bash scripts with zero warnings
- [ ] pylint scores apex_infinite.py at 8.0+ with zero errors
- [ ] black reports no formatting changes needed on apex_infinite.py
- [ ] pytest passes with 80%+ coverage on apex_infinite.py
- [ ] Contract tests validate JSON output schema for analyze-project.sh and check-prereqs.sh
- [ ] CI pipeline runs on every PR and blocks merge on failure
- [ ] Version consistency check passes (4 files match)
- [ ] ASCII validation passes on all scripts, commands, and skills
- [ ] markdownlint passes on all command specification files
- [ ] No pip-audit findings in Python dependencies
- [ ] AGENTS.md and GEMINI.md clarified or removed

## Risks

- **Shellcheck fixes may change script behavior**: Mitigation - run contract tests after each shellcheck fix to verify output unchanged
- **Black formatting may create large diffs**: Mitigation - apply formatting in a single dedicated commit before other changes
- **CI may be slow with full test suite**: Mitigation - parallelize lint and test jobs, cache dependencies
- **Existing scripts may have undocumented behaviors**: Mitigation - write contract tests first to capture current behavior before making changes

## Assumptions

- GitHub Actions minutes are available for CI runs
- shellcheck, black, pylint, and markdownlint are installable in the CI environment
- Current script JSON output formats are correct and should be treated as contracts
- The 4 version-tracking files (README.md, plugin.json, marketplace.json, SKILL.md) should always match

## Open Questions

1. Should BATS be used for Bash unit testing or are contract tests (validating JSON output) sufficient?
2. What is the purpose of AGENTS.md and GEMINI.md - keep, merge, or remove?
3. Should pre-commit hooks be added locally or only enforced via CI?
4. Is there a target shellcheck severity level (error-only vs error+warning+info)?
