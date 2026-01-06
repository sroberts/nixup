#!/usr/bin/env bash
#
# nixup - NixOS Installation Script for Niri
#
# A modular, maintainable installer for NixOS with Niri Wayland compositor
# Designed for Framework 13 laptops but works on other hardware too
#
# Usage:
#   ./install.sh [options]
#
# Options:
#   --help          Show this help message
#   --dry-run       Show what would be done without making changes
#   --skip-disk     Skip disk partitioning (use existing mounts)
#   --config FILE   Use existing config file for non-interactive install
#

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load library functions
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/prompts.sh"
source "${SCRIPT_DIR}/lib/utils.sh"

# Load modules
source "${SCRIPT_DIR}/modules/disk.sh"
source "${SCRIPT_DIR}/modules/user.sh"
source "${SCRIPT_DIR}/modules/hardware.sh"
source "${SCRIPT_DIR}/modules/nixos-config.sh"

# Global options
DRY_RUN=false
SKIP_DISK=false
CONFIG_FILE=""

# Print banner
print_banner() {
    echo -e "${BOLD_CYAN}"
    cat << 'EOF'
    _   _ _      _   _
   | \ | (_)_  _| | | |_ __
   |  \| | \ \/ / | | | '_ \
   | |\  | |>  <| |_| | |_) |
   |_| \_|_/_/\_\\___/| .__/
                      |_|
   NixOS + Niri Installer
EOF
    echo -e "${RESET}"
    echo -e "${CYAN}Framework 13 optimized • Modular • Maintainable${RESET}"
    echo ""
}

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") [options]

Options:
    --help          Show this help message
    --dry-run       Show what would be done without making changes
    --skip-disk     Skip disk partitioning (use existing mounts)
    --config FILE   Use existing config file for non-interactive install

This script will:
  1. Partition and format your disk (with optional LUKS encryption)
  2. Configure your user account and system settings
  3. Detect hardware and generate optimized NixOS configuration
  4. Install NixOS with Niri Wayland compositor

For Framework 13 laptops, additional hardware optimizations are included.

Report issues: https://github.com/sroberts/nixup/issues
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                log_warn "Dry-run mode enabled - no changes will be made"
                shift
                ;;
            --skip-disk)
                SKIP_DISK=true
                log_info "Skipping disk partitioning"
                shift
                ;;
            --config)
                CONFIG_FILE="$2"
                if [[ ! -f "$CONFIG_FILE" ]]; then
                    log_fatal "Config file not found: $CONFIG_FILE"
                fi
                log_info "Using config file: $CONFIG_FILE"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Pre-flight checks
preflight_checks() {
    log_info "Running pre-flight checks..."

    # Check for root
    require_root

    # Check for NixOS environment
    if ! check_nixos_env; then
        log_fatal "This script must be run from the NixOS installer environment"
    fi

    # Check for UEFI
    if ! is_efi; then
        log_fatal "This installer requires UEFI boot mode"
    fi

    # Check for internet connectivity
    if ! ping -c 1 nixos.org &> /dev/null; then
        log_warn "No internet connection detected. Installation may fail."
        if ! confirm "Continue without internet?" "n"; then
            log_fatal "Installation cancelled"
        fi
    fi

    log_success "Pre-flight checks passed"
}

