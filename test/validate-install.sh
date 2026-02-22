#!/usr/bin/env bash
# test/validate-install.sh -- Validate build artifacts and installation integrity
# Checks: file existence, syntax, size limits, MCP server health
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"

# --- State ---
PASS=0
FAIL=0
WARN=0
TESTS=()

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# --- Test helpers ---

pass() {
    PASS=$((PASS + 1))
    TESTS+=("PASS: $1")
    echo -e "  ${GREEN}PASS${NC} $1"
}

fail() {
    FAIL=$((FAIL + 1))
    TESTS+=("FAIL: $1")
    echo -e "  ${RED}FAIL${NC} $1"
}

warn() {
    WARN=$((WARN + 1))
    TESTS+=("WARN: $1")
    echo -e "  ${YELLOW}WARN${NC} $1"
}

check_file() {
    local path="$1" label="${2:-$1}"
    if [ -f "$path" ]; then
        pass "$label exists"
    else
        fail "$label missing"
    fi
}

check_dir() {
    local path="$1" label="${2:-$1}"
    if [ -d "$path" ]; then
        pass "$label exists"
    else
        fail "$label missing"
    fi
}

check_file_count() {
    local dir="$1" pattern="$2" expected="$3" label="$4"
    local count
    count=$(find "$dir" -name "$pattern" -type f 2>/dev/null | wc -l)
    if [ "$count" -eq "$expected" ]; then
        pass "$label: $count files (expected $expected)"
    else
        fail "$label: $count files (expected $expected)"
    fi
}

check_ascii() {
    local file="$1" label="${2:-$1}"
    if LC_ALL=C grep -Pn '[\x80-\xFF]' "$file" >/dev/null 2>&1; then
        fail "$label contains non-ASCII characters"
    else
        pass "$label is ASCII-only"
    fi
}

check_json() {
    local file="$1" label="${2:-$1}"
    if ! [ -f "$file" ]; then
        fail "$label: file not found"
        return
    fi
    # Try python first, fall back to node, then basic check
    if command -v python3 >/dev/null 2>&1; then
        if python3 -m json.tool "$file" >/dev/null 2>&1; then
            pass "$label: valid JSON"
        else
            fail "$label: invalid JSON"
        fi
    elif command -v node >/dev/null 2>&1; then
        if node -e "JSON.parse(require('fs').readFileSync('$file','utf8'))" 2>/dev/null; then
            pass "$label: valid JSON"
        else
            fail "$label: invalid JSON"
        fi
    else
        # Basic check: starts with { and ends with }
        if head -1 "$file" | grep -q '^\s*{' && tail -1 "$file" | grep -q '}\s*$'; then
            pass "$label: JSON structure looks valid (no validator available)"
        else
            warn "$label: cannot validate JSON (no python3 or node)"
        fi
    fi
}

check_toml_basic() {
    local file="$1" label="${2:-$1}"
    if ! [ -f "$file" ]; then
        fail "$label: file not found"
        return
    fi
    # Basic check: no unclosed triple-quoted strings
    local opens closes
    opens=$(grep -c '"""' "$file" 2>/dev/null || echo 0)
    if [ "$((opens % 2))" -eq 0 ]; then
        pass "$label: TOML triple-quotes balanced"
    else
        fail "$label: TOML has unbalanced triple-quotes"
    fi
}

# --- Test suites ---

test_build_artifacts() {
    echo -e "\n${BOLD}=== Build Artifacts ===${NC}"

    check_dir "$DIST_DIR" "dist/"
    check_dir "$DIST_DIR/codex" "dist/codex/"
    check_dir "$DIST_DIR/cursor" "dist/cursor/"
    check_dir "$DIST_DIR/gemini" "dist/gemini/"
    check_dir "$DIST_DIR/mcp" "dist/mcp/"
    check_dir "$DIST_DIR/universal" "dist/universal/"
    check_dir "$DIST_DIR/cline" "dist/cline/"
    check_dir "$DIST_DIR/windsurf" "dist/windsurf/"
    check_dir "$DIST_DIR/antigravity" "dist/antigravity/"
    check_dir "$DIST_DIR/copilot" "dist/copilot/"
    check_dir "$DIST_DIR/amazonq" "dist/amazonq/"
    check_dir "$DIST_DIR/goose" "dist/goose/"
    check_dir "$DIST_DIR/kiro" "dist/kiro/"
}

