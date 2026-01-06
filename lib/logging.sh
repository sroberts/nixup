#!/usr/bin/env bash
# Logging utilities for nixup installer

# Ensure colors are loaded
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./colors.sh
source "${SCRIPT_DIR}/colors.sh"

# Log levels
declare -A LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3 [FATAL]=4)
export LOG_LEVEL="${LOG_LEVEL:-INFO}"

# Log file location
export LOG_FILE="${LOG_FILE:-/tmp/nixup-install.log}"

# Initialize log file
init_logging() {
    mkdir -p "$(dirname "${LOG_FILE}")"
    echo "=== NixUp Installation Log - $(date -Iseconds) ===" > "${LOG_FILE}"
}

# Internal logging function
_log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # Check if we should log this level
    local level_num="${LOG_LEVELS[$level]:-1}"
    local current_level_num="${LOG_LEVELS[$LOG_LEVEL]:-1}"

    if [[ $level_num -lt $current_level_num ]]; then
        return 0
    fi

    # Always log to file
    echo "[$timestamp] [$level] $message" >> "${LOG_FILE}"

    # Format for terminal
    local color prefix
    case "$level" in
        DEBUG) color="${CYAN}"; prefix="[DEBUG]" ;;
        INFO)  color="${GREEN}"; prefix="[INFO] " ;;
        WARN)  color="${YELLOW}"; prefix="[WARN] " ;;
        ERROR) color="${RED}"; prefix="[ERROR]" ;;
        FATAL) color="${BOLD_RED}"; prefix="[FATAL]" ;;
        *)     color="${WHITE}"; prefix="[???]  " ;;
    esac

    echo -e "${color}${prefix}${RESET} ${message}" >&2
}

# Public logging functions
log_debug() { _log DEBUG "$@"; }
log_info()  { _log INFO "$@"; }
log_warn()  { _log WARN "$@"; }
log_error() { _log ERROR "$@"; }
log_fatal() { _log FATAL "$@"; exit 1; }

# Step logging for installation phases
log_step() {
    local step_num="$1"
    local step_name="$2"
    echo -e "\n${BOLD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD_CYAN}  Step ${step_num}: ${step_name}${RESET}"
    echo -e "${BOLD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    echo "=== Step ${step_num}: ${step_name} ===" >> "${LOG_FILE}"
}

# Success message
log_success() {
    echo -e "${BOLD_GREEN}✓${RESET} $*"
    echo "[SUCCESS] $*" >> "${LOG_FILE}"
}

# Failure message
log_failure() {
    echo -e "${BOLD_RED}✗${RESET} $*"
    echo "[FAILURE] $*" >> "${LOG_FILE}"
}
