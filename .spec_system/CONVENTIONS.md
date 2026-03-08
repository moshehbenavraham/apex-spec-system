# CONVENTIONS.md

## Guiding Principles

- Optimize for readability over cleverness
- Code is written once, read many times
- Consistency beats personal preference
- If it can be automated, automate it
- When writing code: Make NO assumptions. Do not be lazy. Pattern match precisely. Do not skim when you need detailed info from documents. Validate systematically.

## Naming

### Bash
- Functions: `snake_case` (e.g., `detect_monorepo`, `get_project_state`)
- Variables: `UPPER_SNAKE_CASE` for constants, `lower_snake_case` for locals
- Script files: `kebab-case.sh` (e.g., `analyze-project.sh`, `check-prereqs.sh`)

### Python
- Functions and variables: `snake_case` (e.g., `llm_manager_decide`, `build_claude_prompt`)
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE` (e.g., `COMMAND_TIMEOUT`, `MAX_HISTORY`)
- Module files: `snake_case.py`

### Markdown
- Command files: `kebab-case.md` (e.g., `plansession.md`, `sculpt-ui.md`)
- Spec directories: `phaseNN-sessionNN-name` format

### General
- Be descriptive over concise
- Booleans read as questions: `is_active`, `has_permission`
- Avoid abbreviations unless universally understood (`id`, `url`, `config`)
- Match domain language--use the same terms as product/design/stakeholders

## Files & Structure

```
apex-spec-system/
  .claude-plugin/      # Plugin manifests (plugin.json, marketplace.json)
  apex-infinite-cli/   # Python autonomous CLI
  commands/            # Markdown command specifications (13 core + 9 utility)
  scripts/             # Bash utilities (analyze, prereqs, common)
  skills/              # Skill definitions (spec-workflow)
  docs/                # User documentation
  .spec_system/        # Internal spec system (dogfooding)
```

- One concept per file where practical
- File names reflect their primary export or purpose
- Keep nesting shallow--if you're 4+ levels deep, reconsider

## Bash Conventions

- Use `set -euo pipefail` at the top of every script
- Quote all variable expansions: `"${var}"` not `$var`
- Use `local` for function-scoped variables
- Prefer `[[ ]]` over `[ ]` for conditionals
- Use `printf` over `echo` for portability
- JSON output via `jq` or careful `printf` with proper escaping
- Exit codes: 0 = success, 1 = general error, 2 = usage error
- `# TODO(name): reason` format for todos

## Python Conventions

- Target Python 3.10+
- Use type hints on all function signatures
- Use Click for CLI argument parsing
- Use Rich for terminal output formatting
- Prefer f-strings over `.format()` or `%`
- Use `with` statements for file and connection handling
- Parameterized queries only for SQLite--no string concatenation
- Constants at module level, not buried in functions

## Markdown Conventions

- Command specs use YAML-style frontmatter (---name/description---)
- Use ATX-style headers (`#` not underlines)
- One sentence per line in prose sections (easier diffs)
- Tables must be ASCII-aligned
- Code blocks specify language (```bash, ```python, ```json)
- All content ASCII-only (0-127), no Unicode, no emoji, no smart quotes
- Unix LF line endings only

## Error Handling

- Bash: trap errors, log to stderr, exit with meaningful code
- Python: catch specific exceptions, log context, re-raise when appropriate
- Errors should be actionable--include what failed and what to try
- Never swallow errors silently

## Testing

- Python: pytest with coverage reporting
- Bash: contract tests validating JSON output schemas
- Test behavior, not implementation
- Test names describe the scenario and expectation
- Flaky tests get fixed or deleted--never ignored

## Git & Version Control

- Commit messages: imperative mood, concise (`Add user validation` not `Added some validation stuff`)
- One logical change per commit
- Branch names: `type/short-description` (e.g., `feat/user-auth`, `fix/cart-total`)
- Keep commits atomic enough to revert safely
- Version must be updated in ALL 4 files: README.md, plugin.json, marketplace.json, SKILL.md

## Pull Requests

- Small PRs get better reviews
- Description explains the *what* and *why*--reviewers can see the *how*
- CI must pass before merge

## Dependencies

- Fewer dependencies = less risk
- Pin versions in requirements.txt
- Run pip-audit before adding new packages
- Justify additions; prefer well-maintained, focused libraries

## ASCII Encoding (Non-Negotiable)

- All output files: ASCII-only (0-127)
- No Unicode, no emoji, no smart quotes, no em-dashes
- Straight quotes only (" ')
- Hyphens (-) not em-dashes
- Validate: `LC_ALL=C grep -P '[^\x00-\x7F]' filename` should return nothing
- Validate: `file filename` should show "ASCII text"

## Local Dev Tools

| Category | Tool | Config |
|----------|------|--------|
| Formatter (Python) | black | pyproject.toml |
| Linter (Python) | pylint | pyproject.toml |
| Linter (Bash) | shellcheck | .shellcheckrc |
| Linter (Markdown) | markdownlint | .markdownlint.yaml |
| Type Safety (Python) | mypy | pyproject.toml |
| Testing (Python) | pytest | pyproject.toml |
| Security (Python) | pip-audit | CI |
| Git Hooks | not configured | - |

## When In Doubt

- Ask
- Leave it better than you found it
- Ship, learn, iterate