test_agents_md() {
    echo -e "\n${BOLD}=== AGENTS.md ===${NC}"

    local agents="$ROOT_DIR/AGENTS.md"
    check_file "$agents" "AGENTS.md (root)"

    if [ -f "$agents" ]; then
        # Size check
        local size
        size=$(wc -c < "$agents")
        if [ "$size" -gt 32768 ]; then
            fail "AGENTS.md: ${size} bytes (exceeds 32KB limit)"
        elif [ "$size" -lt 100 ]; then
            fail "AGENTS.md: ${size} bytes (suspiciously small)"
        else
            pass "AGENTS.md: ${size} bytes (under 32KB)"
        fi

        check_ascii "$agents" "AGENTS.md"

        # Copies in each dist
        for tool in codex cursor gemini; do
            check_file "$DIST_DIR/$tool/AGENTS.md" "dist/$tool/AGENTS.md"
        done
    fi
}

test_codex() {
    echo -e "\n${BOLD}=== Codex CLI ===${NC}"

    local skills_dir="$DIST_DIR/codex/.agents/skills"
    check_dir "$skills_dir" "Codex skills directory"

    if [ -d "$skills_dir" ]; then
        check_file_count "$skills_dir" "SKILL.md" 14 "Codex SKILL.md files"
        check_file_count "$skills_dir" "openai.yaml" 14 "Codex openai.yaml files"

        # Spot-check one skill
        local sample="$skills_dir/initspec/SKILL.md"
        if [ -f "$sample" ]; then
            if head -1 "$sample" | grep -q '^---$'; then
                pass "Codex initspec/SKILL.md has YAML frontmatter"
            else
                fail "Codex initspec/SKILL.md missing YAML frontmatter"
            fi
            check_ascii "$sample" "Codex initspec/SKILL.md"
        fi

        # Scripts copied
        local scripts_count
        scripts_count=$(find "$skills_dir" -name "scripts" -type d 2>/dev/null | wc -l)
        if [ "$scripts_count" -ge 14 ]; then
            pass "Codex: scripts/ copied to all $scripts_count skills"
        else
            warn "Codex: scripts/ found in $scripts_count skills (expected 14)"
        fi
    fi
}

test_cursor() {
    echo -e "\n${BOLD}=== Cursor ===${NC}"

    local cursor_dir="$DIST_DIR/cursor/.cursor"
    check_dir "$cursor_dir/commands" "Cursor commands directory"
    check_dir "$cursor_dir/rules" "Cursor rules directory"

    if [ -d "$cursor_dir/commands" ]; then
        check_file_count "$cursor_dir/commands" "*.md" 14 "Cursor command files"

        # Spot-check: commands should NOT have YAML frontmatter
        local sample="$cursor_dir/commands/initspec.md"
        if [ -f "$sample" ]; then
            if head -1 "$sample" | grep -q '^---$'; then
                fail "Cursor initspec.md has YAML frontmatter (should be stripped)"
            else
                pass "Cursor initspec.md: frontmatter stripped"
            fi
            check_ascii "$sample" "Cursor initspec.md"
        fi
    fi

    # Rule file
    local rule="$cursor_dir/rules/apex-spec.md"
    check_file "$rule" "Cursor apex-spec.md rule"
    if [ -f "$rule" ]; then
        if head -3 "$rule" | grep -q 'alwaysApply: true'; then
            pass "Cursor rule has alwaysApply: true"
        else
            fail "Cursor rule missing alwaysApply: true"
        fi
    fi
}

test_gemini() {
    echo -e "\n${BOLD}=== Gemini CLI ===${NC}"

    local gemini_dir="$DIST_DIR/gemini"
    check_dir "$gemini_dir/.gemini/commands" "Gemini commands directory"

    if [ -d "$gemini_dir/.gemini/commands" ]; then
        check_file_count "$gemini_dir/.gemini/commands" "*.toml" 14 "Gemini TOML command files"

        # Spot-check TOML validity
        local sample="$gemini_dir/.gemini/commands/initspec.toml"
        if [ -f "$sample" ]; then
            check_toml_basic "$sample" "Gemini initspec.toml"
            check_ascii "$sample" "Gemini initspec.toml"

            # Check required fields
            if grep -q '^description = ' "$sample"; then
                pass "Gemini initspec.toml has description field"
            else
                fail "Gemini initspec.toml missing description field"
            fi
            if grep -q '^prompt = """' "$sample"; then
                pass "Gemini initspec.toml has multiline prompt"
            else
                fail "Gemini initspec.toml missing multiline prompt"
            fi
        fi
    fi

    # Skill
    check_file "$gemini_dir/.gemini/skills/spec-workflow/SKILL.md" "Gemini skill"
    check_dir "$gemini_dir/.gemini/skills/spec-workflow/references" "Gemini skill references"

    # Extension manifest
    check_file "$gemini_dir/gemini-extension.json" "Gemini extension manifest"
    if [ -f "$gemini_dir/gemini-extension.json" ]; then
        check_json "$gemini_dir/gemini-extension.json" "gemini-extension.json"
    fi

    # GEMINI.md context file
    check_file "$gemini_dir/GEMINI.md" "GEMINI.md context file"
}

