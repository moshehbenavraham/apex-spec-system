#!/usr/bin/env bash
# =============================================================================
# check-prereqs.sh - Validate session prerequisites
# =============================================================================
# Usage:
#   ./check-prereqs.sh --env                    # Check environment only
#   ./check-prereqs.sh --tools "node,npm"       # Check specific tools
#   ./check-prereqs.sh --json --env             # JSON output for Claude
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# OUTPUT MODE
# =============================================================================

OUTPUT_MODE="human"
JSON_RESULT=""

# =============================================================================
# JSON BUILDING HELPERS
# =============================================================================

init_json() {
    JSON_RESULT=$(jq -n '{
        "generated_at": "",
        "overall": "pass",
        "environment": {},
        "tools": {},
        "sessions": {},
        "files": {},
        "issues": []
    }')
}

set_json_field() {
    local path="$1"
    local value="$2"
    JSON_RESULT=$(echo "$JSON_RESULT" | jq "$path = $value")
}

add_json_issue() {
    local type="$1"
    local name="$2"
    local message="$3"
    JSON_RESULT=$(echo "$JSON_RESULT" | jq \
        --arg type "$type" \
        --arg name "$name" \
        --arg msg "$message" \
        '.issues += [{"type": $type, "name": $name, "message": $msg}]')
    JSON_RESULT=$(echo "$JSON_RESULT" | jq '.overall = "fail"')
}

set_check_result() {
    local category="$1"
    local name="$2"
    local status="$3"
    local extra="${4:-}"

    if [[ -n "$extra" ]]; then
        JSON_RESULT=$(echo "$JSON_RESULT" | jq \
            --arg cat "$category" \
            --arg name "$name" \
            --arg status "$status" \
            --arg extra "$extra" \
            '.[$cat][$name] = {"status": $status, "info": $extra}')
    else
        JSON_RESULT=$(echo "$JSON_RESULT" | jq \
            --arg cat "$category" \
            --arg name "$name" \
            --arg status "$status" \
            '.[$cat][$name] = {"status": $status}')
    fi
}

# =============================================================================
# CHECK FUNCTIONS
# =============================================================================

check_required_sessions() {
    local prereqs="${1:-}"

    if [[ "$OUTPUT_MODE" == "human" ]]; then
        log_info "Checking required sessions..."
    fi

    if [[ -z "$prereqs" ]]; then
        if [[ "$OUTPUT_MODE" == "human" ]]; then
            log_info "No prerequisite sessions specified"
        fi
        return 0
    fi

    local failed=0

    while IFS= read -r prereq; do
        prereq=$(echo "$prereq" | xargs)  # Trim whitespace
        [[ -z "$prereq" ]] && continue

        if is_session_completed "$prereq"; then
            if [[ "$OUTPUT_MODE" == "human" ]]; then
                log_success "Prerequisite met: $prereq"
            else
                set_check_result "sessions" "$prereq" "pass" "completed"
            fi
        else
            if [[ "$OUTPUT_MODE" == "human" ]]; then
                log_error "Prerequisite NOT met: $prereq"
            else
                set_check_result "sessions" "$prereq" "fail" "not completed"
                add_json_issue "session" "$prereq" "prerequisite session not completed"
            fi
            ((failed++)) || true
        fi
    done <<< "$(echo "$prereqs" | tr ',' '\n')"

    return $failed
}

check_required_tools() {
    local tools="${1:-}"

    if [[ "$OUTPUT_MODE" == "human" ]]; then
        log_info "Checking required tools..."
    fi

    if [[ -z "$tools" ]]; then
        if [[ "$OUTPUT_MODE" == "human" ]]; then
            log_info "No specific tools required"
        fi
        return 0
    fi

    local failed=0

    for tool in $(echo "$tools" | tr ',' '\n'); do
        tool=$(echo "$tool" | xargs)  # Trim whitespace
        [[ -z "$tool" ]] && continue

        if command -v "$tool" &> /dev/null; then
            local version=""
            # Try to get version for common tools
            case "$tool" in
                node) version=$(node --version 2>/dev/null || echo "unknown") ;;
                npm) version=$(npm --version 2>/dev/null || echo "unknown") ;;
                python|python3) version=$($tool --version 2>/dev/null | head -1 || echo "unknown") ;;
                docker) version=$(docker --version 2>/dev/null | head -1 || echo "unknown") ;;
                git) version=$(git --version 2>/dev/null | head -1 || echo "unknown") ;;
                go) version=$(go version 2>/dev/null | head -1 || echo "unknown") ;;
                cargo) version=$(cargo --version 2>/dev/null | head -1 || echo "unknown") ;;
                *) version=$($tool --version 2>/dev/null | head -1 || echo "available") ;;
            esac

            if [[ "$OUTPUT_MODE" == "human" ]]; then
                log_success "Tool available: $tool ($version)"
            else
                set_check_result "tools" "$tool" "pass" "$version"
            fi
        else
            if [[ "$OUTPUT_MODE" == "human" ]]; then
                log_error "Tool NOT available: $tool"
            else
                set_check_result "tools" "$tool" "fail" "not installed"
                add_json_issue "tool" "$tool" "required tool not installed"
            fi
            ((failed++)) || true
        fi
    done

    return $failed
}

