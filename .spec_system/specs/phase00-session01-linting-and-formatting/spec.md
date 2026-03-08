# Session Specification

**Session ID**: `phase00-session01-linting-and-formatting`
**Phase**: 00 - Foundation
**Status**: Not Started
**Created**: 2026-03-09

---

## 1. Session Overview

This session establishes the complete linting and formatting toolchain for the Apex Spec System plugin. The codebase currently has zero automated code quality enforcement -- no shellcheck, no Python linter or formatter, and no markdown linter. This session adds all three, configures them to match project conventions, and fixes every existing violation.

The deliverables create a stable, clean baseline that Session 02 (Test Infrastructure) and Session 03 (CI/CD) will build upon. Every subsequent session benefits from consistent code style and automated quality checks during development.

The scope covers 3 Bash scripts (2,180 lines), 1 Python CLI (994 lines), and 22+ markdown command specifications. All tool configurations are centralized in standard config files at the project root.

---

## 2. Objectives

1. Configure shellcheck, black, pylint, and markdownlint with project-appropriate rules
2. Achieve zero shellcheck warnings (severity: warning+) across all 3 Bash scripts
3. Achieve black compliance and pylint score of 8.0+ on apex_infinite.py
4. Achieve zero markdownlint errors across all command specification and documentation files

---

## 3. Prerequisites

### Required Sessions
- None (first session in Phase 00)

### Required Tools/Knowledge
- shellcheck (Bash static analysis)
- Python 3.10+ with pip
- black (Python formatter)
- pylint (Python linter)
- Node.js with npm (for markdownlint-cli2)
- markdownlint-cli2 (Markdown linter)

### Environment Requirements
- Write access to project root for config files
- pip install capability for Python dev dependencies
- npm install capability (global or npx) for markdownlint

---

## 4. Scope

### In Scope (MVP)
- Create .shellcheckrc with severity and directive config - standard shellcheck setup
- Create pyproject.toml with black and pylint configuration sections - centralized Python tooling
- Create .markdownlint.yaml with rules matching project markdown conventions - ASCII-only, ATX headers
- Create dev requirements file for Python linting dependencies - reproducible dev setup
- Fix all shellcheck warnings in scripts/common.sh, scripts/analyze-project.sh, scripts/check-prereqs.sh
- Run black on apex_infinite.py and fix all formatting - single commit for formatting
- Fix pylint errors in apex_infinite.py to reach 8.0+ score - focus on errors and warnings
- Fix markdownlint errors across commands/, docs/, skills/, and root markdown files

### Out of Scope (Deferred)
- Writing tests for any code - *Reason: Session 02 scope*
- Setting up CI pipelines - *Reason: Session 03 scope*
- Adding mypy type checking enforcement - *Reason: deferred per PRD*
- Refactoring code for design improvements - *Reason: PRD non-goal*
- Adding pre-commit hooks - *Reason: open question in PRD, deferred*

---

## 5. Technical Approach

### Architecture
All linting tools are configured via standard config files at the project root. No custom wrapper scripts are needed -- developers run tools directly. Configuration targets the specific file types and directories in this project.

### Design Patterns
- **Centralized config**: All Python tooling in pyproject.toml, shell config in .shellcheckrc, markdown in .markdownlint.yaml
- **Fix-then-verify**: Apply formatting first (black), then fix linter issues, then verify clean state
- **Behavioral preservation**: No script output or behavior changes -- only style and lint compliance

### Technology Stack
- shellcheck 0.9+ (Bash static analyzer)
- black 24+ (Python formatter, pyproject.toml config)
- pylint 3+ (Python linter, pyproject.toml config)
- markdownlint-cli2 0.12+ (Markdown linter, .markdownlint.yaml config)

---

## 6. Deliverables

### Files to Create
| File | Purpose | Est. Lines |
|------|---------|------------|
| `.shellcheckrc` | Shellcheck configuration | ~10 |
| `pyproject.toml` | Black and pylint configuration | ~40 |
| `.markdownlint.yaml` | Markdownlint rules | ~20 |
| `apex-infinite-cli/requirements-dev.txt` | Python dev dependencies | ~5 |