test_cline() {
    echo -e "\n${BOLD}=== Cline ===${NC}"

    local cline_dir="$DIST_DIR/cline"
    check_dir "$cline_dir/.clinerules" "Cline rules directory"

    local rule="$cline_dir/.clinerules/apex-spec.md"
    check_file "$rule" "Cline apex-spec.md rule"
    if [ -f "$rule" ]; then
        # Should have YAML frontmatter with paths field
        if head -1 "$rule" | grep -q '^---$'; then
            pass "Cline rule has YAML frontmatter"
        else
            fail "Cline rule missing YAML frontmatter"
        fi
        if grep -q 'paths:' "$rule"; then
            pass "Cline rule has paths field"
        else
            fail "Cline rule missing paths field"
        fi
        check_ascii "$rule" "Cline apex-spec.md"
    fi

    check_file "$cline_dir/AGENTS.md" "dist/cline/AGENTS.md"
}

test_windsurf() {
    echo -e "\n${BOLD}=== Windsurf ===${NC}"

    local windsurf_dir="$DIST_DIR/windsurf"
    check_dir "$windsurf_dir/.windsurf/rules" "Windsurf rules directory"

    if [ -d "$windsurf_dir/.windsurf/rules" ]; then
        check_file_count "$windsurf_dir/.windsurf/rules" "*.md" 3 "Windsurf rule files"

        # Check each stage file
        for stage in plan build harden; do
            local f="$windsurf_dir/.windsurf/rules/apex-spec-${stage}.md"
            check_file "$f" "Windsurf apex-spec-${stage}.md"
            if [ -f "$f" ]; then
                check_ascii "$f" "Windsurf apex-spec-${stage}.md"
                # Verify under 12K chars
                local size
                size=$(wc -c < "$f")
                if [ "$size" -le 12000 ]; then
                    pass "Windsurf apex-spec-${stage}.md: ${size} bytes (under 12K)"
                else
                    fail "Windsurf apex-spec-${stage}.md: ${size} bytes (exceeds 12K)"
                fi
                # Should have trigger frontmatter
                if head -3 "$f" | grep -q 'trigger:'; then
                    pass "Windsurf apex-spec-${stage}.md has trigger field"
                else
                    fail "Windsurf apex-spec-${stage}.md missing trigger field"
                fi
            fi
        done
    fi

    check_file "$windsurf_dir/AGENTS.md" "dist/windsurf/AGENTS.md"
}

test_antigravity() {
    echo -e "\n${BOLD}=== Antigravity ===${NC}"

    local ag_dir="$DIST_DIR/antigravity"
    check_dir "$ag_dir/.agent/skills/spec-workflow" "Antigravity skill directory"

    local skill="$ag_dir/.agent/skills/spec-workflow/SKILL.md"
    check_file "$skill" "Antigravity SKILL.md"
    if [ -f "$skill" ]; then
        if head -1 "$skill" | grep -q '^---$'; then
            pass "Antigravity SKILL.md has YAML frontmatter"
        else
            fail "Antigravity SKILL.md missing YAML frontmatter"
        fi
        check_ascii "$skill" "Antigravity SKILL.md"
    fi

    check_dir "$ag_dir/.agent/skills/spec-workflow/references" "Antigravity skill references"
    check_file "$ag_dir/GEMINI.md" "Antigravity GEMINI.md"
    check_file "$ag_dir/AGENTS.md" "dist/antigravity/AGENTS.md"
}

