#!/usr/bin/env bash
#
# nixup - NixOS Flake Installation Script
#
# A minimal installer that partitions the disk and runs nixos-install
# with the flake configuration.
#
# Usage:
#   ./install.sh [options]
#
# Options:
#   --help          Show this help message
#   --dry-run       Show what would be done without making changes
#   --no-encrypt    Skip LUKS encryption
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Options
DRY_RUN=false
USE_ENCRYPTION=true
DISK=""
SWAP_SIZE=""
USERNAME=""
USER_FULLNAME=""
USER_PASSWORD=""
HOSTNAME=""
GIT_USERNAME=""
GIT_EMAIL=""

# Logging functions
log_info() { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[OK]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }

# Print banner
print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
    _   _ _      _   _
   | \ | (_)_  _| | | |_ __
   |  \| | \ \/ / | | | '_ \
   | |\  | |>  <| |_| | |_) |
   |_| \_|_/_/\_\\___/| .__/
                      |_|
   NixOS + Niri Flake Installer
EOF
    echo -e "${RESET}"
    echo -e "${CYAN}Framework 13 optimized • Flake-based • Declarative${RESET}"
    echo ""
}

# Show help
show_help() {
    cat << EOF
Usage: $(basename "$0") [options]

Options:
    --help          Show this help message
    --dry-run       Show what would be done without making changes
    --no-encrypt    Skip LUKS encryption

This script will:
  1. Partition and format your disk (with optional LUKS encryption)
  2. Generate hardware configuration
  3. Install NixOS using the flake

After installation:
  - Edit hosts/framework/default.nix to set your username
  - Run: nixos-rebuild switch --flake .#framework

Report issues: https://github.com/sroberts/nixup/issues
EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                log_warn "Dry-run mode enabled"
                shift
                ;;
            --no-encrypt)
                USE_ENCRYPTION=false
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

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Select disk
select_disk() {
    log_info "Available disks:"
    echo ""
    lsblk -d -o NAME,SIZE,MODEL | grep -v "loop\|sr\|NAME"
    echo ""

    read -rp "Enter disk to install on (e.g., nvme0n1, sda): " disk_name
    DISK="/dev/${disk_name}"

    if [[ ! -b "$DISK" ]]; then
        log_error "Disk not found: $DISK"
        exit 1
    fi

    echo ""
    log_warn "WARNING: All data on $DISK will be destroyed!"
    read -rp "Type 'yes' to continue: " confirm
    if [[ "$confirm" != "yes" ]]; then
        log_error "Aborted"
        exit 1
    fi
}

# Get swap size
get_swap_size() {
    local ram_gb
    ram_gb=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)

    echo ""
    log_info "System has ${ram_gb}GB RAM"
    read -rp "Swap size (e.g., 8G, 16G, or 'none'): " SWAP_SIZE

    if [[ "$SWAP_SIZE" == "none" ]]; then
        SWAP_SIZE=""
    fi
}

# Get encryption password
get_encryption_password() {
    if [[ "$USE_ENCRYPTION" != true ]]; then
        return
    fi

    echo ""
    log_info "Setting up LUKS encryption"

    while true; do
        read -rsp "Enter encryption password: " pass1
        echo ""
        read -rsp "Confirm encryption password: " pass2
        echo ""

        if [[ "$pass1" == "$pass2" ]]; then
            LUKS_PASSWORD="$pass1"
            break
        else
            log_error "Passwords don't match, try again"
        fi
    done
}

# Get user details
get_user_details() {
    echo ""
    log_info "User Configuration"

    # Username
    while true; do
        read -rp "Username: " USERNAME
        if [[ "$USERNAME" =~ ^[a-z][a-z0-9_-]*$ ]]; then
            break
        else
            log_error "Invalid username. Use lowercase letters, numbers, underscores, hyphens."
        fi
    done

    # Full name
    read -rp "Full name [$USERNAME]: " USER_FULLNAME
    USER_FULLNAME="${USER_FULLNAME:-$USERNAME}"

    # Password
    while true; do
        read -rsp "User password: " pass1
        echo ""
        read -rsp "Confirm password: " pass2
        echo ""

        if [[ "$pass1" == "$pass2" ]]; then
            USER_PASSWORD="$pass1"
            break
        else
            log_error "Passwords don't match, try again"
        fi
    done

    # Hostname
    read -rp "System hostname [framework]: " HOSTNAME
    HOSTNAME="${HOSTNAME:-framework}"

    echo ""
    log_success "User: $USERNAME ($USER_FULLNAME)"
    log_success "Hostname: $HOSTNAME"
}

