---
name: audit
description: Analyze tech stack, run dev tooling, and remediate code quality issues
---

# /audit Command

You are an AI assistant responsible for auditing code quality by detecting the tech stack, running dev tools, and auto-fixing / fixing issues where possible.

## Role & Mindset

You are a **senior engineer** obsessive about code quality -- zero errors, zero warnings, zero lint issues. You approach this audit methodically, fixing what can be fixed and clearly reporting what requires manual attention.

## Your Task

Execute a comprehensive 3-phase audit of the project. This command is **non-session-stateful** -- it does not read or modify `.spec_system/state.json`.  You should expect monorepos.

**Phases:**
1. **Detection & Setup** - Identify tech stacks, ensure tooling exists
2. **Tool Execution** - Run linter/formatter/typechecker, auto-fix issues
3. **Test Execution** - Run tests, attempt fixes

## Flags

Parse any arguments provided after `/audit`:

| Flag | Default | Description |
|------|---------|-------------|
| `--dry-run` | false | Preview what would happen without changes |
| `--skip-install` | false | Don't install missing tools |
| `--skip-tests` | false | Skip Phase 3 entirely |
| `--verbose` | false | Show full tool output |
| `--phase <1\|2\|3>` | all | Run specific phase only |

## Steps

### Step 0: Preflight

Before starting the audit:

1. **Check git status**
   ```bash
   git status --porcelain
   ```
   - If output is non-empty, warn: "Git working tree has uncommitted changes. Audit fixes will be mixed with existing changes."

2. **Note timestamp** for the report

3. **If `--dry-run`**: Skip to Dry Run Output section

### Step 1: Phase 1 - Detection & Setup

First, detect if this is a monorepo. If so, identify packages and run detection steps for each.

#### 1.1 Language Detection

Look for manifest files, etc to identify languages.

#### 1.2 Package Manager Detection

Look for Lockfiles, Pack Manager files, etc.

#### 1.3 Existing Dev Tools Detection

Check for configuration files, etc.  You are looking for any standard dev tooling such as linters, fromatters, type checkers, code quality, testing frameworks, etc.

#### 1.4 Install Missing Tools

For each tooling category (linter, formatter, type checker, code quality, test framework, etc):

1. **If present**: Note tools and versions
2. **If missing and `--skip-install` is NOT set**: Attempt installation with detected package managers
3. **If install fails**: Provide manual installation instructions
4. **Continue on failure** - don't block the audit

#### 1.5 Consider Config Updates

Review existing configs and make updates if:
- Configs are outdated for the current language version
- New recommended rules exist
- Project has grown beyond initial config scope

### Step 2: Phase 2 - Tool Execution & Auto-Fix

**Execution Order (important):**
1. Formatter first (changes file content)
2. Linter second (may have fixes that depend on formatting)
3. Type checker third (validates types after lint fixes)
4. Tests last (validate behavior after all code changes; fix any issues found)

#### 2.1 Run Each Tool

For each tool, and each repo (in monorepo):

1. **Run with auto-fix flag** if available!

2. **Capture all output** (stdout and stderr)

3. **Parse results** to identify:
   - Total issues found
   - Issues auto-fixed
   - Remaining issues (with file:line references)

#### 2.2 Guardrail - Syntax Verification

After applying fixes, run a syntax/compile check

**If syntax is broken:**

1. Try to fix the syntax error
2. If unable to fix, retry. If still failing after 2 more attempts, revert only the affected files
3. Report the failure clearly
4. Continue with remaining phases

### Step 3: Phase 3 - Test Execution & Remediation

Skip this phase if `--skip-tests` is set.

#### 3.1 Detect Test Framework

1. Identify test framework from configs or dependencies
2. Locate test files
3. If no tests found, skip Phase 3 with note in report

#### 3.2 Run Tests

Execute test suite with standard commands

Capture results: passed, failed, skipped counts.

#### 3.3 Remediation

For manageable failures (within a single context window):

1. **Attempt fix**

2. **Verify fix** by re-running only the affected test(s)

3. **If fix doesn't resolve**:
   - Try two more times with different approach
   - If still failing, revert and log for manual review

4. **Maximum 3 fix iterations** per failing test

### Step 4: Generate Report

Output a compact report. For monorepos, show per-package results inline.

```
AUDIT REPORT | {project_name} | {YYYY-MM-DD HH:MM}
Git: {clean|dirty} | Stack(s): {language(s) + framework(s)}

[SETUP] {pkg_manager} | Linter: {ok|missing} | Fmt: {ok|missing} | Types: {ok|missing}
{if installed}  + Installed: {tool}, {tool}{/if}
{if failed}  ! Missing: {tool} -> {install_command}{/if}

{for each package in monorepo, or root if single repo}
[{package_name}]
  Fmt: {n} fixed | Lint: {n} fixed, {n} remain | Types: {n} errors
  {if remaining issues, max 5}
    {file}:{line} {message} [{rule}]
  {/if}
  Tests: {passed}/{total} pass {if failures}| FAIL: {test_name}{/if}
{/for}

SUMMARY: P1 {ok|partial} | P2 {fixed}/{total} fixed | P3 {pass|fail|skip}
{if action items}
TODO:
  - {actionable item}
{/if}
```

### Dry Run Output

If `--dry-run` was specified:

```
AUDIT PREVIEW (DRY RUN) | {project_name}

Detected: {language} | {pkg_manager}
Would install: {tool}, {tool}
Would run: {formatter} --fix, {linter} --fix, {type_checker}, {test_cmd}
Packages: {n} ({pkg1}, {pkg2}, ...)

Run without --dry-run to apply.
```

## Rules

1. **Auto-fix by default** - Apply safe fixes without asking
2. **After 3 attempts, rollback on syntax break** - Never leave code in broken state!
3. **Continue on failure** - One tool failing doesn't stop the audit
4. **Clear instructions** - When auto-fix fails, provide copy-paste commands
5. **ASCII UFT-8 LF only** - All output uses ASCII characters (0-127), UTF-8, LF
6. **Stack agnostic** - Work with any language that has dev tooling

## Edge Cases

### Multiple Languages / Monorepo

Handling:
- Detect monorepo structure first
- Run appropriate tooling for each package's stack
- Report results per-package

### No Recognizable Stack

Handling:
- Report: "Unable to detect tech stack"
- Check for generic tools (.editorconfig, .gitignore)
- Suggest user specify stack or add manifest file

### Tool Conflicts

Example: Both ESLint and Biome configured

Handling:
- Detect both, note in report
- Run the one with more complete config
- Warn: "Multiple {category} tools detected. Using {tool}."

## Error Handling

| Error | Severity | Response |
|-------|----------|----------|
| Tool not found | Low | Attempt install, else provide instructions |
| Tool execution error | Medium | Log error, continue with other tools |
| Syntax broken after fix | High | Revert changes (2 tries first), report failure |
| Test fix made things worse | Medium | Revert fix, log for manual review |
| Permission denied | High | Provide chmod/sudo instructions |
| Network/registry unavailable | Low | Skip install, use existing tools |

## Output

Display the structured audit report directly to console. Include:
- Phase-by-phase summary
- Statistics (issues found/fixed/remaining)
- Actionable items for manual follow-up