test_copilot() {
    echo -e "\n${BOLD}=== GitHub Copilot ===${NC}"

    local copilot_dir="$DIST_DIR/copilot"

    # Repo-wide instructions
    local instructions="$copilot_dir/.github/copilot-instructions.md"
    check_file "$instructions" "Copilot copilot-instructions.md"
    if [ -f "$instructions" ]; then
        # Should NOT have YAML frontmatter (plain markdown)
        if head -1 "$instructions" | grep -q '^---$'; then
            fail "Copilot copilot-instructions.md has frontmatter (should be plain markdown)"
        else
            pass "Copilot copilot-instructions.md: no frontmatter (correct)"
        fi
        check_ascii "$instructions" "Copilot copilot-instructions.md"
    fi

    # Path-specific instructions
    local specific="$copilot_dir/.github/instructions/apex-spec.instructions.md"
    check_file "$specific" "Copilot apex-spec.instructions.md"
    if [ -f "$specific" ]; then
        # Should have YAML frontmatter with applyTo
        if head -1 "$specific" | grep -q '^---$'; then
            pass "Copilot instructions file has YAML frontmatter"
        else
            fail "Copilot instructions file missing YAML frontmatter"
        fi
        if grep -q 'applyTo:' "$specific"; then
            pass "Copilot instructions file has applyTo field"
        else
            fail "Copilot instructions file missing applyTo field"
        fi
        check_ascii "$specific" "Copilot apex-spec.instructions.md"
    fi

    check_file "$copilot_dir/AGENTS.md" "dist/copilot/AGENTS.md"
}

test_amazonq() {
    echo -e "\n${BOLD}=== Amazon Q ===${NC}"

    local aq_dir="$DIST_DIR/amazonq"
    check_dir "$aq_dir/.amazonq/rules" "Amazon Q rules directory"

    local rule="$aq_dir/.amazonq/rules/apex-spec.md"
    check_file "$rule" "Amazon Q apex-spec.md rule"
    if [ -f "$rule" ]; then
        # Should NOT have YAML frontmatter (plain markdown)
        if head -1 "$rule" | grep -q '^---$'; then
            fail "Amazon Q rule has YAML frontmatter (should be plain markdown)"
        else
            pass "Amazon Q rule: no frontmatter (correct)"
        fi
        # Should have Purpose and Instructions sections
        if grep -q '## Purpose' "$rule"; then
            pass "Amazon Q rule has Purpose section"
        else
            fail "Amazon Q rule missing Purpose section"
        fi
        check_ascii "$rule" "Amazon Q apex-spec.md"
    fi

    check_file "$aq_dir/AGENTS.md" "dist/amazonq/AGENTS.md"
}

test_goose() {
    echo -e "\n${BOLD}=== Goose ===${NC}"

    local goose_dir="$DIST_DIR/goose"

    local hints="$goose_dir/.goosehints"
    check_file "$hints" "Goose .goosehints"
    if [ -f "$hints" ]; then
        # Should NOT have YAML frontmatter
        if head -1 "$hints" | grep -q '^---$'; then
            fail "Goose .goosehints has frontmatter (should be plain text)"
        else
            pass "Goose .goosehints: no frontmatter (correct)"
        fi
        # Should reference AGENTS.md via @ syntax
        if grep -q '@AGENTS.md' "$hints"; then
            pass "Goose .goosehints references @AGENTS.md"
        else
            warn "Goose .goosehints does not reference @AGENTS.md"
        fi
        check_ascii "$hints" "Goose .goosehints"
    fi

    check_file "$goose_dir/AGENTS.md" "dist/goose/AGENTS.md"
}

test_kiro() {
    echo -e "\n${BOLD}=== Kiro ===${NC}"

    local kiro_dir="$DIST_DIR/kiro"
    check_dir "$kiro_dir/.kiro/steering" "Kiro steering directory"

    local steering="$kiro_dir/.kiro/steering/apex-spec.md"
    check_file "$steering" "Kiro apex-spec.md steering"
    if [ -f "$steering" ]; then
        # Should have YAML frontmatter with inclusion field
        if head -1 "$steering" | grep -q '^---$'; then
            pass "Kiro steering file has YAML frontmatter"
        else
            fail "Kiro steering file missing YAML frontmatter"
        fi
        if grep -q 'inclusion:' "$steering"; then
            pass "Kiro steering file has inclusion field"
        else
            fail "Kiro steering file missing inclusion field"
        fi
        check_ascii "$steering" "Kiro apex-spec.md"
    fi

    check_file "$kiro_dir/AGENTS.md" "dist/kiro/AGENTS.md"
}