# Get git identity
get_git_identity() {
    echo ""
    log_info "Git Configuration (optional, press Enter to skip)"

    read -rp "Git username: " GIT_USERNAME
    read -rp "Git email: " GIT_EMAIL

    if [[ -n "$GIT_USERNAME" && -n "$GIT_EMAIL" ]]; then
        log_success "Git: $GIT_USERNAME <$GIT_EMAIL>"
    else
        log_info "Git identity not configured (can be set later in local.nix)"
    fi
}

# Generate local.nix configuration
configure_user() {
    log_info "Generating local.nix configuration..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would generate local.nix for user: $USERNAME"
        return
    fi

    local local_config="${SCRIPT_DIR}/hosts/framework/local.nix"

    # Generate password hash
    local password_hash
    password_hash=$(echo -n "$USER_PASSWORD" | mkpasswd -m sha-512 -s)

    # Generate local.nix
    cat > "$local_config" << EOF
# Local configuration - generated by install.sh
# Edit this file to change machine-specific settings
{
  username = "$USERNAME";
  fullName = "$USER_FULLNAME";
  hashedPassword = "$password_hash";
  hostname = "$HOSTNAME";
  gitUsername = "$GIT_USERNAME";
  gitEmail = "$GIT_EMAIL";
}
EOF

    log_success "local.nix generated"
}

# Partition disk
partition_disk() {
    log_info "Partitioning $DISK..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would partition $DISK"
        return
    fi

    # Wipe existing partitions
    wipefs -af "$DISK"
    sgdisk -Z "$DISK"

    # Create GPT partition table
    sgdisk -o "$DISK"

    # EFI partition (512MB)
    sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" "$DISK"

    # Swap partition (if requested)
    local part_num=2
    if [[ -n "$SWAP_SIZE" ]]; then
        sgdisk -n 2:0:+${SWAP_SIZE} -t 2:8200 -c 2:"swap" "$DISK"
        part_num=3
    fi

    # Root partition (remaining space)
    sgdisk -n ${part_num}:0:0 -t ${part_num}:8300 -c ${part_num}:"root" "$DISK"

    # Update kernel partition table
    partprobe "$DISK"
    sleep 2

    log_success "Disk partitioned"
}

# Get partition paths
get_partitions() {
    # Handle NVMe vs SATA naming
    if [[ "$DISK" == *"nvme"* ]]; then
        EFI_PART="${DISK}p1"
        if [[ -n "$SWAP_SIZE" ]]; then
            SWAP_PART="${DISK}p2"
            ROOT_PART="${DISK}p3"
        else
            ROOT_PART="${DISK}p2"
        fi
    else
        EFI_PART="${DISK}1"
        if [[ -n "$SWAP_SIZE" ]]; then
            SWAP_PART="${DISK}2"
            ROOT_PART="${DISK}3"
        else
            ROOT_PART="${DISK}2"
        fi
    fi
}

# Setup encryption
setup_encryption() {
    if [[ "$USE_ENCRYPTION" != true ]]; then
        return
    fi

    log_info "Setting up LUKS encryption..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would encrypt $ROOT_PART"
        return
    fi

    # Store original partition for hardware config
    LUKS_DEVICE="$ROOT_PART"

    # Encrypt root
    echo -n "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 \
        --cipher aes-xts-plain64 \
        --key-size 512 \
        --hash sha512 \
        --iter-time 5000 \
        "$ROOT_PART" -

    # Open encrypted partition
    echo -n "$LUKS_PASSWORD" | cryptsetup open "$ROOT_PART" cryptroot -
    ROOT_PART="/dev/mapper/cryptroot"

    log_success "Encryption configured"
}

