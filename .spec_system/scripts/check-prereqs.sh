#!/usr/bin/env bash
# =============================================================================
# check-prereqs.sh - Validate session prerequisites
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# MAIN FUNCTIONS
# =============================================================================

check_required_sessions() {
    local session_id="$1"
    local prereqs="${2:-}"

    log_info "Checking required sessions for: $session_id"

    local failed=0

    if [[ -z "$prereqs" ]]; then
        log_info "No prerequisite sessions specified"
        return 0
    fi

    # Split prereqs by comma or newline
    echo "$prereqs" | tr ',' '\n' | while read -r prereq; do
        prereq=$(echo "$prereq" | xargs)  # Trim whitespace
        [[ -z "$prereq" ]] && continue

        if is_session_completed "$prereq"; then
            log_success "Prerequisite met: $prereq"
        else
            log_error "Prerequisite NOT met: $prereq"
            ((failed++))
        fi
    done

    return $failed
}

check_required_tools() {
    local tools="${1:-}"

    log_info "Checking required tools..."

    local failed=0

    if [[ -z "$tools" ]]; then
        log_info "No specific tools required"
        return 0
    fi

    echo "$tools" | tr ',' '\n' | while read -r tool; do
        tool=$(echo "$tool" | xargs)  # Trim whitespace
        [[ -z "$tool" ]] && continue

        if command -v "$tool" &> /dev/null; then
            log_success "Tool available: $tool"
        else
            log_error "Tool NOT available: $tool"
            ((failed++))
        fi
    done

    return $failed
}

check_required_files() {
    local files="${1:-}"

    log_info "Checking required files..."

    local failed=0

    if [[ -z "$files" ]]; then
        log_info "No specific files required"
        return 0
    fi

    echo "$files" | tr ',' '\n' | while read -r file; do
        file=$(echo "$file" | xargs)  # Trim whitespace
        [[ -z "$file" ]] && continue

        if [[ -f "$file" ]]; then
            log_success "File exists: $file"
        else
            log_error "File NOT found: $file"
            ((failed++))
        fi
    done

    return $failed
}

check_environment() {
    log_info "Checking environment..."

    local failed=0

    # Check spec system
    if check_spec_system; then
        log_success "Spec system: OK"
    else
        log_error "Spec system: FAILED"
        ((failed++))
    fi

    # Check jq
    if command -v jq &> /dev/null; then
        log_success "jq: OK ($(jq --version))"
    else
        log_warning "jq: NOT installed (some features may not work)"
    fi

    # Check git (optional)
    if command -v git &> /dev/null; then
        log_success "git: OK ($(git --version | head -1))"
    else
        log_info "git: NOT installed (optional)"
    fi

    return $failed
}

# =============================================================================
# USAGE
# =============================================================================

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Check prerequisites for a session.

OPTIONS:
  -s, --session ID     Session ID to check prerequisites for
  -t, --tools LIST     Comma-separated list of required tools
  -f, --files LIST     Comma-separated list of required files
  -p, --prereqs LIST   Comma-separated list of prerequisite sessions
  -e, --env            Check environment only
  -h, --help           Show this help message

EXAMPLES:
  $(basename "$0") --env
  $(basename "$0") --session phase01-session03-auth
  $(basename "$0") --tools "node,npm,docker"
  $(basename "$0") --prereqs "phase01-session01-setup,phase01-session02-core"
EOF
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    local session_id=""
    local tools=""
    local files=""
    local prereqs=""
    local env_only=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--session)
                session_id="$2"
                shift 2
                ;;
            -t|--tools)
                tools="$2"
                shift 2
                ;;
            -f|--files)
                files="$2"
                shift 2
                ;;
            -p|--prereqs)
                prereqs="$2"
                shift 2
                ;;
            -e|--env)
                env_only=true
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

    echo "=============================================="
    echo "PREREQUISITE CHECK"
    echo "=============================================="
    echo ""

    local total_failed=0

    # Always check environment
    if ! check_environment; then
        ((total_failed++))
    fi

    if [[ "$env_only" == true ]]; then
        exit $total_failed
    fi

    echo ""

    # Check session prerequisites
    if [[ -n "$session_id" || -n "$prereqs" ]]; then
        if ! check_required_sessions "$session_id" "$prereqs"; then
            ((total_failed++))
        fi
        echo ""
    fi

    # Check tools
    if [[ -n "$tools" ]]; then
        if ! check_required_tools "$tools"; then
            ((total_failed++))
        fi
        echo ""
    fi

    # Check files
    if [[ -n "$files" ]]; then
        if ! check_required_files "$files"; then
            ((total_failed++))
        fi
        echo ""
    fi

    echo "=============================================="
    if [[ $total_failed -eq 0 ]]; then
        log_success "All prerequisites met!"
        exit 0
    else
        log_error "Some prerequisites not met ($total_failed issues)"
        exit 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