test_mcp() {
    echo -e "\n${BOLD}=== MCP Configs ===${NC}"

    local mcp_dir="$DIST_DIR/mcp"
    check_dir "$mcp_dir" "MCP config directory"

    if [ -d "$mcp_dir" ]; then
        # JSON configs
        for cfg in cursor.json vscode.json cline.json windsurf.json gemini.json; do
            check_file "$mcp_dir/$cfg" "MCP $cfg"
            if [ -f "$mcp_dir/$cfg" ]; then
                check_json "$mcp_dir/$cfg" "MCP $cfg"
            fi
        done

        # TOML config
        check_file "$mcp_dir/codex.toml" "MCP codex.toml"
    fi
}

test_mcp_server() {
    echo -e "\n${BOLD}=== MCP Server ===${NC}"

    check_file "$ROOT_DIR/mcp-server/package.json" "MCP server package.json"
    check_file "$ROOT_DIR/mcp-server/src/index.ts" "MCP server source"

    if [ -f "$ROOT_DIR/mcp-server/package.json" ]; then
        check_json "$ROOT_DIR/mcp-server/package.json" "MCP server package.json"
    fi

    # Check if built
    if [ -f "$ROOT_DIR/mcp-server/dist/index.js" ]; then
        pass "MCP server: compiled (dist/index.js exists)"

        # Try starting server and checking tools/list (if node available)
        if command -v node >/dev/null 2>&1; then
            local response
            response=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | \
                timeout 5 node "$ROOT_DIR/mcp-server/dist/index.js" 2>/dev/null | head -1 || echo "")
            if echo "$response" | grep -q '"result"' 2>/dev/null; then
                pass "MCP server: responds to initialize"
            else
                warn "MCP server: could not verify initialize response"
            fi
        else
            warn "MCP server: Node.js not available, skipping runtime test"
        fi
    else
        warn "MCP server: not compiled (run 'make mcp-build')"
    fi
}

test_installer() {
    echo -e "\n${BOLD}=== Installer ===${NC}"

    check_file "$ROOT_DIR/install.sh" "install.sh"
    if [ -f "$ROOT_DIR/install.sh" ]; then
        if [ -x "$ROOT_DIR/install.sh" ]; then
            pass "install.sh is executable"
        else
            fail "install.sh is not executable"
        fi
        check_ascii "$ROOT_DIR/install.sh" "install.sh"

        # Verify --help works
        if "$ROOT_DIR/install.sh" --help >/dev/null 2>&1; then
            pass "install.sh --help runs without error"
        else
            fail "install.sh --help failed"
        fi
    fi
}

test_scripts() {
    echo -e "\n${BOLD}=== Scripts ===${NC}"

    for script in analyze-project.sh check-prereqs.sh common.sh; do
        check_file "$ROOT_DIR/scripts/$script" "scripts/$script"
        if [ -f "$ROOT_DIR/scripts/$script" ]; then
            check_ascii "$ROOT_DIR/scripts/$script" "scripts/$script"
        fi
    done

    check_file "$ROOT_DIR/build/generate.sh" "build/generate.sh"
    if [ -f "$ROOT_DIR/build/generate.sh" ]; then
        check_ascii "$ROOT_DIR/build/generate.sh" "build/generate.sh"
    fi
}

# --- Summary ---

print_summary() {
    local total=$((PASS + FAIL + WARN))
    echo ""
    echo -e "${BOLD}=== Validation Summary ===${NC}"
    echo -e "  Total:    $total"
    echo -e "  ${GREEN}Passed:${NC}  $PASS"
    echo -e "  ${RED}Failed:${NC}  $FAIL"
    echo -e "  ${YELLOW}Warned:${NC}  $WARN"
    echo ""

    if [ "$FAIL" -gt 0 ]; then
        echo -e "${RED}VALIDATION FAILED${NC}"
        return 1
    else
        echo -e "${GREEN}VALIDATION PASSED${NC}"
        return 0
    fi
}

# --- Main ---

main() {
    echo -e "${BOLD}Apex Spec System -- Installation Validator${NC}"
    echo "Root: $ROOT_DIR"

    test_build_artifacts
    test_agents_md
    test_codex
    test_cursor
    test_gemini
    test_cline
    test_windsurf
    test_antigravity
    test_copilot
    test_amazonq
    test_goose
    test_kiro
    test_mcp
    test_mcp_server
    test_installer
    test_scripts

    print_summary
}

main "$@"