# Format partitions
format_partitions() {
    log_info "Formatting partitions..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would format partitions"
        return
    fi

    # Format EFI
    mkfs.fat -F32 -n EFI "$EFI_PART"

    # Format swap
    if [[ -n "${SWAP_PART:-}" ]]; then
        mkswap -L swap "$SWAP_PART"
    fi

    # Format root
    mkfs.ext4 -L nixos "$ROOT_PART"

    log_success "Partitions formatted"
}

# Mount partitions
mount_partitions() {
    log_info "Mounting partitions..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would mount partitions"
        return
    fi

    mount "$ROOT_PART" /mnt
    mkdir -p /mnt/boot
    mount "$EFI_PART" /mnt/boot

    if [[ -n "${SWAP_PART:-}" ]]; then
        swapon "$SWAP_PART"
    fi

    log_success "Partitions mounted"
}

# Generate hardware configuration
generate_hardware_config() {
    log_info "Generating hardware configuration..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would generate hardware config"
        return
    fi

    # Generate to temp location
    nixos-generate-config --root /mnt

    # Copy to our flake's host directory
    cp /mnt/etc/nixos/hardware-configuration.nix "${SCRIPT_DIR}/hosts/framework/hardware-configuration.nix"

    # Add LUKS configuration if encrypted
    if [[ "$USE_ENCRYPTION" == true && -n "${LUKS_DEVICE:-}" ]]; then
        local luks_uuid
        luks_uuid=$(blkid -s UUID -o value "$LUKS_DEVICE")

        # Append LUKS config to hardware-configuration.nix
        cat >> "${SCRIPT_DIR}/hosts/framework/hardware-configuration.nix" << EOF

  # LUKS encryption
  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/${luks_uuid}";
      preLVM = true;
      allowDiscards = true;
    };
  };
EOF
    fi

    log_success "Hardware configuration generated"
}

# Run nixos-install
run_install() {
    log_info "Installing NixOS..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would run: nixos-install --flake ${SCRIPT_DIR}#framework --no-root-passwd"
        return
    fi

    # Copy flake to /mnt for installation
    mkdir -p /mnt/etc/nixos
    cp -r "${SCRIPT_DIR}"/* /mnt/etc/nixos/

    # Install
    nixos-install --flake "/mnt/etc/nixos#framework" --no-root-passwd

    log_success "NixOS installed!"
}

# Show completion message
show_completion() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${GREEN}  Installation Complete!${RESET}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  ${CYAN}Next steps:${RESET}"
    echo -e "    1. Reboot into your new system"
    echo -e "    2. Log in as ${WHITE}${USERNAME}${RESET}"
    echo -e "    3. To make changes, edit /etc/nixos/ and run:"
    echo -e "       ${WHITE}sudo nixos-rebuild switch --flake /etc/nixos#framework${RESET}"
    echo ""
    echo -e "  ${CYAN}Key bindings:${RESET}"
    echo -e "    ${WHITE}Super + Return${RESET}  - Open terminal"
    echo -e "    ${WHITE}Super + Space${RESET}   - Application launcher"
    echo -e "    ${WHITE}Super + Q${RESET}       - Close window"
    echo -e "    ${WHITE}Super + 1-9${RESET}     - Switch workspace"
    echo ""
    echo -e "  ${CYAN}Configuration:${RESET}"
    echo -e "    /etc/nixos/flake.nix"
    echo ""

    read -rp "Reboot now? [y/N]: " reboot_confirm
    if [[ "$reboot_confirm" =~ ^[Yy]$ ]]; then
        reboot
    fi
}

# Main
main() {
    print_banner
    parse_args "$@"
    check_root

    echo -e "${CYAN}Step 1: Disk Selection${RESET}"
    select_disk
    get_swap_size

    if [[ "$USE_ENCRYPTION" == true ]]; then
        get_encryption_password
    fi

    echo ""
    echo -e "${CYAN}Step 2: User Setup${RESET}"
    get_user_details
    get_git_identity

    echo ""
    echo -e "${CYAN}Step 3: Partitioning${RESET}"
    partition_disk
    get_partitions
    setup_encryption
    format_partitions
    mount_partitions

    echo ""
    echo -e "${CYAN}Step 4: Configuration${RESET}"
    configure_user
    generate_hardware_config

    echo ""
    echo -e "${CYAN}Step 5: Installation${RESET}"
    run_install

    show_completion
}

main "$@"
