#!/usr/bin/env bash
# install.sh -- Universal installer for Apex Spec System
# Detects installed tools and copies the right configs to the right places.
# Pure bash, no external dependencies beyond what the build system needs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- State ---
DRY_RUN=false
UNINSTALL=false
TOOL_FILTER=""         # empty = auto-detect
TARGET_DIR="${PWD}"    # where to install (user's project)
INSTALLED=()
SKIPPED=()
ERRORS=()

# --- Usage ---

usage() {
    cat <<EOF
${BOLD}Apex Spec System Installer${NC}

Usage: install.sh [OPTIONS]

Options:
  --tool TOOL       Install for a specific tool only.
                    Values: codex, gemini, cursor, vscode, cline, windsurf, antigravity,
                            copilot, amazonq, goose, kiro, all
  --target DIR      Target project directory (default: current directory)
  --dry-run         Show what would be done without making changes
  --uninstall       Remove installed files
  -h, --help        Show this help

Examples:
  ./install.sh                          # Auto-detect and install
  ./install.sh --tool cursor            # Install Cursor configs only
  ./install.sh --tool all               # Install all tool configs
  ./install.sh --dry-run                # Preview changes
  ./install.sh --uninstall              # Remove installed files
  ./install.sh --target /path/to/proj   # Install into a specific project
EOF
}

# --- Logging ---

log_info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC}   $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERR]${NC}  $*"; }
log_dry()     { echo -e "${YELLOW}[DRY]${NC}  $*"; }

# --- Detection ---

detect_codex() {
    command -v codex >/dev/null 2>&1
}

detect_gemini() {
    command -v gemini >/dev/null 2>&1
}

detect_cursor() {
    [ -d "$TARGET_DIR/.cursor" ] || command -v cursor >/dev/null 2>&1
}

detect_vscode() {
    [ -d "$TARGET_DIR/.vscode" ] || command -v code >/dev/null 2>&1
}

detect_cline() {
    [ -d "$TARGET_DIR/.clinerules" ] || [ -f "$TARGET_DIR/.clinerules" ]
}

detect_windsurf() {
    [ -d "$TARGET_DIR/.windsurf" ] || command -v windsurf >/dev/null 2>&1
}

detect_antigravity() {
    [ -d "$TARGET_DIR/.agent" ] || command -v antigravity >/dev/null 2>&1
}

detect_copilot() {
    [ -d "$TARGET_DIR/.github" ] || command -v gh >/dev/null 2>&1
}

detect_amazonq() {
    [ -d "$TARGET_DIR/.amazonq" ] || command -v q >/dev/null 2>&1
}

detect_goose() {
    [ -f "$TARGET_DIR/.goosehints" ] || command -v goose >/dev/null 2>&1
}

detect_kiro() {
    [ -d "$TARGET_DIR/.kiro" ] || command -v kiro >/dev/null 2>&1
}

detect_node() {
    command -v node >/dev/null 2>&1
}

# --- File operations ---

# Copy a file or directory, creating parent dirs as needed
# Usage: install_file SRC DEST
install_file() {
    local src="$1" dest="$2"
    if $DRY_RUN; then
        log_dry "copy $src -> $dest"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -d "$src" ]; then
        cp -r "$src" "$dest"
    else
        cp "$src" "$dest"
    fi
}

# Remove a file or directory
# Usage: remove_path PATH
remove_path() {
    local path="$1"
    if [ ! -e "$path" ]; then
        return 0
    fi
    if $DRY_RUN; then
        log_dry "remove $path"
        return 0
    fi
    rm -rf "$path"
}

# --- Ensure build ---

ensure_build() {
    if [ -d "$DIST_DIR" ] && [ -f "$DIST_DIR/universal/AGENTS.md" ]; then
        return 0
    fi
    log_info "Build artifacts not found. Running build..."
    if $DRY_RUN; then
        log_dry "would run: make -C $SCRIPT_DIR build"
        return 0
    fi
    make -C "$SCRIPT_DIR" build
}

# --- Install functions ---

install_codex() {
    local src="$DIST_DIR/codex"
    if [ ! -d "$src" ]; then
        log_error "Codex build artifacts not found"
        ERRORS+=("codex: missing build artifacts")
        return 1
    fi

    log_info "Installing Codex CLI configs..."

    # AGENTS.md at project root
    install_file "$src/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # Skills directory
    install_file "$src/.agents" "$TARGET_DIR/.agents"

    # MCP config (if Node available)
    if detect_node && [ -f "$DIST_DIR/mcp/codex.toml" ]; then
        install_file "$DIST_DIR/mcp/codex.toml" "$TARGET_DIR/.codex/config.toml"
    fi

    INSTALLED+=("codex")
    log_success "Codex CLI: installed"
}