### Files to Modify
| File | Changes | Est. Lines Changed |
|------|---------|------------|
| `scripts/common.sh` | Fix shellcheck warnings | ~30 |
| `scripts/analyze-project.sh` | Fix shellcheck warnings | ~15 |
| `scripts/check-prereqs.sh` | Fix shellcheck warnings | ~30 |
| `apex-infinite-cli/apex_infinite.py` | Black formatting + pylint fixes | ~80 |
| `commands/*.md` (22 files) | Fix markdownlint errors | ~50 total |
| `docs/*.md` (3 files) | Fix markdownlint errors | ~10 total |
| `skills/**/*.md` | Fix markdownlint errors | ~10 |
| `README.md` | Fix markdownlint errors | ~5 |

---

## 7. Success Criteria

### Functional Requirements
- [ ] shellcheck --severity=warning returns zero findings for all 3 scripts
- [ ] black --check apex-infinite-cli/apex_infinite.py exits 0
- [ ] pylint apex-infinite-cli/apex_infinite.py scores 8.0 or higher
- [ ] markdownlint-cli2 commands/*.md exits 0
- [ ] markdownlint-cli2 docs/*.md exits 0
- [ ] No behavioral changes to any script (output unchanged for same input)

### Testing Requirements
- [ ] Run each Bash script with --help or --json to verify unchanged output
- [ ] Manual verification that shellcheck, black, pylint, markdownlint all pass

### Non-Functional Requirements
- [ ] All config files under 50 lines each
- [ ] Dev dependency install completes in under 60 seconds

### Quality Gates
- [ ] All files ASCII-encoded
- [ ] Unix LF line endings
- [ ] Code follows project conventions (CONVENTIONS.md)

---

## 8. Implementation Notes

### Key Considerations
- Black formatting should be applied in a single pass before pylint fixes, since black changes may resolve some pylint issues (line length, whitespace)
- Shellcheck fixes must preserve script output contracts -- the JSON output format must remain identical
- Markdownlint rules should be permissive enough for the YAML-style frontmatter used in command files
- The pyproject.toml is new and only covers black/pylint -- pytest config will be added in Session 02

### Potential Challenges
- **Shellcheck SC2086 (word splitting)**: Many Bash scripts may have unquoted variables -- fix by quoting all expansions per CONVENTIONS.md
- **Pylint import ordering**: May conflict with black -- resolve by disabling pylint's import-order check or configuring isort
- **Markdownlint HTML blocks**: Command specs may use inline HTML that triggers MD033 -- configure rule to allow specific tags
- **Black line length vs pylint**: Ensure both tools agree on max line length (88 is black default)

### Relevant Considerations
- No active concerns or lessons learned yet (clean slate per CONSIDERATIONS.md)

---

## 9. Testing Strategy

### Unit Tests
- Not applicable (Session 02 scope)

### Integration Tests
- Not applicable (Session 02 scope)

### Manual Testing
- Run shellcheck on each script and verify zero output
- Run black --check and verify exit code 0
- Run pylint and verify score >= 8.0
- Run markdownlint-cli2 on each target directory and verify zero output
- Run analyze-project.sh --json and check-prereqs.sh --json to verify output unchanged

### Edge Cases
- Scripts sourcing common.sh -- ensure shellcheck directive for source path
- Markdown files with code blocks -- ensure markdownlint ignores fenced code content
- Python file with long strings/URLs -- ensure black handles gracefully

---

## 10. Dependencies

### External Libraries
- shellcheck: system package (apt/brew)
- black: pip (>=24.0)
- pylint: pip (>=3.0)
- markdownlint-cli2: npm (>=0.12.0)

### Other Sessions
- **Depends on**: None
- **Depended by**: Session 02 (Test Infrastructure), Session 03 (CI/CD Quality Gates), Session 04 (Security Hardening)

---

## Next Steps

Run `/implement` to begin AI-led implementation.
