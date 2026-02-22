#!/usr/bin/env bash
# build/generate.sh -- Generate tool-specific outputs from canonical sources
# Pure bash, no external dependencies (no Node/Python/yq)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
COMMANDS_DIR="$ROOT_DIR/commands"
SKILLS_DIR="$ROOT_DIR/skills"
SCRIPTS_DIR="$ROOT_DIR/scripts"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# --- Frontmatter parsing (pure bash/sed/awk) ---

# Extract a single YAML frontmatter field value from a file
# Usage: parse_frontmatter FILE FIELD
parse_frontmatter() {
    local file="$1" field="$2"
    sed -n '/^---$/,/^---$/p' "$file" | sed -n "s/^${field}:[[:space:]]*//p" | head -1 || true
}

# Extract the markdown body (everything after the second ---)
# Usage: parse_body FILE
parse_body() {
    local file="$1"
    awk 'BEGIN{c=0} /^---$/{c++; next} c>=2{print}' "$file"
}

# --- Command collection ---

# Collect all commands into a table: "| `/name` | description |"
collect_commands() {
    local cmd_file name desc
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        [ -f "$cmd_file" ] || continue
        name="$(parse_frontmatter "$cmd_file" "name")"
        desc="$(parse_frontmatter "$cmd_file" "description")"
        if [ -n "$name" ] && [ -n "$desc" ]; then
            echo "| \`/$name\` | $desc |"
        fi
    done
}

# --- AGENTS.md generation ---

generate_agents_md() {
    local template="$TEMPLATES_DIR/AGENTS.md.tmpl"
    if [ ! -f "$template" ]; then
        echo "WARNING: Template not found: $template" >&2
        return 1
    fi

    # Extract version from skill
    local version
    version="$(parse_frontmatter "$SKILLS_DIR/spec-workflow/SKILL.md" "version")"
    if [ -z "$version" ]; then
        version="unknown"
    fi

    # Build command table
    local command_table
    command_table="$(collect_commands)"

    # Read template and substitute placeholders
    local content
    content="$(cat "$template")"
    content="${content//\{\{VERSION\}\}/$version}"

    # For multi-line substitution, use a temp file approach
    local tmpfile
    tmpfile="$(mktemp)"
    echo "$content" > "$tmpfile"

    # Replace {{COMMAND_TABLE}} with actual table content
    local table_tmpfile
    table_tmpfile="$(mktemp)"
    while IFS= read -r line; do
        if [[ "$line" == *'{{COMMAND_TABLE}}'* ]]; then
            echo "$command_table"
        else
            echo "$line"
        fi
    done < "$tmpfile" > "$table_tmpfile"

    local output="$1"
    cp "$table_tmpfile" "$output"
    rm -f "$tmpfile" "$table_tmpfile"

    # Validate size
    local size
    size="$(wc -c < "$output")"
    if [ "$size" -gt 32768 ]; then
        echo "WARNING: AGENTS.md is ${size} bytes (exceeds 32KB limit)" >&2
    else
        echo "AGENTS.md: ${size} bytes (under 32KB limit)"
    fi
}

# --- Codex CLI skill generation ---