install_gemini() {
    local src="$DIST_DIR/gemini"
    if [ ! -d "$src" ]; then
        log_error "Gemini build artifacts not found"
        ERRORS+=("gemini: missing build artifacts")
        return 1
    fi

    log_info "Installing Gemini CLI configs..."

    # AGENTS.md at project root
    install_file "$src/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # Gemini commands and skills
    install_file "$src/.gemini" "$TARGET_DIR/.gemini"

    # GEMINI.md context file
    install_file "$src/GEMINI.md" "$TARGET_DIR/GEMINI.md"

    # Extension manifest (stays in source, user references it)
    # gemini-extension.json is for `gemini extensions install <path>`, not copied

    # MCP config
    if detect_node && [ -f "$DIST_DIR/mcp/gemini.json" ]; then
        install_file "$DIST_DIR/mcp/gemini.json" "$TARGET_DIR/.gemini/settings.json"
    fi

    INSTALLED+=("gemini")
    log_success "Gemini CLI: installed"
}

install_cursor() {
    local src="$DIST_DIR/cursor"
    if [ ! -d "$src" ]; then
        log_error "Cursor build artifacts not found"
        ERRORS+=("cursor: missing build artifacts")
        return 1
    fi

    log_info "Installing Cursor configs..."

    # AGENTS.md at project root
    install_file "$src/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # Cursor commands and rules
    install_file "$src/.cursor" "$TARGET_DIR/.cursor"

    # MCP config
    if detect_node && [ -f "$DIST_DIR/mcp/cursor.json" ]; then
        install_file "$DIST_DIR/mcp/cursor.json" "$TARGET_DIR/.cursor/mcp.json"
    fi

    INSTALLED+=("cursor")
    log_success "Cursor: installed"
}

install_vscode() {
    log_info "Installing VS Code / Copilot configs..."

    # AGENTS.md at project root
    install_file "$DIST_DIR/universal/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # MCP config
    if detect_node && [ -f "$DIST_DIR/mcp/vscode.json" ]; then
        install_file "$DIST_DIR/mcp/vscode.json" "$TARGET_DIR/.vscode/mcp.json"
    fi

    INSTALLED+=("vscode")
    log_success "VS Code: installed"
}

install_cline() {
    local src="$DIST_DIR/cline"
    if [ ! -d "$src" ]; then
        log_error "Cline build artifacts not found"
        ERRORS+=("cline: missing build artifacts")
        return 1
    fi

    log_info "Installing Cline configs..."

    # AGENTS.md at project root
    install_file "$src/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # Cline rules directory
    install_file "$src/.clinerules" "$TARGET_DIR/.clinerules"

    # MCP config
    if detect_node && [ -f "$DIST_DIR/mcp/cline.json" ]; then
        install_file "$DIST_DIR/mcp/cline.json" "$TARGET_DIR/.cline/cline_mcp_settings.json"
    fi

    INSTALLED+=("cline")
    log_success "Cline: installed"
}

install_windsurf() {
    local src="$DIST_DIR/windsurf"
    if [ ! -d "$src" ]; then
        log_error "Windsurf build artifacts not found"
        ERRORS+=("windsurf: missing build artifacts")
        return 1
    fi

    log_info "Installing Windsurf configs..."

    # AGENTS.md at project root
    install_file "$src/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # Windsurf rules
    install_file "$src/.windsurf" "$TARGET_DIR/.windsurf"

    # MCP config
    if detect_node && [ -f "$DIST_DIR/mcp/windsurf.json" ]; then
        install_file "$DIST_DIR/mcp/windsurf.json" "$TARGET_DIR/.windsurf/mcp_config.json"
    fi

    INSTALLED+=("windsurf")
    log_success "Windsurf: installed"
}

install_antigravity() {
    local src="$DIST_DIR/antigravity"
    if [ ! -d "$src" ]; then
        log_error "Antigravity build artifacts not found"
        ERRORS+=("antigravity: missing build artifacts")
        return 1
    fi

    log_info "Installing Antigravity configs..."

    # AGENTS.md at project root
    install_file "$src/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # Skills directory
    install_file "$src/.agent" "$TARGET_DIR/.agent"

    # GEMINI.md context file (shared path)
    install_file "$src/GEMINI.md" "$TARGET_DIR/GEMINI.md"

    INSTALLED+=("antigravity")
    log_success "Antigravity: installed"
}

install_copilot() {
    local src="$DIST_DIR/copilot"
    if [ ! -d "$src" ]; then
        log_error "Copilot build artifacts not found"
        ERRORS+=("copilot: missing build artifacts")
        return 1
    fi

    log_info "Installing GitHub Copilot configs..."

    # AGENTS.md at project root
    install_file "$src/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # .github directory (copilot-instructions.md + instructions/)
    install_file "$src/.github" "$TARGET_DIR/.github"

    # MCP config (VS Code format, since Copilot runs in VS Code)
    if detect_node && [ -f "$DIST_DIR/mcp/vscode.json" ]; then
        install_file "$DIST_DIR/mcp/vscode.json" "$TARGET_DIR/.vscode/mcp.json"
    fi

    INSTALLED+=("copilot")
    log_success "GitHub Copilot: installed"
}

