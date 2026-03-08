# Session 01: Linting and Formatting

**Session ID**: `phase00-session01-linting-and-formatting`
**Status**: Not Started
**Estimated Tasks**: ~20
**Estimated Duration**: 3-4 hours

---

## Objective

Set up all linting and formatting tools (shellcheck, black, pylint, markdownlint) with proper configuration and fix all existing violations across the codebase.

---

## Scope

### In Scope (MVP)
- Install and configure shellcheck with .shellcheckrc
- Fix all shellcheck warnings in common.sh, analyze-project.sh, check-prereqs.sh
- Install and configure black and pylint in pyproject.toml
- Run black on apex_infinite.py and commit formatted output
- Fix all pylint errors in apex_infinite.py to reach 8.0+ score
- Install and configure markdownlint with .markdownlint.yaml
- Fix markdownlint errors in command specification files

### Out of Scope
- Writing tests (Session 02)
- Setting up CI (Session 03)
- Refactoring code for design improvements
- Adding mypy type checking enforcement (deferred)

---

## Prerequisites

- [ ] Python 3.10+ available
- [ ] Node.js available (for markdownlint-cli)
- [ ] shellcheck installable

---

## Deliverables

1. .shellcheckrc configuration file
2. pyproject.toml with black and pylint configuration
3. .markdownlint.yaml configuration file
4. All 3 Bash scripts pass shellcheck with zero warnings
5. apex_infinite.py passes black with no changes needed
6. apex_infinite.py passes pylint at 8.0+ score
7. All 22 command markdown files pass markdownlint

---

## Success Criteria

- [ ] shellcheck --severity=warning returns zero findings for all scripts
- [ ] black --check apex_infinite.py exits 0
- [ ] pylint apex_infinite.py scores 8.0 or higher
- [ ] markdownlint commands/*.md exits 0
- [ ] No behavioral changes to any script (output unchanged)