# Show configuration summary
show_summary() {
    echo ""
    echo -e "${BOLD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD_WHITE}  Installation Summary${RESET}"
    echo -e "${BOLD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  ${CYAN}Disk:${RESET}         ${DISK:-N/A}"
    echo -e "  ${CYAN}Encryption:${RESET}   ${USE_ENCRYPTION:-false}"
    echo -e "  ${CYAN}Swap:${RESET}         ${SWAP_SIZE:-none}"
    echo ""
    echo -e "  ${CYAN}Username:${RESET}     ${USERNAME:-N/A}"
    echo -e "  ${CYAN}Hostname:${RESET}     ${HOSTNAME:-N/A}"
    echo -e "  ${CYAN}Timezone:${RESET}     automatic"
    echo -e "  ${CYAN}Locale:${RESET}       ${LOCALE:-N/A}"
    echo -e "  ${CYAN}Keyboard:${RESET}     ${KEYBOARD_LAYOUT:-N/A}"
    echo ""
    echo -e "  ${CYAN}CPU:${RESET}          ${CPU_VENDOR:-unknown}"
    echo -e "  ${CYAN}GPU:${RESET}          ${GPU_VENDOR:-unknown}"
    echo -e "  ${CYAN}Laptop:${RESET}       ${IS_LAPTOP:-false}"
    echo -e "  ${CYAN}Framework:${RESET}    ${IS_FRAMEWORK:-false}"
    echo ""
    echo -e "${BOLD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# Run NixOS installation
run_nixos_install() {
    log_step "5" "NixOS Installation"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would run: nixos-install --no-root-passwd"
        return 0
    fi

    log_info "Running nixos-install..."
    log_info "This may take a while..."

    if nixos-install --no-root-passwd; then
        log_success "NixOS installation complete!"
    else
        log_fatal "NixOS installation failed. Check the log at ${LOG_FILE}"
    fi
}

# Post-installation tasks
post_install() {
    log_step "6" "Post-Installation"

    local username="${USERNAME:-user}"

    # Set correct ownership of home directory
    if [[ -d "/mnt/home/${username}" ]]; then
        log_info "Setting home directory ownership..."
        # Get the UID from the installed system
        local uid
        uid=$(nixos-enter --root /mnt -- id -u "$username" 2>/dev/null || echo "1000")
        chown -R "${uid}:${uid}" "/mnt/home/${username}"
    fi

    # Create Pictures/Screenshots directory
    ensure_dir "/mnt/home/${username}/Pictures/Screenshots"

    log_success "Post-installation tasks complete"
}

# Cleanup function
cleanup() {
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Installation failed with exit code: $exit_code"
        log_info "Log file: ${LOG_FILE}"

        # Attempt to unmount on failure
        if mountpoint -q /mnt/boot 2>/dev/null; then
            umount /mnt/boot 2>/dev/null || true
        fi
        if mountpoint -q /mnt 2>/dev/null; then
            umount /mnt 2>/dev/null || true
        fi
    fi

    exit $exit_code
}

# Main installation function
main() {
    # Set up trap for cleanup
    trap cleanup EXIT

    # Initialize logging
    init_logging

    # Print banner
    print_banner

    # Parse command line arguments
    parse_args "$@"

    # Run pre-flight checks
    preflight_checks

    # Load config file if provided
    if [[ -n "$CONFIG_FILE" ]]; then
        log_info "Loading configuration from file..."
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
    fi

    # Step 1: Disk Setup
    if [[ "$SKIP_DISK" != true ]]; then
        setup_disk
    else
        log_info "Skipping disk setup - using existing mounts"
        if ! mountpoint -q /mnt; then
            log_fatal "/mnt is not mounted. Mount your partitions or remove --skip-disk"
        fi
    fi

    # Step 2: User Configuration
    setup_user

    # Step 3: Hardware Detection
    setup_hardware

    # Show summary and confirm
    show_summary

    if ! confirm "Proceed with installation?" "y"; then
        log_fatal "Installation cancelled by user"
    fi

    # Step 4: Generate NixOS Configuration
    generate_nixos_config

    # Step 5: Run NixOS Install
    run_nixos_install

    # Step 6: Post-installation
    post_install

    # Success!
    echo ""
    echo -e "${BOLD_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD_GREEN}  Installation Complete!${RESET}"
    echo -e "${BOLD_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  Your NixOS system with Niri is ready!"
    echo ""
    echo -e "  ${CYAN}To finish:${RESET}"
    echo -e "    1. Reboot into your new system"
    echo -e "    2. Log in as ${BOLD_WHITE}${USERNAME}${RESET}"
    echo -e "    3. Niri will start automatically"
    echo ""
    echo -e "  ${CYAN}Key bindings:${RESET}"
    echo -e "    ${WHITE}Super + Return${RESET}  - Open terminal"
    echo -e "    ${WHITE}Super + D${RESET}       - Application launcher"
    echo -e "    ${WHITE}Super + Q${RESET}       - Close window"
    echo -e "    ${WHITE}Super + 1-9${RESET}     - Switch workspace"
    echo ""
    echo -e "  ${CYAN}Configuration location:${RESET}"
    echo -e "    /etc/nixos/configuration.nix"
    echo ""

    if confirm "Reboot now?" "y"; then
        reboot
    fi
}

# Run main
main "$@"
