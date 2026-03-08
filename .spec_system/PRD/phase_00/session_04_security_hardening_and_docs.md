# Session 04: Security Hardening and Documentation

**Session ID**: `phase00-session04-security-hardening-and-docs`
**Status**: Not Started
**Estimated Tasks**: ~18
**Estimated Duration**: 2-3 hours

---

## Objective

Harden apex-infinite-cli against injection and input validation issues, add dependency security scanning, and clean up project documentation gaps.

---

## Scope

### In Scope (MVP)
- Audit all subprocess calls in apex_infinite.py for injection risks
- Ensure all subprocess arguments are validated and escaped
- Verify all SQLite operations use parameterized queries (no string concatenation)
- Add input validation for CLI arguments and config values
- Add pip-audit to CI pipeline for dependency vulnerability scanning
- Add requirements.txt pinning with hashes
- Resolve AGENTS.md and GEMINI.md (currently symlinks to CLAUDE.md)
- Review and update README.md for accuracy
- Review existing docs (GUIDANCE.md, WALKTHROUGH.md, UTILITIES.md) for completeness
- Add any missing documentation identified during audit

### Out of Scope
- Adding semgrep or trivy scanning (deferred)
- Rewriting command specification content
- Adding new workflow commands or features
- Architecture decision records (deferred)

---

## Prerequisites

- [ ] Session 01-03 completed (lint, test, CI all in place)
- [ ] pip-audit installable

---

## Deliverables

1. Hardened apex_infinite.py with validated subprocess calls
2. Verified parameterized SQLite queries
3. pip-audit added to CI workflow
4. Pinned requirements.txt with hashes
5. AGENTS.md and GEMINI.md resolved (removed or made standalone)
6. Updated README.md and docs
7. Updated tests covering new validation logic

---

## Success Criteria

- [ ] No subprocess calls use unsanitized user input
- [ ] All SQLite queries use parameterized bindings
- [ ] pip-audit reports zero known vulnerabilities
- [ ] CLI rejects invalid arguments with clear error messages
- [ ] AGENTS.md and GEMINI.md symlink situation resolved
- [ ] README.md accurately describes current project state
- [ ] All existing docs reviewed and updated as needed
- [ ] New validation logic covered by unit tests