generate_codex_skills() {
    local codex_dir="$DIST_DIR/codex"
    local skills_dir="$codex_dir/.agents/skills"
    local cmd_file name desc body version

    version="$(parse_frontmatter "$SKILLS_DIR/spec-workflow/SKILL.md" "version")"
    [ -z "$version" ] && version="unknown"

    local count=0
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        [ -f "$cmd_file" ] || continue
        name="$(parse_frontmatter "$cmd_file" "name")"
        desc="$(parse_frontmatter "$cmd_file" "description")"
        [ -z "$name" ] && continue

        local skill_dir="$skills_dir/$name"
        mkdir -p "$skill_dir"

        # Generate SKILL.md -- reuse frontmatter fields, copy body as-is
        {
            echo "---"
            echo "name: $name"
            echo "description: $desc"
            echo "---"
            echo ""
            parse_body "$cmd_file"
        } > "$skill_dir/SKILL.md"

        # Generate openai.yaml metadata
        {
            echo "interface:"
            echo "  display_name: \"/$name\""
            echo "  short_description: \"$desc\""
            echo "policy:"
            echo "  allow_implicit_invocation: false"
        } > "$skill_dir/openai.yaml"

        count=$((count + 1))
    done

    # Symlink scripts into each skill that references them
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        [ -f "$cmd_file" ] || continue
        name="$(parse_frontmatter "$cmd_file" "name")"
        [ -z "$name" ] && continue
        local skill_dir="$skills_dir/$name"
        # Copy scripts to skill dir (portable, no symlinks)
        if [ -d "$SCRIPTS_DIR" ]; then
            cp -r "$SCRIPTS_DIR" "$skill_dir/scripts"
        fi
    done

    echo "Codex: Generated $count skills in dist/codex/.agents/skills/"
}

# --- Cursor commands + rules generation ---

generate_cursor() {
    local cursor_dir="$DIST_DIR/cursor"
    local commands_out="$cursor_dir/.cursor/commands"
    local rules_out="$cursor_dir/.cursor/rules"
    local cmd_file name desc body

    mkdir -p "$commands_out"
    mkdir -p "$rules_out"

    # Generate commands (one per canonical command)
    local count=0
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        [ -f "$cmd_file" ] || continue
        name="$(parse_frontmatter "$cmd_file" "name")"
        [ -z "$name" ] && continue

        # Strip YAML frontmatter, output plain markdown
        body="$(parse_body "$cmd_file")"

        # Skip leading blank lines to find actual first line
        local first_line
        first_line="$(echo "$body" | sed '/^$/d' | head -1 || true)"

        # If body already starts with a heading containing the command name, use as-is
        if [[ "$first_line" == "# /"* ]]; then
            echo "$body" > "$commands_out/$name.md"
        else
            {
                echo "# /$name"
                echo ""
                echo "$body"
            } > "$commands_out/$name.md"
        fi

        count=$((count + 1))
    done

    echo "Cursor: Generated $count commands in dist/cursor/.cursor/commands/"

    # Generate rule from skill content (MDC frontmatter format)
    local skill_file="$SKILLS_DIR/spec-workflow/SKILL.md"
    if [ -f "$skill_file" ]; then
        local skill_body
        skill_body="$(parse_body "$skill_file")"

        # Use a static description to avoid YAML quoting issues
        {
            echo "---"
            echo "description: Apex Spec Workflow - specification-driven AI development system"
            echo "alwaysApply: true"
            echo "---"
            echo ""
            echo "$skill_body"
        } > "$rules_out/apex-spec.md"

        echo "Cursor: Generated rule in dist/cursor/.cursor/rules/apex-spec.md"
    fi

    # Copy AGENTS.md (Cursor reads it natively from project root)
    cp "$DIST_DIR/universal/AGENTS.md" "$cursor_dir/AGENTS.md"
    echo "Cursor: Copied AGENTS.md to dist/cursor/"
}

# --- Gemini CLI command + skill generation ---

