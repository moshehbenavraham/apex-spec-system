# Session 02: Test Infrastructure

**Session ID**: `phase00-session02-test-infrastructure`
**Status**: Not Started
**Estimated Tasks**: ~20
**Estimated Duration**: 3-4 hours

---

## Objective

Create comprehensive test infrastructure with pytest for Python unit tests (80%+ coverage) and contract tests validating Bash script JSON output schemas.

---

## Scope

### In Scope (MVP)
- Configure pytest with coverage reporting in pyproject.toml
- Create test fixtures and helpers in conftest.py
- Write unit tests for apex_infinite.py core functions (CLI args, LLM manager, session management, SQLite operations)
- Create contract test framework for Bash script JSON outputs
- Write contract tests for analyze-project.sh JSON schema validation
- Write contract tests for check-prereqs.sh JSON schema validation
- Achieve 80%+ line coverage on apex_infinite.py

### Out of Scope
- Integration tests simulating full command workflows (deferred)
- BATS unit tests for individual Bash functions (deferred)
- CI integration (Session 03)
- Performance or load testing

---

## Prerequisites

- [ ] Session 01 completed (linted code is stable baseline)
- [ ] pytest and coverage installable
- [ ] Bash scripts functional for contract test execution

---

## Deliverables

1. pytest configuration in pyproject.toml
2. tests/conftest.py with shared fixtures
3. tests/test_apex_infinite.py with unit tests
4. tests/test_analyze_project.py with contract tests
5. tests/test_check_prereqs.py with contract tests
6. Coverage report showing 80%+ on apex_infinite.py

---

## Success Criteria

- [ ] pytest runs all tests with zero failures
- [ ] Coverage report shows 80%+ line coverage for apex_infinite.py
- [ ] Contract tests validate all JSON output fields for analyze-project.sh
- [ ] Contract tests validate all JSON output fields for check-prereqs.sh
- [ ] Tests are deterministic (no flaky tests)
