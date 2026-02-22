# Canonical Format

All commands and skills in the Apex Spec System follow a canonical format: YAML frontmatter + markdown body.

## Command Format (`commands/*.md`)

### YAML Frontmatter

```yaml
---
name: command-name
description: One-line description of what the command does
---
```

**Required fields:**
- `name` -- Command identifier (lowercase, hyphenated)
- `description` -- Short description used in help text and AGENTS.md tables

**Reserved fields (future use):**
- `globs` -- File patterns the command operates on
- `toml_prompt_override` -- Override default prompt behavior

### Markdown Body

The body begins with a level-1 heading matching the command name:

```markdown
# /command-name Command

Command documentation, rules, workflow steps, and templates.
```

## Skill Format (`skills/*/SKILL.md`)

### YAML Frontmatter

```yaml
---
name: Skill Display Name
description: When and how the skill activates
version: 0.0.0
---
```

**Required fields:**
- `name` -- Human-readable skill name
- `description` -- Activation conditions and purpose
- `version` -- Semver version string

### Markdown Body

Free-form documentation for the skill's behavior, rules, and context.

## Conventions

- All files must be ASCII-only (bytes 0-127)
- Unix LF line endings only
- No Unicode, emoji, or smart quotes
- Frontmatter delimiters are exactly `---` on their own line
