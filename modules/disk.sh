#!/usr/bin/env bash
# Disk partitioning module for nixup installer
# Supports UEFI with GPT partitioning and LUKS encryption

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

# shellcheck source=../lib/logging.sh
source "${LIB_DIR}/logging.sh"
# shellcheck source=../lib/prompts.sh
source "${LIB_DIR}/prompts.sh"
# shellcheck source=../lib/utils.sh
source "${LIB_DIR}/utils.sh"

# Configuration variables (set by configure_disk)
export DISK=""
export USE_ENCRYPTION=false
export LUKS_PASSWORD=""
export SWAP_SIZE=""
export EFI_PART=""
export ROOT_PART=""
export SWAP_PART=""

# Show available disks and let user select one
select_disk() {
    log_info "Detecting available disks..."

    local disks=()
    while IFS= read -r line; do
        disks+=("$line")
    done < <(lsblk -dno NAME,SIZE,TYPE | grep disk | awk '{print "/dev/" $1 " (" $2 ")"}')

    if [[ ${#disks[@]} -eq 0 ]]; then
        log_fatal "No disks found!"
    fi

    log_info "Available disks:"
    DISK=$(select_option "Select installation disk" "${disks[@]}")
    DISK="${DISK%% *}"  # Extract just the device path

    log_info "Selected disk: $DISK"

    # Warn if disk has existing partitions
    if disk_has_partitions "$DISK"; then
        log_warn "Disk $DISK has existing partitions!"
        if ! confirm "All data on $DISK will be DESTROYED. Continue?" "n"; then
            log_fatal "Installation cancelled by user"
        fi
    fi
}

# Configure disk options
configure_disk() {
    # Ask about encryption
    if confirm "Enable LUKS disk encryption?" "y"; then
        USE_ENCRYPTION=true
        ask_password_confirm "LUKS encryption password" LUKS_PASSWORD
    fi

    # Calculate swap size
    local ram_gb
    ram_gb=$(get_ram_gb)
    local default_swap="${ram_gb}G"

    log_info "System has ${ram_gb}GB RAM"
    ask "Swap partition size (e.g., 8G, 16G, or 'none')" "$default_swap" SWAP_SIZE

    if [[ "$SWAP_SIZE" == "none" ]]; then
        SWAP_SIZE=""
    fi
}

# Partition the disk
# Layout:
#   - EFI System Partition: 512MB
#   - Swap partition (optional): user-specified
#   - Root partition: remaining space
partition_disk() {
    log_info "Partitioning disk $DISK..."

    # Wipe existing partition table
    run "Wiping partition table" wipefs -af "$DISK"
    run "Creating new GPT partition table" sgdisk -Z "$DISK"

    local part_num=1

    # EFI partition (512MB)
    run "Creating EFI partition" sgdisk -n "${part_num}:0:+512M" -t "${part_num}:ef00" -c "${part_num}:EFI" "$DISK"
    EFI_PART="${DISK}p${part_num}"
    # Handle non-NVMe naming
    if [[ ! -e "$EFI_PART" ]]; then
        EFI_PART="${DISK}${part_num}"
    fi
    ((part_num++))

    # Swap partition (optional)
    if [[ -n "$SWAP_SIZE" ]]; then
        run "Creating swap partition" sgdisk -n "${part_num}:0:+${SWAP_SIZE}" -t "${part_num}:8200" -c "${part_num}:SWAP" "$DISK"
        SWAP_PART="${DISK}p${part_num}"
        if [[ ! -e "$SWAP_PART" ]]; then
            SWAP_PART="${DISK}${part_num}"
        fi
        ((part_num++))
    fi

    # Root partition (remaining space)
    run "Creating root partition" sgdisk -n "${part_num}:0:0" -t "${part_num}:8300" -c "${part_num}:ROOT" "$DISK"
    ROOT_PART="${DISK}p${part_num}"
    if [[ ! -e "$ROOT_PART" ]]; then
        ROOT_PART="${DISK}${part_num}"
    fi

    # Notify kernel of partition changes
    run "Updating kernel partition table" partprobe "$DISK"
    sleep 2  # Give the kernel time to recognize partitions

    log_success "Disk partitioning complete"
}

# Setup LUKS encryption
setup_encryption() {
    if [[ "$USE_ENCRYPTION" != true ]]; then
        return 0
    fi

    log_info "Setting up LUKS encryption..."

    # Encrypt root partition
    echo -n "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 \
        --cipher aes-xts-plain64 \
        --key-size 512 \
        --hash sha512 \
        --iter-time 5000 \
        --use-urandom \
        "$ROOT_PART" -

    # Open encrypted partition
    echo -n "$LUKS_PASSWORD" | cryptsetup open "$ROOT_PART" cryptroot -

    # Update ROOT_PART to point to mapper device
    ROOT_PART="/dev/mapper/cryptroot"

    # Encrypt swap if present
    if [[ -n "$SWAP_PART" ]]; then
        echo -n "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 \
            --cipher aes-xts-plain64 \
            --key-size 512 \
            "$SWAP_PART" -

        echo -n "$LUKS_PASSWORD" | cryptsetup open "$SWAP_PART" cryptswap -
        SWAP_PART="/dev/mapper/cryptswap"
    fi

    log_success "LUKS encryption configured"
}

# Format partitions
format_partitions() {
    log_info "Formatting partitions..."

    # Format EFI partition
    run "Formatting EFI partition" mkfs.fat -F32 -n EFI "$EFI_PART"

    # Format root partition
    run "Formatting root partition" mkfs.ext4 -L nixos "$ROOT_PART"

    # Format swap if present
    if [[ -n "$SWAP_PART" ]]; then
        run "Formatting swap partition" mkswap -L swap "$SWAP_PART"
    fi

    log_success "Partition formatting complete"
}

# Mount partitions for installation
mount_partitions() {
    log_info "Mounting partitions..."

    # Mount root
    run "Mounting root partition" mount "$ROOT_PART" /mnt

    # Create and mount EFI
    ensure_dir /mnt/boot
    run "Mounting EFI partition" mount "$EFI_PART" /mnt/boot

    # Enable swap
    if [[ -n "$SWAP_PART" ]]; then
        run "Enabling swap" swapon "$SWAP_PART"
    fi

    log_success "Partitions mounted"
}

# Get encryption configuration for NixOS
get_luks_config() {
    if [[ "$USE_ENCRYPTION" != true ]]; then
        return 0
    fi

    local root_uuid
    # Get the UUID of the encrypted partition (before opening)
    root_uuid=$(blkid -s UUID -o value "${ROOT_PART%cryptroot}p"* 2>/dev/null | head -1)

    cat << EOF
  # LUKS encryption
  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/${root_uuid}";
      preLVM = true;
      allowDiscards = true;
    };
  };
EOF
}

# Main disk setup function
setup_disk() {
    log_step "1" "Disk Configuration"

    require_root

    if ! is_efi; then
        log_fatal "This installer requires UEFI. Legacy BIOS is not supported."
    fi

    select_disk
    configure_disk
    partition_disk
    setup_encryption
    format_partitions
    mount_partitions

    log_success "Disk setup complete!"
}

# Export functions for use by other modules
export -f select_disk configure_disk partition_disk setup_encryption format_partitions mount_partitions get_luks_config setup_disk
