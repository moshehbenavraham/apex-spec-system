# Scripts Reference

Bash automation scripts for the Apex Spec System.

## Setup

Make scripts executable:

```bash
chmod +x .spec_system/scripts/*.sh
```

## Available Scripts

| Script | Purpose |
|--------|---------|
| `common.sh` | Shared utilities (source in other scripts) |
| `analyze-project.sh` | Analyze project state for recommendations |
| `check-prereqs.sh` | Validate session prerequisites |
| `setup-session.sh` | Create session directory structure |

## common.sh

Shared utilities - source this in other scripts:

```bash
source "$(dirname "$0")/common.sh"
```

### Logging Functions
```bash
log_info "Information message"
log_success "Success message"
log_warning "Warning message"
log_error "Error message"
```

### JSON Operations (requires jq)
```bash
json_get "$STATE_FILE" '.current_phase'
json_set "$STATE_FILE" '.current_session' '"phase01-session01-setup"'
validate_json "$STATE_FILE"
```

### Session ID Parsing
```bash
# Parse components
parse_session_id "phase01-session03-auth" phase session suffix name

# Extract specific parts
get_phase_from_session_id "phase01-session03-auth"  # Returns: 01
get_session_number_from_id "phase01-session03-auth"  # Returns: 03

# Build session ID
build_session_id 1 3 "auth"  # Returns: phase01-session03-auth
build_session_ref 1 3        # Returns: S0103
```

### State Operations
```bash
get_current_phase
get_current_session
get_completed_sessions
is_session_completed "phase01-session01-setup"
set_current_session "phase01-session02-core"
add_completed_session "phase01-session01-setup"
```

### Validation
```bash
validate_ascii "path/to/file"
find_non_ascii "path/to/file"
check_spec_system
```

## analyze-project.sh

Analyze project state and show summary:

```bash
./analyze-project.sh
```

Output includes:
- Phase status overview
- Completed sessions list
- Current session state
- Next session candidates

## check-prereqs.sh

Validate prerequisites for a session:

```bash
# Check environment only
./check-prereqs.sh --env

# Check specific session
./check-prereqs.sh --session phase01-session03-auth

# Check required tools
./check-prereqs.sh --tools "node,npm,docker"

# Check prerequisite sessions
./check-prereqs.sh --prereqs "phase01-session01-setup,phase01-session02-core"

# Combined
./check-prereqs.sh -s phase01-session03-auth -t "node,npm" -p "phase01-session01-setup"
```

## setup-session.sh

Create session directory structure:

```bash
# Create directory only
./setup-session.sh phase01-session03-auth

# Create with placeholders
./setup-session.sh phase01-session03-auth --placeholder

# Create and update state
./setup-session.sh phase01-session03-auth --update-state

# All options
./setup-session.sh phase01-session03-auth -p -u
```

## Dependencies

- **bash**: 4.0+ recommended
- **jq**: Required for JSON operations
- **grep**: With PCRE support (-P flag)

Install jq:
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# Windows (via chocolatey)
choco install jq
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SPEC_SYSTEM_DIR` | `.spec_system` | Spec system directory |
| `STATE_FILE` | `.spec_system/state.json` | State file path |
| `SPECS_DIR` | `specs` | Specs directory |
| `DEBUG` | `0` | Enable debug logging |

## Examples

### Analyze Before Starting Work
```bash
./analyze-project.sh
```

### Verify Ready for Session
```bash
./check-prereqs.sh --env
./check-prereqs.sh --session phase01-session03-auth
```

### Set Up New Session
```bash
./setup-session.sh phase01-session03-auth -p -u
```

### Custom Script Using Common
```bash
#!/usr/bin/env bash
source .spec_system/scripts/common.sh

check_spec_system || exit 1

current=$(get_current_session)
log_info "Current session: $current"

if is_session_completed "phase01-session01-setup"; then
    log_success "Foundation complete!"
fi
```