generate_gemini() {
    local gemini_dir="$DIST_DIR/gemini"
    local commands_out="$gemini_dir/.gemini/commands"
    local skills_out="$gemini_dir/.gemini/skills/spec-workflow"
    local cmd_file name desc body

    mkdir -p "$commands_out"
    mkdir -p "$skills_out"

    # Generate TOML commands (one per canonical command)
    local count=0
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        [ -f "$cmd_file" ] || continue
        name="$(parse_frontmatter "$cmd_file" "name")"
        desc="$(parse_frontmatter "$cmd_file" "description")"
        [ -z "$name" ] && continue

        body="$(parse_body "$cmd_file")"

        # Write TOML file with multiline prompt string
        {
            printf 'description = "%s"\n' "$desc"
            printf 'prompt = """\n'
            printf '%s\n' "$body"
            printf '"""\n'
        } > "$commands_out/$name.toml"

        count=$((count + 1))
    done

    echo "Gemini: Generated $count commands in dist/gemini/.gemini/commands/"

    # Generate skill with allowed-tools field
    local skill_file="$SKILLS_DIR/spec-workflow/SKILL.md"
    if [ -f "$skill_file" ]; then
        local skill_name skill_desc skill_version skill_body
        skill_name="$(parse_frontmatter "$skill_file" "name")"
        skill_desc="$(parse_frontmatter "$skill_file" "description")"
        skill_version="$(parse_frontmatter "$skill_file" "version")"
        skill_body="$(parse_body "$skill_file")"

        {
            echo "---"
            echo "name: $skill_name"
            echo "description: Specification-driven AI development system guidance"
            echo "version: $skill_version"
            echo "allowed-tools:"
            echo "  - Bash"
            echo "  - ReadFile"
            echo "  - WriteFile"
            echo "  - ReadManyFiles"
            echo "  - ListDir"
            echo "---"
            echo ""
            printf '%s\n' "$skill_body"
        } > "$skills_out/SKILL.md"

        echo "Gemini: Generated skill in dist/gemini/.gemini/skills/spec-workflow/SKILL.md"
    fi

    # Copy reference files for skill
    local refs_src="$SKILLS_DIR/spec-workflow/references"
    if [ -d "$refs_src" ]; then
        cp -r "$refs_src" "$skills_out/references"
        echo "Gemini: Copied skill references to dist/gemini/.gemini/skills/spec-workflow/references/"
    fi
}

# --- Gemini extension manifest + context file ---

generate_gemini_extension() {
    local gemini_dir="$DIST_DIR/gemini"
    local version
    version="$(parse_frontmatter "$SKILLS_DIR/spec-workflow/SKILL.md" "version")"
    [ -z "$version" ] && version="unknown"

    # Generate gemini-extension.json
    cat > "$gemini_dir/gemini-extension.json" <<EXTEOF
{
  "name": "apex-spec",
  "version": "$version",
  "description": "Specification-driven workflow system for AI-assisted development",
  "contextFileName": "GEMINI.md",
  "settings": []
}
EXTEOF

    echo "Gemini: Generated gemini-extension.json"

    # Generate GEMINI.md from skill content + command reference
    local skill_body
    skill_body="$(parse_body "$SKILLS_DIR/spec-workflow/SKILL.md")"

    local command_table
    command_table="$(collect_commands)"

    {
        echo "# Apex Spec System v${version}"
        echo ""
        echo "Specification-driven workflow system for AI-assisted development."
        echo ""
        printf '%s\n' "$skill_body"
        echo ""
        echo "## Available Commands"
        echo ""
        echo "| Command | Description |"
        echo "|---------|-------------|"
        echo "$command_table"
    } > "$gemini_dir/GEMINI.md"

    echo "Gemini: Generated GEMINI.md context file"

    # Copy AGENTS.md (Gemini reads it natively from project root)
    cp "$DIST_DIR/universal/AGENTS.md" "$gemini_dir/AGENTS.md"
    echo "Gemini: Copied AGENTS.md to dist/gemini/"
}

# --- MCP config snippet generation ---

