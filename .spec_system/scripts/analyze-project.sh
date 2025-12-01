#!/usr/bin/env bash
# =============================================================================
# analyze-project.sh - Analyze project state for session recommendations
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# MAIN FUNCTIONS
# =============================================================================

analyze_phases() {
    log_info "Analyzing phases..."

    local current_phase
    current_phase=$(get_current_phase)

    echo "Current Phase: $current_phase"
    echo ""
    echo "Phase Status:"
    echo "-------------"

    # Get all phase numbers from state
    local phases
    phases=$(json_get "$STATE_FILE" '.phases | keys[]' 2>/dev/null || echo "")

    for phase in $phases; do
        local name status count
        name=$(get_phase_name "$phase")
        status=$(get_phase_status "$phase")
        count=$(get_phase_session_count "$phase")
        printf "  Phase %02d: %-25s [%s] (%d sessions)\n" "$phase" "$name" "$status" "$count"
    done
}

analyze_sessions() {
    log_info "Analyzing completed sessions..."

    local count
    count=$(get_completed_sessions_count)

    echo ""
    echo "Completed Sessions: $count"
    echo "-------------------"

    get_completed_sessions | while read -r session; do
        [[ -n "$session" ]] && echo "  - $session"
    done
}

analyze_current() {
    log_info "Analyzing current state..."

    local current
    current=$(get_current_session)

    echo ""
    echo "Current Session: ${current:-"(none)"}"

    if [[ "$current" != "null" && -n "$current" ]]; then
        local session_dir
        session_dir=$(get_session_dir "$current")

        echo "Session Directory: $session_dir"

        if [[ -d "$session_dir" ]]; then
            echo "Files:"
            ls -la "$session_dir" 2>/dev/null | tail -n +2
        else
            echo "  (directory not created yet)"
        fi
    fi
}

analyze_next_candidates() {
    log_info "Finding next session candidates..."

    local current_phase
    current_phase=$(get_current_phase)

    local prd_dir="${SPEC_SYSTEM_DIR}/PRD/phase_$(printf '%02d' "$current_phase")"

    echo ""
    echo "Next Session Candidates (Phase $current_phase):"
    echo "----------------------------------------------"

    if [[ -d "$prd_dir" ]]; then
        # List session files that aren't completed
        find "$prd_dir" -name "session_*.md" -type f | sort | while read -r file; do
            local filename
            filename=$(basename "$file" .md)

            # Extract session number from filename (session_NN_name)
            if [[ "$filename" =~ ^session_([0-9]+)_ ]]; then
                local session_num="${BASH_REMATCH[1]}"
                local session_id
                session_id=$(build_session_id "$current_phase" "$session_num" "placeholder")

                if ! is_session_number_completed "$session_num" "$current_phase"; then
                    echo "  - $filename (not completed)"
                else
                    echo "  - $filename (completed)"
                fi
            fi
        done
    else
        echo "  (no phase directory found: $prd_dir)"
    fi
}

show_summary() {
    echo ""
    echo "=============================================="
    echo "PROJECT ANALYSIS SUMMARY"
    echo "=============================================="

    local project_name
    project_name=$(get_project_name)

    echo "Project: $project_name"
    echo "State File: $STATE_FILE"
    echo ""

    analyze_phases
    analyze_sessions
    analyze_current
    analyze_next_candidates

    echo ""
    echo "=============================================="
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    check_spec_system || exit 1
    show_summary
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
