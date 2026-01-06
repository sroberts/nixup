#!/usr/bin/env bash
#
# nixup update - Sync NixOS system with nixup configuration
#
# Run this script after making changes to the nixup repo to apply
# them to your installed system.
#
# Usage:
#   ./update.sh [options]
#
# Options:
#   --help          Show this help message
#   --test          Build and activate but don't add to bootloader
#   --boot          Build and add to bootloader, activate on next boot
#   --dry-run       Show what would be done without making changes
#   --no-backup     Skip backing up existing configuration
#   --pull          Pull latest changes from git before updating
#

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load library functions
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/prompts.sh"
source "${SCRIPT_DIR}/lib/utils.sh"

# Configuration
NIXOS_CONFIG_DIR="/etc/nixos"
BACKUP_DIR="/etc/nixos/backups"
CONFIG_DIR="${SCRIPT_DIR}/config"

# Options
REBUILD_ACTION="switch"
DRY_RUN=false
SKIP_BACKUP=false
PULL_FIRST=false

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
   Configuration Update
EOF
    echo -e "${RESET}"
}

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") [options]

Sync your NixOS system with the nixup configuration.

Options:
    --help          Show this help message
    --test          Build and activate but don't add to bootloader
    --boot          Build and add to bootloader, activate on next boot
    --dry-run       Show what would be done without making changes
    --no-backup     Skip backing up existing configuration
    --pull          Pull latest changes from git before updating

Examples:
    $(basename "$0")              # Apply changes immediately (switch)
    $(basename "$0") --test       # Test changes without persisting
    $(basename "$0") --boot       # Apply on next reboot
    $(basename "$0") --pull       # Pull git changes first, then apply

This script will:
  1. Optionally pull latest changes from git
  2. Back up your current /etc/nixos configuration
  3. Copy updated config files from this repo
  4. Run nixos-rebuild to apply changes
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
            --test)
                REBUILD_ACTION="test"
                log_info "Will use 'nixos-rebuild test' (no bootloader entry)"
                shift
                ;;
            --boot)
                REBUILD_ACTION="boot"
                log_info "Will use 'nixos-rebuild boot' (activate on next boot)"
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                log_warn "Dry-run mode enabled - no changes will be made"
                shift
                ;;
            --no-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --pull)
                PULL_FIRST=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Check if we're on an installed NixOS system
check_environment() {
    log_info "Checking environment..."

    # Must be root
    if [[ $EUID -ne 0 ]]; then
        log_fatal "This script must be run as root (use sudo)"
    fi

    # Must be on NixOS
    if [[ ! -f /etc/NIXOS ]]; then
        log_fatal "This script must be run on NixOS"
    fi

    # Must have nixos-rebuild
    if ! command -v nixos-rebuild &> /dev/null; then
        log_fatal "nixos-rebuild not found"
    fi

    # Config directory must exist
    if [[ ! -d "$NIXOS_CONFIG_DIR" ]]; then
        log_fatal "NixOS config directory not found: $NIXOS_CONFIG_DIR"
    fi

    # Check if this looks like a nixup-managed system
    if [[ ! -d "$NIXOS_CONFIG_DIR/modules" ]]; then
        log_warn "This doesn't appear to be a nixup-managed system"
        log_warn "Directory $NIXOS_CONFIG_DIR/modules not found"
        if ! confirm "Continue anyway?" "n"; then
            log_fatal "Update cancelled"
        fi
    fi

    log_success "Environment check passed"
}

# Pull latest changes from git
pull_changes() {
    if [[ "$PULL_FIRST" != true ]]; then
        return 0
    fi

    log_info "Pulling latest changes from git..."

    if [[ ! -d "${SCRIPT_DIR}/.git" ]]; then
        log_warn "Not a git repository, skipping pull"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would run: git pull"
        return 0
    fi

    cd "$SCRIPT_DIR"
    if git pull; then
        log_success "Git pull complete"
    else
        log_error "Git pull failed"
        if ! confirm "Continue with current version?" "y"; then
            log_fatal "Update cancelled"
        fi
    fi
}

