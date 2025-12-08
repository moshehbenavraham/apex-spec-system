#!/usr/bin/env bash
# =============================================================================
# common.sh - Shared utilities for the Apex Spec System
# =============================================================================
# Source this file in other scripts: source "$(dirname "$0")/common.sh"
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

SPEC_SYSTEM_DIR="${SPEC_SYSTEM_DIR:-.spec_system}"
STATE_FILE="${SPEC_SYSTEM_DIR}/state.json"
SPECS_DIR="${SPECS_DIR:-${SPEC_SYSTEM_DIR}/specs}"

# =============================================================================
# COLORS AND LOGGING
# =============================================================================

# Colors (only if terminal supports it)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    NC=''
fi

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $*"
    fi
}

# =============================================================================
# JSON OPERATIONS (requires jq)
# =============================================================================

check_jq() {
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed. Install with: apt install jq"
        return 1
    fi
}

json_get() {
    local file="$1"
    local path="$2"

    check_jq || return 1

    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi

    jq -r "$path" "$file"
}

json_set() {
    local file="$1"
    local path="$2"
    local value="$3"

    check_jq || return 1

    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi

    local tmp_file
    tmp_file=$(mktemp)

    jq "$path = $value" "$file" > "$tmp_file" && mv "$tmp_file" "$file"
}

json_append_array() {
    local file="$1"
    local path="$2"
    local value="$3"

    check_jq || return 1

    local tmp_file
    tmp_file=$(mktemp)

    jq "$path += [$value]" "$file" > "$tmp_file" && mv "$tmp_file" "$file"
}

validate_json() {
    local file="$1"

    check_jq || return 1

    if jq empty "$file" 2>/dev/null; then
        return 0
    else
        log_error "Invalid JSON in $file"
        return 1
    fi
}

# =============================================================================
# SESSION ID PARSING
# =============================================================================
# Session ID format: phaseNN-sessionNN[x]-name
# Examples:
#   phase00-session01-project-setup
#   phase01-session08b-refinements

parse_session_id() {
    local session_id="$1"
    local phase_var="${2:-}"
    local session_var="${3:-}"
    local suffix_var="${4:-}"
    local name_var="${5:-}"

    # Regex: phase([0-9]{2})-session([0-9]{2})([a-z])?-(.+)
    if [[ "$session_id" =~ ^phase([0-9]{2})-session([0-9]{2})([a-z])?-(.+)$ ]]; then
        [[ -n "$phase_var" ]] && eval "$phase_var='${BASH_REMATCH[1]}'"
        [[ -n "$session_var" ]] && eval "$session_var='${BASH_REMATCH[2]}'"
        [[ -n "$suffix_var" ]] && eval "$suffix_var='${BASH_REMATCH[3]}'"
        [[ -n "$name_var" ]] && eval "$name_var='${BASH_REMATCH[4]}'"
        return 0
    else
        log_error "Invalid session ID format: $session_id"
        return 1
    fi
}

get_phase_from_session_id() {
    local session_id="$1"
    local phase
    parse_session_id "$session_id" phase && echo "$phase"
}

get_session_number_from_id() {
    local session_id="$1"
    local session
    parse_session_id "$session_id" "" session && echo "$session"
}

get_session_suffix_from_id() {
    local session_id="$1"
    local suffix
    parse_session_id "$session_id" "" "" suffix && echo "$suffix"
}

get_session_name_from_id() {
    local session_id="$1"
    local name
    parse_session_id "$session_id" "" "" "" name && echo "$name"
}

build_session_id() {
    local phase="$1"
    local session="$2"
    local name="$3"
    local suffix="${4:-}"

    # Zero-pad phase and session
    printf "phase%02d-session%02d%s-%s" "$phase" "$session" "$suffix" "$name"
}

# Build session reference (e.g., S0103 for Phase 01, Session 03)
build_session_ref() {
    local phase="$1"
    local session="$2"

    printf "S%02d%02d" "$phase" "$session"
}

# =============================================================================
# STATE QUERIES
# =============================================================================

get_current_phase() {
    json_get "$STATE_FILE" '.current_phase'
}

get_current_session() {
    json_get "$STATE_FILE" '.current_session'
}

get_project_name() {
    json_get "$STATE_FILE" '.project_name'
}

get_completed_sessions() {
    json_get "$STATE_FILE" '.completed_sessions[]' 2>/dev/null || true
}

get_completed_sessions_count() {
    json_get "$STATE_FILE" '.completed_sessions | length'
}

is_session_completed() {
    local session_id="$1"
    local completed
    completed=$(get_completed_sessions)

    if echo "$completed" | grep -q "^${session_id}$"; then
        return 0
    else
        return 1
    fi
}

# Check if session number is completed (handles suffixes like session08b)
is_session_number_completed() {
    local session_num="$1"
    local phase="${2:-$(get_current_phase)}"
    local completed
    completed=$(get_completed_sessions)

    # Match any session with this number (with or without suffix)
    local pattern
    pattern=$(printf "phase%02d-session%02d" "$phase" "$session_num")

    if echo "$completed" | grep -q "^${pattern}"; then
        return 0
    else
        return 1
    fi
}