generate_mcp_configs() {
    local mcp_dir="$DIST_DIR/mcp"
    mkdir -p "$mcp_dir"

    local version
    version="$(parse_frontmatter "$SKILLS_DIR/spec-workflow/SKILL.md" "version")"
    [ -z "$version" ] && version="unknown"

    # Cursor MCP config (.cursor/mcp.json format)
    cat > "$mcp_dir/cursor.json" <<'MCPEOF'
{
  "mcpServers": {
    "apex-spec": {
      "command": "node",
      "args": ["./mcp-server/dist/index.js"],
      "env": {}
    }
  }
}
MCPEOF

    # VS Code MCP config (.vscode/mcp.json format)
    cat > "$mcp_dir/vscode.json" <<'MCPEOF'
{
  "servers": {
    "apex-spec": {
      "type": "stdio",
      "command": "node",
      "args": ["./mcp-server/dist/index.js"]
    }
  }
}
MCPEOF

    # Cline MCP config (cline_mcp_settings.json fragment)
    cat > "$mcp_dir/cline.json" <<'MCPEOF'
{
  "mcpServers": {
    "apex-spec": {
      "command": "node",
      "args": ["./mcp-server/dist/index.js"],
      "disabled": false
    }
  }
}
MCPEOF

    # Windsurf MCP config (mcp_config.json fragment)
    cat > "$mcp_dir/windsurf.json" <<'MCPEOF'
{
  "mcpServers": {
    "apex-spec": {
      "command": "node",
      "args": ["./mcp-server/dist/index.js"]
    }
  }
}
MCPEOF

    # Codex MCP config (.codex/config.toml fragment)
    cat > "$mcp_dir/codex.toml" <<'MCPEOF'
[mcp_servers.apex-spec]
command = "node"
args = ["./mcp-server/dist/index.js"]
MCPEOF

    # Gemini MCP config (settings.json fragment)
    cat > "$mcp_dir/gemini.json" <<'MCPEOF'
{
  "mcpServers": {
    "apex-spec": {
      "command": "node",
      "args": ["./mcp-server/dist/index.js"]
    }
  }
}
MCPEOF

    echo "MCP: Generated 6 config snippets in dist/mcp/"
}

# --- Cline rules generation ---

generate_cline() {
    local cline_dir="$DIST_DIR/cline"
    local rules_dir="$cline_dir/.clinerules"
    mkdir -p "$rules_dir"

    # Generate main rule file from skill content
    local skill_file="$SKILLS_DIR/spec-workflow/SKILL.md"
    if [ -f "$skill_file" ]; then
        local skill_body
        skill_body="$(parse_body "$skill_file")"

        local command_table
        command_table="$(collect_commands)"

        {
            echo "---"
            echo "description: Apex Spec Workflow - specification-driven AI development system"
            echo "paths:"
            echo "  - \"**/*\""
            echo "---"
            echo ""
            printf '%s\n' "$skill_body"
            echo ""
            echo "## Available Commands"
            echo ""
            echo "| Command | Description |"
            echo "|---------|-------------|"
            echo "$command_table"
        } > "$rules_dir/apex-spec.md"

        echo "Cline: Generated rule in dist/cline/.clinerules/apex-spec.md"
    fi

    # Copy AGENTS.md (Cline auto-detects it from project root)
    cp "$DIST_DIR/universal/AGENTS.md" "$cline_dir/AGENTS.md"
    echo "Cline: Copied AGENTS.md to dist/cline/"
}

# --- Windsurf rules generation (3 files to stay under 12K char limit) ---