check_required_files() {
    local files="${1:-}"

    if [[ "$OUTPUT_MODE" == "human" ]]; then
        log_info "Checking required files..."
    fi

    if [[ -z "$files" ]]; then
        if [[ "$OUTPUT_MODE" == "human" ]]; then
            log_info "No specific files required"
        fi
        return 0
    fi

    local failed=0

    for file in $(echo "$files" | tr ',' '\n'); do
        file=$(echo "$file" | xargs)  # Trim whitespace
        [[ -z "$file" ]] && continue

        if [[ -f "$file" ]]; then
            if [[ "$OUTPUT_MODE" == "human" ]]; then
                log_success "File exists: $file"
            else
                set_check_result "files" "$file" "pass" "exists"
            fi
        else
            if [[ "$OUTPUT_MODE" == "human" ]]; then
                log_error "File NOT found: $file"
            else
                set_check_result "files" "$file" "fail" "not found"
                add_json_issue "file" "$file" "required file not found"
            fi
            ((failed++)) || true
        fi
    done

    return $failed
}

check_environment() {
    if [[ "$OUTPUT_MODE" == "human" ]]; then
        log_info "Checking environment..."
    fi

    local failed=0

    # Check spec system
    if [[ -d "$SPEC_SYSTEM_DIR" && -f "$STATE_FILE" ]]; then
        if validate_json "$STATE_FILE" 2>/dev/null; then
            if [[ "$OUTPUT_MODE" == "human" ]]; then
                log_success "Spec system: OK"
            else
                set_check_result "environment" "spec_system" "pass" "$SPEC_SYSTEM_DIR"
            fi
        else
            if [[ "$OUTPUT_MODE" == "human" ]]; then
                log_error "Spec system: Invalid state.json"
            else
                set_check_result "environment" "spec_system" "fail" "invalid state.json"
                add_json_issue "environment" "spec_system" "state.json is not valid JSON"
            fi
            ((failed++)) || true
        fi
    else
        if [[ "$OUTPUT_MODE" == "human" ]]; then
            log_error "Spec system: NOT found"
        else
            set_check_result "environment" "spec_system" "fail" "not found"
            add_json_issue "environment" "spec_system" ".spec_system directory or state.json not found"
        fi
        ((failed++)) || true
    fi

    # Check jq
    if command -v jq &> /dev/null; then
        local jq_version
        jq_version=$(jq --version 2>/dev/null || echo "unknown")
        if [[ "$OUTPUT_MODE" == "human" ]]; then
            log_success "jq: OK ($jq_version)"
        else
            set_check_result "environment" "jq" "pass" "$jq_version"
        fi
    else
        if [[ "$OUTPUT_MODE" == "human" ]]; then
            log_error "jq: NOT installed (required for scripts)"
        else
            set_check_result "environment" "jq" "fail" "not installed"
            add_json_issue "environment" "jq" "jq is required but not installed"
        fi
        ((failed++)) || true
    fi

    # Check git (optional but noted)
    if command -v git &> /dev/null; then
        local git_version
        git_version=$(git --version 2>/dev/null | head -1 || echo "unknown")
        if [[ "$OUTPUT_MODE" == "human" ]]; then
            log_success "git: OK ($git_version)"
        else
            set_check_result "environment" "git" "pass" "$git_version"
        fi
    else
        if [[ "$OUTPUT_MODE" == "human" ]]; then
            log_info "git: NOT installed (optional)"
        else
            set_check_result "environment" "git" "skip" "not installed (optional)"
        fi
    fi

    return $failed
}