install_amazonq() {
    local src="$DIST_DIR/amazonq"
    if [ ! -d "$src" ]; then
        log_error "Amazon Q build artifacts not found"
        ERRORS+=("amazonq: missing build artifacts")
        return 1
    fi

    log_info "Installing Amazon Q configs..."

    # AGENTS.md at project root
    install_file "$src/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # .amazonq/rules directory
    install_file "$src/.amazonq" "$TARGET_DIR/.amazonq"

    INSTALLED+=("amazonq")
    log_success "Amazon Q: installed"
}

install_goose() {
    local src="$DIST_DIR/goose"
    if [ ! -d "$src" ]; then
        log_error "Goose build artifacts not found"
        ERRORS+=("goose: missing build artifacts")
        return 1
    fi

    log_info "Installing Goose configs..."

    # AGENTS.md at project root (Goose reads it natively)
    install_file "$src/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # .goosehints file
    install_file "$src/.goosehints" "$TARGET_DIR/.goosehints"

    INSTALLED+=("goose")
    log_success "Goose: installed"
}

install_kiro() {
    local src="$DIST_DIR/kiro"
    if [ ! -d "$src" ]; then
        log_error "Kiro build artifacts not found"
        ERRORS+=("kiro: missing build artifacts")
        return 1
    fi

    log_info "Installing Kiro configs..."

    # AGENTS.md at project root (Kiro reads it natively)
    install_file "$src/AGENTS.md" "$TARGET_DIR/AGENTS.md"

    # .kiro/steering directory
    install_file "$src/.kiro" "$TARGET_DIR/.kiro"

    INSTALLED+=("kiro")
    log_success "Kiro: installed"
}

install_mcp_server() {
    if ! detect_node; then
        log_warn "Node.js not found -- skipping MCP server setup"
        SKIPPED+=("mcp-server: no Node.js")
        return 0
    fi

    local mcp_src="$SCRIPT_DIR/mcp-server"
    if [ ! -f "$mcp_src/package.json" ]; then
        log_warn "MCP server source not found"
        SKIPPED+=("mcp-server: source missing")
        return 0
    fi

    log_info "Setting up MCP server..."

    if $DRY_RUN; then
        log_dry "would run: npm install in $mcp_src"
        return 0
    fi

    (cd "$mcp_src" && npm install --silent 2>/dev/null && npx tsc 2>/dev/null) || {
        log_warn "MCP server build failed (non-fatal)"
        SKIPPED+=("mcp-server: build failed")
        return 0
    }

    log_success "MCP server: built"
}

# --- Uninstall ---

uninstall_all() {
    log_info "Removing Apex Spec System files from $TARGET_DIR..."

    local paths=(
        "$TARGET_DIR/AGENTS.md"
        "$TARGET_DIR/GEMINI.md"
        "$TARGET_DIR/.agents"
        "$TARGET_DIR/.gemini/commands"
        "$TARGET_DIR/.gemini/skills/spec-workflow"
        "$TARGET_DIR/.gemini/settings.json"
        "$TARGET_DIR/.cursor/commands"
        "$TARGET_DIR/.cursor/rules/apex-spec.md"
        "$TARGET_DIR/.cursor/mcp.json"
        "$TARGET_DIR/.vscode/mcp.json"
        "$TARGET_DIR/.codex/config.toml"
        "$TARGET_DIR/.clinerules/apex-spec.md"
        "$TARGET_DIR/.cline/cline_mcp_settings.json"
        "$TARGET_DIR/.windsurf/rules/apex-spec-plan.md"
        "$TARGET_DIR/.windsurf/rules/apex-spec-build.md"
        "$TARGET_DIR/.windsurf/rules/apex-spec-harden.md"
        "$TARGET_DIR/.windsurf/mcp_config.json"
        "$TARGET_DIR/.agent/skills/spec-workflow"
        "$TARGET_DIR/.github/copilot-instructions.md"
        "$TARGET_DIR/.github/instructions/apex-spec.instructions.md"
        "$TARGET_DIR/.amazonq/rules/apex-spec.md"
        "$TARGET_DIR/.goosehints"
        "$TARGET_DIR/.kiro/steering/apex-spec.md"
    )

    local removed=0
    for path in "${paths[@]}"; do
        if [ -e "$path" ]; then
            remove_path "$path"
            removed=$((removed + 1))
            if $DRY_RUN; then
                : # already logged
            else
                log_success "Removed: $path"
            fi
        fi
    done

    if [ "$removed" -eq 0 ]; then
        log_info "Nothing to remove."
    else
        log_success "Removed $removed items."
    fi
}