generate_windsurf() {
    local windsurf_dir="$DIST_DIR/windsurf"
    local rules_dir="$windsurf_dir/.windsurf/rules"
    mkdir -p "$rules_dir"

    # Stage groupings
    local plan_cmds="initspec createprd phasebuild"
    local build_cmds="nextsession sessionspec tasks implement validate updateprd"
    local harden_cmds="audit pipeline infra documents carryforward"

    # Helper: generate a condensed stage rule file (under 12K chars)
    # Includes command name + description + first section only
    # Usage: _windsurf_stage_file OUTPUT_PATH STAGE_NAME STAGE_DESC CMD_LIST...
    _windsurf_stage_file() {
        local output="$1" stage_name="$2" stage_desc="$3"
        shift 3
        local cmds="$*"

        {
            echo "---"
            echo "trigger: always_on"
            echo "---"
            echo ""
            echo "# Apex Spec System - ${stage_name} Stage"
            echo ""
            echo "${stage_desc}"
            echo ""
            echo "Refer to AGENTS.md for full system overview. Each command below summarizes its purpose and key steps."
            echo ""

            local cmd_name cmd_file desc body summary
            for cmd_name in $cmds; do
                cmd_file="$COMMANDS_DIR/${cmd_name}.md"
                [ -f "$cmd_file" ] || continue
                desc="$(parse_frontmatter "$cmd_file" "description")"

                # Extract only the first section (up to second ## heading)
                body="$(parse_body "$cmd_file")"
                summary="$(printf '%s\n' "$body" | awk '/^## /{if(seen++)exit}1')"

                echo "## /${cmd_name}"
                echo ""
                [ -n "$desc" ] && echo "**${desc}**" && echo ""
                printf '%s\n' "$summary"
                echo ""
            done
        } > "$output"
    }

    _windsurf_stage_file "$rules_dir/apex-spec-plan.md" \
        "PLAN" \
        "Initialization and planning commands for starting a spec-driven project." \
        $plan_cmds

    _windsurf_stage_file "$rules_dir/apex-spec-build.md" \
        "BUILD" \
        "Session workflow commands for iterative development cycles." \
        $build_cmds

    _windsurf_stage_file "$rules_dir/apex-spec-harden.md" \
        "HARDEN" \
        "Hardening commands for quality, infrastructure, and documentation." \
        $harden_cmds

    # Validate each file is under 12K chars
    local f size
    for f in "$rules_dir"/apex-spec-*.md; do
        size=$(wc -c < "$f")
        if [ "$size" -gt 12000 ]; then
            echo "WARNING: $(basename "$f") is ${size} bytes (exceeds 12K limit)" >&2
        fi
    done

    echo "Windsurf: Generated 3 rule files in dist/windsurf/.windsurf/rules/"

    # Copy AGENTS.md
    cp "$DIST_DIR/universal/AGENTS.md" "$windsurf_dir/AGENTS.md"
    echo "Windsurf: Copied AGENTS.md to dist/windsurf/"
}

# --- Antigravity skill generation ---

generate_antigravity() {
    local ag_dir="$DIST_DIR/antigravity"
    local skills_dir="$ag_dir/.agent/skills/spec-workflow"
    mkdir -p "$skills_dir"

    # Generate SKILL.md from canonical skill (Antigravity format is nearly identical to Gemini)
    local skill_file="$SKILLS_DIR/spec-workflow/SKILL.md"
    if [ -f "$skill_file" ]; then
        local skill_name skill_desc skill_version skill_body
        skill_name="$(parse_frontmatter "$skill_file" "name")"
        skill_desc="$(parse_frontmatter "$skill_file" "description")"
        skill_version="$(parse_frontmatter "$skill_file" "version")"
        skill_body="$(parse_body "$skill_file")"

        {
            echo "---"
            echo "name: $skill_name"
            echo "description: Specification-driven AI development system guidance"
            echo "version: $skill_version"
            echo "---"
            echo ""
            printf '%s\n' "$skill_body"
        } > "$skills_dir/SKILL.md"

        echo "Antigravity: Generated skill in dist/antigravity/.agent/skills/spec-workflow/SKILL.md"
    fi

    # Copy reference files
    local refs_src="$SKILLS_DIR/spec-workflow/references"
    if [ -d "$refs_src" ]; then
        cp -r "$refs_src" "$skills_dir/references"
        echo "Antigravity: Copied skill references"
    fi

    # Reuse GEMINI.md as context file (shared path with Gemini CLI)
    if [ -f "$DIST_DIR/gemini/GEMINI.md" ]; then
        cp "$DIST_DIR/gemini/GEMINI.md" "$ag_dir/GEMINI.md"
        echo "Antigravity: Copied GEMINI.md context file"
    fi

    # Copy AGENTS.md
    cp "$DIST_DIR/universal/AGENTS.md" "$ag_dir/AGENTS.md"
    echo "Antigravity: Copied AGENTS.md to dist/antigravity/"
}

# --- GitHub Copilot generation ---