# =============================================================================
# USAGE
# =============================================================================

show_usage() {
    cat << 'EOF'
Usage: check-prereqs.sh [OPTIONS]

Check prerequisites for a session.

OPTIONS:
  -t, --tools LIST     Comma-separated list of required tools
  -f, --files LIST     Comma-separated list of required files
  -p, --prereqs LIST   Comma-separated list of prerequisite sessions
  -e, --env            Check environment only
  --json               Output results as JSON (for Claude integration)
  -h, --help           Show this help message

OUTPUT MODES:
  Default (no --json): Human-readable output with colors
  --json: Structured JSON for programmatic use

JSON OUTPUT STRUCTURE:
  {
    "generated_at": "2024-01-15 10:30:00",
    "overall": "pass" | "fail",
    "environment": {
      "spec_system": {"status": "pass", "info": ".spec_system"},
      "jq": {"status": "pass", "info": "jq-1.7"}
    },
    "tools": {
      "node": {"status": "pass", "info": "v20.10.0"},
      "docker": {"status": "fail", "info": "not installed"}
    },
    "sessions": {
      "phase00-session01": {"status": "pass", "info": "completed"}
    },
    "files": {
      "package.json": {"status": "pass", "info": "exists"}
    },
    "issues": [
      {"type": "tool", "name": "docker", "message": "required tool not installed"}
    ]
  }

EXAMPLES:
  ./check-prereqs.sh --env                      # Check environment
  ./check-prereqs.sh --tools "node,npm,docker"  # Check tools
  ./check-prereqs.sh --json --env               # JSON output
  ./check-prereqs.sh --json --env --tools "node,npm"
EOF
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    local tools=""
    local files=""
    local prereqs=""
    local env_only=false
    local run_any=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --json)
                OUTPUT_MODE="json"
                check_jq || exit 1
                init_json
                shift
                ;;
            -t|--tools)
                tools="$2"
                run_any=true
                shift 2
                ;;
            -f|--files)
                files="$2"
                run_any=true
                shift 2
                ;;
            -p|--prereqs)
                prereqs="$2"
                run_any=true
                shift 2
                ;;
            -e|--env)
                env_only=true
                run_any=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Default to env check if nothing specified
    if [[ "$run_any" == false ]]; then
        env_only=true
    fi

    if [[ "$OUTPUT_MODE" == "json" ]]; then
        set_json_field '.generated_at' "\"$(get_datetime)\""
    else
        echo "=============================================="
        echo "PREREQUISITE CHECK"
        echo "=============================================="
        echo ""
    fi

    local total_failed=0

    # Always check environment first
    if ! check_environment; then
        ((total_failed++)) || true
    fi

    if [[ "$env_only" == true && -z "$tools" && -z "$files" && -z "$prereqs" ]]; then
        # Just environment check
        :
    else
        if [[ "$OUTPUT_MODE" == "human" ]]; then
            echo ""
        fi

        # Check session prerequisites
        if [[ -n "$prereqs" ]]; then
            if ! check_required_sessions "$prereqs"; then
                ((total_failed++)) || true
            fi
            [[ "$OUTPUT_MODE" == "human" ]] && echo ""
        fi

        # Check tools
        if [[ -n "$tools" ]]; then
            if ! check_required_tools "$tools"; then
                ((total_failed++)) || true
            fi
            [[ "$OUTPUT_MODE" == "human" ]] && echo ""
        fi

        # Check files
        if [[ -n "$files" ]]; then
            if ! check_required_files "$files"; then
                ((total_failed++)) || true
            fi
            [[ "$OUTPUT_MODE" == "human" ]] && echo ""
        fi
    fi

    # Output results
    if [[ "$OUTPUT_MODE" == "json" ]]; then
        echo "$JSON_RESULT" | jq .
    else
        echo "=============================================="
        if [[ $total_failed -eq 0 ]]; then
            log_success "All prerequisites met!"
        else
            log_error "Some prerequisites not met ($total_failed issues)"
        fi
    fi

    # Exit with appropriate code
    if [[ "$OUTPUT_MODE" == "json" ]]; then
        local overall
        overall=$(echo "$JSON_RESULT" | jq -r '.overall')
        [[ "$overall" == "pass" ]] && exit 0 || exit 1
    else
        [[ $total_failed -eq 0 ]] && exit 0 || exit 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
