---
name: audit
description: Analyze tech stack, run dev tooling, and remediate code quality issues
---

# /audit Command

Add and validate local dev tooling one bundle at a time. Follows the universal 9-step flow shared with /pipeline and /infra.

## Master List (5 Bundles)

Industry standard order (fast to slow, format before validate):

| Priority | Bundle | Contents |
|----------|--------|----------|
| 1 | **Formatting** | Formatter (Prettier, Biome, Black, Ruff format) |
| 2 | **Linting** | Linter (ESLint, Biome, Ruff, Clippy) |
| 3 | **Type Safety** | Type checker (TypeScript, mypy, Pyright) |
| 4 | **Testing** | Test runner + coverage (Jest, Vitest, pytest, pytest-cov) |
| 5 | **Git Hooks** | Pre-commit hooks (husky, pre-commit, lefthook) |

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--dry-run` | false | Preview what would happen without changes |
| `--skip-install` | false | Don't install missing tools |
| `--verbose` | false | Show full tool output |

## Flow

### Step 1: DETECT

1. Check for `.spec_system/CONVENTIONS.md`
   - If missing: "No CONVENTIONS.md found. Run /initspec first or create manually."
   - Read Repository section for monorepo detection
   - Read Stack section for languages/runtimes
   - Read Local Dev Tools table for configured tools

2. Check for `.spec_system/audit/known-issues.md`
   - If found, load ignore patterns
   - Note: "Known issues loaded (N paths, N rules, N tests)"

3. Check git status
   - If dirty: Warn "Uncommitted changes exist. Fixes will mix with existing changes."

4. If `--dry-run`: Skip to Dry Run Output

### Step 2: COMPARE

Compare Local Dev Tools table against 5-bundle master list:
- For each bundle, check if Tool column has a value or shows "not configured" / "-"
- Build list of missing bundles in priority order

If all bundles configured: "All recommended local dev tools configured. Jumping to Step 5."

### Step 3: SELECT

Pick the highest-priority missing bundle from Step 2.

Output: "Selected: [Bundle Name] - not yet configured"

### Step 4: IMPLEMENT

Install and configure the selected bundle.

**Detection by language** (from CONVENTIONS.md Stack section):

| Language | Formatter | Linter | Type Checker | Test Framework | Git Hooks |
|----------|-----------|--------|--------------|----------------|-----------|
| Python | Ruff | Ruff | mypy | pytest + pytest-cov | pre-commit |
| TypeScript | Biome | Biome | tsc (strict) | Vitest | husky + lint-staged |
| JavaScript | Biome | Biome | - | Vitest | husky + lint-staged |
| Rust | rustfmt | Clippy | (built-in) | cargo test | pre-commit |
| Go | gofmt | golangci-lint | (built-in) | go test | pre-commit |

**For monorepos**: Install at root if shared, or per-package if stack differs.

1. Install tool via detected package manager
2. Generate config file with sensible defaults
3. If install fails and not `--skip-install`: Provide manual instructions, continue

### Step 5: VALIDATE

Run ALL configured tools (not just the new one):

1. **Formatter** (if configured): Run with auto-fix flag
2. **Linter** (if configured): Run with auto-fix flag
3. **Type checker** (if configured): Run in check mode
4. **Tests** (if configured): Run full suite
5. **Git hooks** (if configured): Verify hooks are installed

**For monorepos**: Run per package, collect results.

Capture all output. Parse for errors, warnings, fixes applied.

### Step 6: FIX

For each issue found in Step 5:

1. **Auto-fixable** (format, some lint): Already fixed in Step 5
2. **Type errors**: Attempt fix, verify syntax still valid
3. **Test failures**: Attempt fix, re-run affected test
4. **Unfixable after 3 attempts**: Log for manual review, revert if syntax broken

**Guardrail**: After any fix, verify syntax/compilation. If broken after 2 retries, revert.

Filter out issues matching known-issues.md patterns - report separately as "Known".

### Step 7: RECORD

If a new bundle was added, update `.spec_system/CONVENTIONS.md`:

Update the Local Dev Tools table:
```markdown
| Category | Tool | Config |
|----------|------|--------|
| Formatter | Ruff | ruff.toml |  <-- was "not configured"
```

### Step 8: REPORT

**For monorepos**, show per-package:
```
[apps/web] Formatter: 12 fixed | Linter: 3 remain
[apps/api] Formatter: 8 fixed | Types: 2 errors
```

**For single repos**:
```
REPORT
- Added: Formatting (Ruff)
- Config: ruff.toml created
- Fixed: 47 format issues, 12 lint errors
- Remaining: 3 type errors in src/api/handlers.ts:45, :67, :89
- Known: 5 issues in src/legacy/** (ignored per known-issues.md)
```

### Step 9: RECOMMEND

**If issues remain:**
```
ACTION REQUIRED:
1. Fix type errors in src/api/handlers.ts

Rerun /audit after addressing these issues.
```

**If new bundle added configured and passing:**
```
New dev tool bundle configured and all tools passing.

Recommendation: Run /pipeline
```

**If all 5 bundles configured and passing:**
```
All local dev tools configured and all tools passing.

Recommendation: Run /pipeline
```

## Dry Run Output

```
AUDIT PREVIEW (DRY RUN)

Repository: monorepo (Turborepo)
Packages: apps/web, apps/api, packages/shared
Stack: Python 3.12, Node 20
Package managers: uv, pnpm

Configured: Formatting, Linting
Missing: Type Safety, Testing, Git Hooks

Would add: Type Safety
Would install: mypy (apps/api), typescript strict (apps/web, packages/shared)
Would run: ruff format, ruff check, biome format, biome lint, mypy, tsc

Run without --dry-run to apply.
```

## Rules

1. **One bundle per run** - Add one, validate all, fix all
2. **Never break syntax** - Revert after 2 failed attempts
3. **Respect known-issues.md** - Don't fix intentional exceptions
4. **Update CONVENTIONS.md** - Record what was added
5. **Continue on failure** - One tool failing doesn't stop the audit
6. **Monorepo aware** - Run per package, report per package