generate_copilot() {
    local copilot_dir="$DIST_DIR/copilot"
    local github_dir="$copilot_dir/.github"
    local instructions_dir="$github_dir/instructions"
    mkdir -p "$instructions_dir"

    # Generate .github/copilot-instructions.md (plain markdown, no frontmatter)
    # This is the repo-wide instructions file (~2 pages max)
    cp "$DIST_DIR/universal/AGENTS.md" "$github_dir/copilot-instructions.md"
    echo "Copilot: Generated .github/copilot-instructions.md"

    # Generate .github/instructions/apex-spec.instructions.md
    # Has YAML frontmatter with description and applyTo
    local skill_body
    skill_body="$(parse_body "$SKILLS_DIR/spec-workflow/SKILL.md")"

    local command_table
    command_table="$(collect_commands)"

    {
        echo "---"
        echo "description: 'Apex Spec Workflow - specification-driven AI development system with 14 commands for structured project delivery'"
        echo "applyTo: '**/*'"
        echo "---"
        echo ""
        printf '%s\n' "$skill_body"
        echo ""
        echo "## Available Commands"
        echo ""
        echo "| Command | Description |"
        echo "|---------|-------------|"
        echo "$command_table"
    } > "$instructions_dir/apex-spec.instructions.md"

    echo "Copilot: Generated .github/instructions/apex-spec.instructions.md"

    # Copy AGENTS.md
    cp "$DIST_DIR/universal/AGENTS.md" "$copilot_dir/AGENTS.md"
    echo "Copilot: Copied AGENTS.md to dist/copilot/"
}

# --- Amazon Q Developer generation ---

generate_amazonq() {
    local aq_dir="$DIST_DIR/amazonq"
    local rules_dir="$aq_dir/.amazonq/rules"
    mkdir -p "$rules_dir"

    # Generate .amazonq/rules/apex-spec.md (plain markdown, no frontmatter)
    local skill_body
    skill_body="$(parse_body "$SKILLS_DIR/spec-workflow/SKILL.md")"

    local command_table
    command_table="$(collect_commands)"

    {
        echo "# Apex Spec Workflow"
        echo ""
        echo "## Purpose"
        echo ""
        echo "Specification-driven AI development system that breaks large projects into"
        echo "manageable 2-4 hour sessions with 12-25 tasks each."
        echo ""
        echo "## Instructions"
        echo ""
        printf '%s\n' "$skill_body"
        echo ""
        echo "## Available Commands"
        echo ""
        echo "| Command | Description |"
        echo "|---------|-------------|"
        echo "$command_table"
        echo ""
        echo "## Priority"
        echo ""
        echo "High"
    } > "$rules_dir/apex-spec.md"

    echo "Amazon Q: Generated .amazonq/rules/apex-spec.md"

    # Copy AGENTS.md
    cp "$DIST_DIR/universal/AGENTS.md" "$aq_dir/AGENTS.md"
    echo "Amazon Q: Copied AGENTS.md to dist/amazonq/"
}

# --- Goose generation ---

generate_goose() {
    local goose_dir="$DIST_DIR/goose"
    mkdir -p "$goose_dir"

    # Generate .goosehints (plain text, no frontmatter)
    # Keep concise -- contributes to token usage on every request
    local version
    version="$(parse_frontmatter "$SKILLS_DIR/spec-workflow/SKILL.md" "version")"
    [ -z "$version" ] && version="unknown"

    local command_table
    command_table="$(collect_commands)"

    {
        echo "This project uses the Apex Spec System v${version} for specification-driven development."
        echo ""
        echo "Core principle: 1 session = 1 spec = 2-4 hours = 12-25 tasks"
        echo ""
        echo "3-Stage Workflow: PLAN -> BUILD -> HARDEN"
        echo "  PLAN: /initspec, /createprd, /phasebuild"
        echo "  BUILD: /nextsession, /sessionspec, /tasks, /implement, /validate, /updateprd"
        echo "  HARDEN: /audit, /pipeline, /infra, /documents, /carryforward"
        echo ""
        echo "Key paths:"
        echo "  .spec_system/state.json    - Project state tracking"
        echo "  .spec_system/PRD/PRD.md    - Master PRD"
        echo "  .spec_system/specs/        - Session specifications"
        echo "  scripts/                   - Bash utilities (analyze-project.sh, check-prereqs.sh)"
        echo ""
        echo "Session naming: phaseNN-sessionNN-name (e.g., phase01-session03-user-auth)"
        echo "Task format: - [ ] TNNN [SNNMM] [P] Action verb + what + where"
        echo "Max 25 tasks per session, max 4 hours, single objective."
        echo ""
        echo "All generated files must be ASCII-only (bytes 0-127). No Unicode, no emoji."
        echo ""
        echo "@AGENTS.md"
    } > "$goose_dir/.goosehints"

    echo "Goose: Generated .goosehints"

    # Copy AGENTS.md (Goose reads it natively via CONTEXT_FILE_NAMES)
    cp "$DIST_DIR/universal/AGENTS.md" "$goose_dir/AGENTS.md"
    echo "Goose: Copied AGENTS.md to dist/goose/"
}