get_phase_status() {
    local phase="$1"
    json_get "$STATE_FILE" ".phases[\"$phase\"].status"
}

get_phase_name() {
    local phase="$1"
    json_get "$STATE_FILE" ".phases[\"$phase\"].name"
}

get_phase_session_count() {
    local phase="$1"
    json_get "$STATE_FILE" ".phases[\"$phase\"].session_count"
}

# =============================================================================
# STATE UPDATES
# =============================================================================

set_current_session() {
    local session_id="$1"
    json_set "$STATE_FILE" '.current_session' "\"$session_id\""
}

clear_current_session() {
    json_set "$STATE_FILE" '.current_session' 'null'
}

add_completed_session() {
    local session_id="$1"
    json_append_array "$STATE_FILE" '.completed_sessions' "\"$session_id\""
}

set_phase_status() {
    local phase="$1"
    local status="$2"
    json_set "$STATE_FILE" ".phases[\"$phase\"].status" "\"$status\""
}

# =============================================================================
# FILE VALIDATION
# =============================================================================

validate_ascii() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi

    # Check for non-ASCII characters (bytes > 127)
    if grep -qP '[^\x00-\x7F]' "$file"; then
        log_error "Non-ASCII characters found in: $file"
        return 1
    fi

    # Check for CRLF line endings
    if grep -qP '\r\n' "$file"; then
        log_error "CRLF line endings found in: $file"
        return 1
    fi

    return 0
}

find_non_ascii() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi

    # Show non-ASCII characters with line numbers
    grep -nP '[^\x00-\x7F]' "$file" || true
}

validate_all_files() {
    local dir="${1:-.}"
    local errors=0

    while IFS= read -r -d '' file; do
        if ! validate_ascii "$file"; then
            ((errors++))
        fi
    done < <(find "$dir" -type f \( -name "*.md" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.json" \) -print0)

    if [[ $errors -gt 0 ]]; then
        log_error "Found $errors files with encoding issues"
        return 1
    fi

    log_success "All files pass ASCII validation"
    return 0
}

# =============================================================================
# DIRECTORY OPERATIONS
# =============================================================================

ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    fi
}

get_session_dir() {
    local session_id="$1"
    echo "${SPECS_DIR}/${session_id}"
}

session_dir_exists() {
    local session_id="$1"
    [[ -d "$(get_session_dir "$session_id")" ]]
}

# =============================================================================
# DATE/TIME UTILITIES
# =============================================================================

get_date() {
    date '+%Y-%m-%d'
}

get_datetime() {
    date '+%Y-%m-%d %H:%M:%S'
}

get_timestamp() {
    date '+%Y%m%d_%H%M%S'
}

# =============================================================================
# INITIALIZATION CHECK
# =============================================================================

check_spec_system() {
    if [[ ! -d "$SPEC_SYSTEM_DIR" ]]; then
        log_error "Spec system not found. Expected: $SPEC_SYSTEM_DIR/"
        return 1
    fi

    if [[ ! -f "$STATE_FILE" ]]; then
        log_error "State file not found: $STATE_FILE"
        return 1
    fi

    if ! validate_json "$STATE_FILE"; then
        return 1
    fi

    return 0
}

# =============================================================================
# HELP
# =============================================================================

show_common_help() {
    cat << 'EOF'
Apex Spec System - Common Utilities

Functions available after sourcing common.sh:

LOGGING:
  log_info <msg>      - Blue info message
  log_success <msg>   - Green success message
  log_warning <msg>   - Yellow warning message
  log_error <msg>     - Red error message

JSON (requires jq):
  json_get <file> <path>           - Read JSON value
  json_set <file> <path> <value>   - Write JSON value
  validate_json <file>             - Validate JSON syntax

SESSION ID:
  parse_session_id <id> [vars...]  - Parse session ID components
  get_phase_from_session_id <id>   - Extract phase number
  build_session_id <p> <s> <name>  - Construct session ID
  build_session_ref <p> <s>        - Build ref like S0103

STATE:
  get_current_phase                - Current phase number
  get_current_session              - Current session ID
  get_completed_sessions           - List completed sessions
  is_session_completed <id>        - Check if completed
  set_current_session <id>         - Update current session
  add_completed_session <id>       - Mark session complete

VALIDATION:
  validate_ascii <file>            - Check ASCII encoding
  find_non_ascii <file>            - List non-ASCII chars
  check_spec_system                - Verify setup

UTILITIES:
  get_date                         - YYYY-MM-DD
  get_datetime                     - YYYY-MM-DD HH:MM:SS
  ensure_dir <dir>                 - Create if not exists
  get_session_dir <id>             - Get specs/session path
EOF
}

# Show help if script run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_common_help
fi
