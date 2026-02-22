# Contributing to Apex Spec System

## Adding Support for a New Tool

The system generates tool-specific configurations from 14 canonical command files. To add a new tool:

### 1. Add a Generator Function

Edit `build/generate.sh` and add a function named `generate_<toolname>()`:

```bash
generate_newtool() {
    local out_dir="$DIST_DIR/newtool"
    mkdir -p "$out_dir"

    # Generate tool-specific files from canonical commands
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        local name desc body
        name="$(parse_frontmatter "$cmd_file" "name")"
        desc="$(parse_frontmatter "$cmd_file" "description")"
        body="$(parse_body "$cmd_file")"

        # Write in whatever format the tool expects
        # ...
    done

    # Copy AGENTS.md if the tool reads it natively
    cp "$ROOT_DIR/AGENTS.md" "$out_dir/AGENTS.md"
}
```

Call your function from `main()` at the bottom of the script.

### 2. Available Helpers

The build script provides these pure-bash helpers:

| Function | Purpose |
|----------|---------|
| `parse_frontmatter FILE FIELD` | Extract a YAML frontmatter field value |
| `parse_body FILE` | Extract markdown body (everything after second `---`) |
| `collect_commands` | Generate a markdown table of all 14 commands |

### 3. Add Installer Detection

Edit `install.sh` and add:

1. A `detect_newtool()` function that returns 0 if the tool is present
2. An `install_newtool()` function that copies files to the right locations
3. An `uninstall_newtool()` function for cleanup
4. Add the tool name to the `--tool` flag help text

### 4. Add Validation Tests

Edit `test/validate-install.sh` and add a `test_newtool()` function that checks:

- Expected files exist in `dist/newtool/`
- File formats are valid (JSON, TOML, YAML, plain markdown as appropriate)
- Content is ASCII-only (no Unicode)
- AGENTS.md is present if the tool reads it

### 5. Update Documentation

- Add the tool to the table in `README.md`
- Add a column in `docs/COMPATIBILITY-MATRIX.md`
- Create a setup guide in `docs/newtool.md` if the tool needs detailed instructions

### 6. Canonical Command Format

Commands live in `commands/*.md` using YAML frontmatter + markdown body:

```markdown
---
name: commandname
description: One-line description
---

# /commandname

Full command instructions in markdown...
```

See [docs/CANONICAL-FORMAT.md](docs/CANONICAL-FORMAT.md) for the complete specification.

## Constraints

- **Pure bash**: `build/generate.sh` must not require Node.js, Python, or other runtimes
- **ASCII only**: All generated files must use characters 0-127 only
- **AGENTS.md < 32KB**: The generated AGENTS.md must stay under the Codex CLI size limit
- **Windsurf < 12K chars**: Windsurf rule files must stay under 12,000 characters each

## Running Tests

```bash
make validate    # Build + run all 125+ validation checks
```

## Project Layout

```
commands/           # Canonical source (do not modify format without updating generators)
build/generate.sh   # All generator functions
install.sh          # Universal installer
test/validate-install.sh  # Validation suite
docs/               # Per-tool setup guides and reference docs
```