# --- Kiro steering generation ---

generate_kiro() {
    local kiro_dir="$DIST_DIR/kiro"
    local steering_dir="$kiro_dir/.kiro/steering"
    mkdir -p "$steering_dir"

    # Generate .kiro/steering/apex-spec.md (markdown with YAML frontmatter)
    local skill_body
    skill_body="$(parse_body "$SKILLS_DIR/spec-workflow/SKILL.md")"

    local command_table
    command_table="$(collect_commands)"

    {
        echo "---"
        echo "inclusion: always"
        echo "---"
        echo ""
        echo "# Apex Spec Workflow"
        echo ""
        printf '%s\n' "$skill_body"
        echo ""
        echo "## Available Commands"
        echo ""
        echo "| Command | Description |"
        echo "|---------|-------------|"
        echo "$command_table"
    } > "$steering_dir/apex-spec.md"

    echo "Kiro: Generated .kiro/steering/apex-spec.md"

    # Copy AGENTS.md (Kiro reads it natively from project root)
    cp "$DIST_DIR/universal/AGENTS.md" "$kiro_dir/AGENTS.md"
    echo "Kiro: Copied AGENTS.md to dist/kiro/"
}

# --- Main build ---

main() {
    echo "=== Apex Spec System Build ==="
    echo "Root: $ROOT_DIR"

    # Wipe and recreate dist/ (idempotent)
    rm -rf "$DIST_DIR"
    mkdir -p "$DIST_DIR"/{codex,cursor,gemini,mcp,universal,cline,windsurf,antigravity,copilot,amazonq,goose,kiro}

    # Copy scripts to universal
    if [ -d "$SCRIPTS_DIR" ]; then
        cp -r "$SCRIPTS_DIR" "$DIST_DIR/universal/scripts"
        echo "Copied scripts/ to dist/universal/scripts/"
    fi

    # Generate AGENTS.md (needed by other targets)
    generate_agents_md "$DIST_DIR/universal/AGENTS.md"
    cp "$DIST_DIR/universal/AGENTS.md" "$ROOT_DIR/AGENTS.md"
    echo "Generated AGENTS.md at root and dist/universal/"

    # --- Phase 0: Codex AGENTS.md ---
    cp "$DIST_DIR/universal/AGENTS.md" "$DIST_DIR/codex/AGENTS.md"
    echo "Copied AGENTS.md to dist/codex/"

    # --- Phase 1: Codex skills ---
    generate_codex_skills

    # --- Phase 1: Cursor commands + rules ---
    generate_cursor

    # --- Phase 2: Gemini CLI commands + skill ---
    generate_gemini

    # --- Phase 2: Gemini extension manifest + GEMINI.md ---
    generate_gemini_extension

    # --- Phase 3: MCP config snippets ---
    generate_mcp_configs

    # --- Phase 5: Cline rules ---
    generate_cline

    # --- Phase 5: Windsurf rules ---
    generate_windsurf

    # --- Phase 5: Antigravity skills (depends on Gemini for GEMINI.md) ---
    generate_antigravity

    # --- Session 13: Copilot + Amazon Q + Goose + Kiro ---
    generate_copilot
    generate_amazonq
    generate_goose
    generate_kiro

    echo "=== Build complete ==="
}

main "$@"