# Backup existing configuration
backup_config() {
    if [[ "$SKIP_BACKUP" == true ]]; then
        log_info "Skipping backup (--no-backup)"
        return 0
    fi

    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="${BACKUP_DIR}/${timestamp}"

    log_info "Backing up current configuration to ${backup_path}..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would backup to: ${backup_path}"
        return 0
    fi

    mkdir -p "$backup_path"

    # Backup configuration.nix
    if [[ -f "${NIXOS_CONFIG_DIR}/configuration.nix" ]]; then
        cp "${NIXOS_CONFIG_DIR}/configuration.nix" "${backup_path}/"
    fi

    # Backup modules directory
    if [[ -d "${NIXOS_CONFIG_DIR}/modules" ]]; then
        cp -r "${NIXOS_CONFIG_DIR}/modules" "${backup_path}/"
    fi

    # Keep only last 5 backups
    local backup_count
    backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type d | wc -l)
    if [[ $backup_count -gt 6 ]]; then
        log_info "Cleaning old backups..."
        ls -1dt "${BACKUP_DIR}"/*/ | tail -n +6 | xargs rm -rf
    fi

    log_success "Backup complete"
}

# Copy updated configuration files
copy_configs() {
    log_info "Copying configuration files..."

    local modules_dir="${NIXOS_CONFIG_DIR}/modules"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would copy:"
        log_info "  ${CONFIG_DIR}/system/base.nix -> ${modules_dir}/base.nix"
        log_info "  ${CONFIG_DIR}/system/applications.nix -> ${modules_dir}/applications.nix"
        log_info "  ${CONFIG_DIR}/niri/niri.nix -> ${modules_dir}/niri.nix"
        return 0
    fi

    # Ensure modules directory exists
    mkdir -p "$modules_dir"

    # Copy base system config
    if [[ -f "${CONFIG_DIR}/system/base.nix" ]]; then
        cp "${CONFIG_DIR}/system/base.nix" "${modules_dir}/base.nix"
        log_success "Copied base.nix"
    fi

    # Copy applications config
    if [[ -f "${CONFIG_DIR}/system/applications.nix" ]]; then
        cp "${CONFIG_DIR}/system/applications.nix" "${modules_dir}/applications.nix"
        log_success "Copied applications.nix"
    fi

    # Copy Niri config
    if [[ -f "${CONFIG_DIR}/niri/niri.nix" ]]; then
        cp "${CONFIG_DIR}/niri/niri.nix" "${modules_dir}/niri.nix"
        log_success "Copied niri.nix"
    fi

    log_success "Configuration files updated"
}

# Copy user dotfiles
copy_dotfiles() {
    log_info "Updating user dotfiles..."

    # Get the main user (first user in wheel group that isn't root)
    local username
    username=$(getent group wheel | cut -d: -f4 | tr ',' '\n' | grep -v '^root$' | head -1)

    if [[ -z "$username" ]]; then
        log_warn "Could not determine main user, skipping dotfiles"
        return 0
    fi

    local home_dir="/home/${username}"
    local config_dir="${home_dir}/.config"

    if [[ ! -d "$home_dir" ]]; then
        log_warn "Home directory not found: $home_dir"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would update dotfiles for user: $username"
        return 0
    fi

    # Update Niri config
    if [[ -f "${CONFIG_DIR}/home/niri-config.nix" ]]; then
        # Extract the niri config from the nix file
        # For now, we'll update the config directly
        mkdir -p "${config_dir}/niri"

        # Check if user has customized their config
        if [[ -f "${config_dir}/niri/config.kdl" ]]; then
            local niri_backup="${config_dir}/niri/config.kdl.backup.$(date +%Y%m%d_%H%M%S)"
            cp "${config_dir}/niri/config.kdl" "$niri_backup"
            log_info "Backed up existing niri config to $niri_backup"
        fi
    fi

    # Fix ownership
    chown -R "${username}:${username}" "$config_dir"

    log_success "Dotfiles updated for user: $username"
}

# Run nixos-rebuild
rebuild_system() {
    log_info "Running nixos-rebuild ${REBUILD_ACTION}..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would run: nixos-rebuild ${REBUILD_ACTION}"
        return 0
    fi

    echo ""
    echo -e "${BOLD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD_WHITE}  nixos-rebuild ${REBUILD_ACTION}${RESET}"
    echo -e "${BOLD_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""

    if nixos-rebuild "$REBUILD_ACTION"; then
        log_success "System rebuild complete!"
    else
        log_error "System rebuild failed!"
        log_info "Your previous configuration has been backed up"
        log_info "You can restore it from: ${BACKUP_DIR}"
        exit 1
    fi
}

# Show summary
show_summary() {
    echo ""
    echo -e "${BOLD_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD_GREEN}  Update Complete!${RESET}"
    echo -e "${BOLD_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""

    case "$REBUILD_ACTION" in
        switch)
            echo -e "  Changes are now ${BOLD_WHITE}active${RESET}."
            ;;
        test)
            echo -e "  Changes are ${BOLD_WHITE}active${RESET} but will ${YELLOW}revert on reboot${RESET}."
            echo -e "  Run ${CYAN}sudo nixos-rebuild switch${RESET} to make permanent."
            ;;
        boot)
            echo -e "  Changes will be ${BOLD_WHITE}active on next boot${RESET}."
            echo -e "  Reboot to apply changes."
            ;;
    esac

    echo ""
    echo -e "  ${CYAN}Backups:${RESET} ${BACKUP_DIR}"
    echo ""
}

# Main function
main() {
    # Initialize logging
    init_logging

    # Print banner
    print_banner

    # Parse arguments
    parse_args "$@"

    # Check environment
    check_environment

    # Pull changes if requested
    pull_changes

    # Backup current config
    backup_config

    # Copy new configs
    copy_configs

    # Optionally copy dotfiles
    # copy_dotfiles  # Disabled by default - user dotfiles are personal

    # Rebuild system
    rebuild_system

    # Show summary
    if [[ "$DRY_RUN" != true ]]; then
        show_summary
    fi
}

# Run main
main "$@"
