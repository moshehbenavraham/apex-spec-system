# Build System

The build system generates tool-specific output from the canonical command and skill sources.

## Usage

```bash
make build    # Generate all outputs in dist/
make clean    # Remove dist/
```

Or directly:

```bash
bash build/generate.sh
```

## Output Structure

```
dist/
  codex/        # Codex CLI artifacts (AGENTS.md)
  cursor/       # Cursor rules
  gemini/       # Gemini CLI artifacts
  mcp/          # MCP server definitions
  universal/    # Shared assets (scripts/, AGENTS.md)
```

## How It Works

1. Parses YAML frontmatter from `commands/*.md` and `skills/*/SKILL.md`
2. Collects command names and descriptions into a table
3. Reads `build/templates/AGENTS.md.tmpl` and substitutes placeholders
4. Writes generated files to `dist/` subdirectories
5. Copies shared scripts to `dist/universal/scripts/`

## Templates

Templates live in `build/templates/` and use `{{PLACEHOLDER}}` syntax:
- `{{VERSION}}` -- Replaced with version from `skills/spec-workflow/SKILL.md`
- `{{COMMAND_TABLE}}` -- Replaced with auto-generated command reference table