# --- Summary ---

print_summary() {
    echo ""
    echo -e "${BOLD}=== Installation Summary ===${NC}"
    echo -e "  Target: $TARGET_DIR"

    if [ ${#INSTALLED[@]} -gt 0 ]; then
        echo -e "  ${GREEN}Installed:${NC} ${INSTALLED[*]}"
    fi
    if [ ${#SKIPPED[@]} -gt 0 ]; then
        echo -e "  ${YELLOW}Skipped:${NC}"
        for s in "${SKIPPED[@]}"; do
            echo "    - $s"
        done
    fi
    if [ ${#ERRORS[@]} -gt 0 ]; then
        echo -e "  ${RED}Errors:${NC}"
        for e in "${ERRORS[@]}"; do
            echo "    - $e"
        done
    fi

    if $DRY_RUN; then
        echo ""
        echo -e "  ${YELLOW}(dry run -- no changes made)${NC}"
    fi
    echo ""
}

# --- Main ---

main() {
    # Parse args
    while [ $# -gt 0 ]; do
        case "$1" in
            --tool)
                TOOL_FILTER="$2"
                shift 2
                ;;
            --target)
                TARGET_DIR="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --uninstall)
                UNINSTALL=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Resolve target to absolute path
    TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

    echo -e "${BOLD}Apex Spec System Installer${NC}"
    echo "Source: $SCRIPT_DIR"
    echo "Target: $TARGET_DIR"
    echo ""

    # Uninstall mode
    if $UNINSTALL; then
        uninstall_all
        exit 0
    fi

    # Ensure build artifacts exist
    ensure_build

    # Build MCP server if Node available
    install_mcp_server

    # Determine which tools to install
    if [ "$TOOL_FILTER" = "all" ]; then
        install_codex
        install_gemini
        install_cursor
        install_vscode
        install_cline
        install_windsurf
        install_antigravity
        install_copilot
        install_amazonq
        install_goose
        install_kiro
    elif [ -n "$TOOL_FILTER" ]; then
        case "$TOOL_FILTER" in
            codex)        install_codex ;;
            gemini)       install_gemini ;;
            cursor)       install_cursor ;;
            vscode)       install_vscode ;;
            cline)        install_cline ;;
            windsurf)     install_windsurf ;;
            antigravity)  install_antigravity ;;
            copilot)      install_copilot ;;
            amazonq)      install_amazonq ;;
            goose)        install_goose ;;
            kiro)         install_kiro ;;
            *)
                log_error "Unknown tool: $TOOL_FILTER (expected: codex, gemini, cursor, vscode, cline, windsurf, antigravity, copilot, amazonq, goose, kiro, all)"
                exit 1
                ;;
        esac
    else
        # Auto-detect
        log_info "Auto-detecting installed tools..."
        local detected=0

        if detect_codex; then
            install_codex
            detected=$((detected + 1))
        else
            SKIPPED+=("codex: not detected")
        fi

        if detect_gemini; then
            install_gemini
            detected=$((detected + 1))
        else
            SKIPPED+=("gemini: not detected")
        fi

        if detect_cursor; then
            install_cursor
            detected=$((detected + 1))
        else
            SKIPPED+=("cursor: not detected")
        fi

        if detect_vscode; then
            install_vscode
            detected=$((detected + 1))
        else
            SKIPPED+=("vscode: not detected")
        fi

        if detect_cline; then
            install_cline
            detected=$((detected + 1))
        else
            SKIPPED+=("cline: not detected")
        fi

        if detect_windsurf; then
            install_windsurf
            detected=$((detected + 1))
        else
            SKIPPED+=("windsurf: not detected")
        fi

        if detect_antigravity; then
            install_antigravity
            detected=$((detected + 1))
        else
            SKIPPED+=("antigravity: not detected")
        fi

        if detect_copilot; then
            install_copilot
            detected=$((detected + 1))
        else
            SKIPPED+=("copilot: not detected")
        fi

        if detect_amazonq; then
            install_amazonq
            detected=$((detected + 1))
        else
            SKIPPED+=("amazonq: not detected")
        fi

        if detect_goose; then
            install_goose
            detected=$((detected + 1))
        else
            SKIPPED+=("goose: not detected")
        fi

        if detect_kiro; then
            install_kiro
            detected=$((detected + 1))
        else
            SKIPPED+=("kiro: not detected")
        fi

        if [ "$detected" -eq 0 ]; then
            log_warn "No supported tools detected. Use --tool to install manually."
            log_info "Supported tools: codex, gemini, cursor, vscode, cline, windsurf, antigravity, copilot, amazonq, goose, kiro, all"
        fi
    fi

    print_summary
}

main "$@"
