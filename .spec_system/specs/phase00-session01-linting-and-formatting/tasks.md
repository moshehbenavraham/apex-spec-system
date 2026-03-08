# Task Checklist

**Session ID**: `phase00-session01-linting-and-formatting`
**Total Tasks**: 20
**Estimated Duration**: 3-4 hours
**Created**: 2026-03-09

---

## Legend

- `[x]` = Completed
- `[ ]` = Pending
- `[P]` = Parallelizable (can run with other [P] tasks)
- `[S0001]` = Session reference (Phase 00, Session 01)
- `TNNN` = Task ID

---

## Progress Summary

| Category | Total | Done | Remaining |
|----------|-------|------|-----------|
| Setup | 3 | 3 | 0 |
| Foundation | 3 | 3 | 0 |
| Implementation | 10 | 10 | 0 |
| Testing | 4 | 4 | 0 |
| **Total** | **20** | **20** | **0** |

---

## Setup (3 tasks)

Initial configuration and tool installation.

- [x] T001 [S0001] Verify prerequisites met -- shellcheck, python3, pip, node, npm available
- [x] T002 [S0001] [P] Create shellcheck configuration (`.shellcheckrc`)
- [x] T003 [S0001] [P] Create markdownlint configuration (`.markdownlint.yaml`)

---

## Foundation (3 tasks)

Centralized tool configuration and dev dependency management.

- [x] T004 [S0001] Create pyproject.toml with black and pylint configuration (`pyproject.toml`)
- [x] T005 [S0001] Create dev requirements file for linting tools (`apex-infinite-cli/requirements-dev.txt`)
- [x] T006 [S0001] Install all linting tools and verify each tool runs successfully

---

## Implementation (10 tasks)

Fix all linting and formatting violations across the codebase.

- [x] T007 [S0001] Run black formatter on apex_infinite.py and commit formatted output (`apex-infinite-cli/apex_infinite.py`)
- [x] T008 [S0001] Fix shellcheck warnings in common.sh (`scripts/common.sh`)
- [x] T009 [S0001] [P] Fix shellcheck warnings in analyze-project.sh (`scripts/analyze-project.sh`)
- [x] T010 [S0001] [P] Fix shellcheck warnings in check-prereqs.sh (`scripts/check-prereqs.sh`)
- [x] T011 [S0001] Fix pylint errors in apex_infinite.py -- critical errors and conventions (`apex-infinite-cli/apex_infinite.py`)
- [x] T012 [S0001] Fix pylint warnings in apex_infinite.py -- reach 8.0+ score (`apex-infinite-cli/apex_infinite.py`)
- [x] T013 [S0001] [P] Fix markdownlint errors in commands/ batch 1: audit through initspec (`commands/`)
- [x] T014 [S0001] [P] Fix markdownlint errors in commands/ batch 2: phasebuild through validate (`commands/`)
- [x] T015 [S0001] [P] Fix markdownlint errors in docs/ and root-level markdown (`docs/`, `README.md`)
- [x] T016 [S0001] [P] Fix markdownlint errors in skills/ markdown files (`skills/`)

---

## Testing (4 tasks)

Verification that all tools pass clean.

- [x] T017 [S0001] Verify shellcheck --severity=warning returns zero findings for all 3 scripts
- [x] T018 [S0001] [P] Verify black --check exits 0 and pylint scores 8.0+ on apex_infinite.py
- [x] T019 [S0001] [P] Verify markdownlint-cli2 passes on all target markdown files
- [x] T020 [S0001] Validate ASCII encoding on all modified files

---

## Completion Checklist

Before marking session complete:

- [x] All tasks marked `[x]`
- [x] All linting tools pass with zero errors
- [x] All files ASCII-encoded
- [x] implementation-notes.md updated
- [x] Ready for `/validate`

---

## Next Steps

Run `/implement` to begin AI-led implementation.
