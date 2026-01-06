#!/usr/bin/env bash
# General utilities for nixup installer

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./logging.sh
source "${SCRIPT_DIR}/logging.sh"

# Check if running as root
require_root() {
    if [[ $EUID -ne 0 ]]; then
        log_fatal "This script must be run as root"
    fi
}

# Check if running in NixOS installer environment
check_nixos_env() {
    if ! command -v nixos-install &> /dev/null; then
        log_error "nixos-install not found. Are you running from the NixOS installer?"
        return 1
    fi
    return 0
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Run a command with error handling
run() {
    local description="$1"
    shift

    log_info "Running: $description"
    log_debug "Command: $*"

    if "$@" >> "${LOG_FILE}" 2>&1; then
        log_success "$description"
        return 0
    else
        local exit_code=$?
        log_failure "$description (exit code: $exit_code)"
        return $exit_code
    fi
}

# Run a command and capture output
run_capture() {
    local description="$1"
    shift

    log_debug "Running (capture): $*"

    local output
    if output=$("$@" 2>&1); then
        echo "$output"
        return 0
    else
        local exit_code=$?
        log_error "Command failed: $description"
        log_debug "Output: $output"
        return $exit_code
    fi
}

# Detect system hardware
detect_hardware() {
    local vendor product

    if [[ -f /sys/class/dmi/id/sys_vendor ]]; then
        vendor=$(cat /sys/class/dmi/id/sys_vendor)
    fi

    if [[ -f /sys/class/dmi/id/product_name ]]; then
        product=$(cat /sys/class/dmi/id/product_name)
    fi

    echo "${vendor:-Unknown} ${product:-Unknown}"
}

# Check if running on Framework laptop
is_framework() {
    local hardware
    hardware=$(detect_hardware)
    [[ "$hardware" == *"Framework"* ]]
}

# Get total RAM in GB
get_ram_gb() {
    local mem_kb
    mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    echo $(( mem_kb / 1024 / 1024 ))
}

# Get available disks
get_disks() {
    lsblk -dno NAME,SIZE,TYPE | grep disk | awk '{print "/dev/" $1 " (" $2 ")"}'
}

# Get disk size in bytes
get_disk_size() {
    local disk="$1"
    blockdev --getsize64 "$disk"
}

# Check if disk has partitions
disk_has_partitions() {
    local disk="$1"
    local partitions
    partitions=$(lsblk -n "$disk" | wc -l)
    [[ $partitions -gt 1 ]]
}

# Check if EFI system
is_efi() {
    [[ -d /sys/firmware/efi ]]
}

# Get CPU vendor
get_cpu_vendor() {
    if grep -q "GenuineIntel" /proc/cpuinfo; then
        echo "intel"
    elif grep -q "AuthenticAMD" /proc/cpuinfo; then
        echo "amd"
    else
        echo "unknown"
    fi
}

# Get GPU vendor
get_gpu_vendor() {
    if lspci | grep -qi "nvidia"; then
        echo "nvidia"
    elif lspci | grep -qi "amd.*radeon\|radeon.*amd"; then
        echo "amd"
    elif lspci | grep -qi "intel.*graphics\|graphics.*intel"; then
        echo "intel"
    else
        echo "unknown"
    fi
}

# Backup a file with timestamp
backup_file() {
    local file="$1"
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"

    if [[ -f "$file" ]]; then
        cp "$file" "$backup"
        log_info "Backed up $file to $backup"
        echo "$backup"
    fi
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_debug "Created directory: $dir"
    fi
}

# Generate a random string
random_string() {
    local length="${1:-32}"
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

# Validate hostname
validate_hostname() {
    local hostname="$1"

    # Check length
    if [[ ${#hostname} -lt 1 || ${#hostname} -gt 63 ]]; then
        return 1
    fi

    # Check format (alphanumeric and hyphens, not starting/ending with hyphen)
    if [[ ! "$hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
        return 1
    fi

    return 0
}

# Validate username
validate_username() {
    local username="$1"

    # Check length
    if [[ ${#username} -lt 1 || ${#username} -gt 32 ]]; then
        return 1
    fi

    # Check format (lowercase alphanumeric and underscores, starting with letter)
    if [[ ! "$username" =~ ^[a-z][a-z0-9_]*$ ]]; then
        return 1
    fi

    return 0
}
