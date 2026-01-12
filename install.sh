#!/usr/bin/env bash
#
# NixUp Installer for Framework 13 Laptops
# Automates NixOS installation with LUKS encryption and proper partitioning
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

prompt() {
    echo -e "${BLUE}[PROMPT]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root. Use: sudo ./install.sh"
fi

# Check if running in UEFI mode
if [ ! -d /sys/firmware/efi/efivars ]; then
    error "Not booted in UEFI mode. Please boot in UEFI mode."
fi

info "NixUp Installer - Framework 13 Edition"
echo ""
warn "This will ERASE the selected disk and install NixOS!"
echo ""

# Step 1: Disk Selection
prompt "Available disks:"
lsblk -d -n -o NAME,SIZE,MODEL | grep -v loop
echo ""
read -p "Enter disk to install to (e.g., nvme0n1, sda): " DISK
DISK="/dev/${DISK}"

if [ ! -b "$DISK" ]; then
    error "Disk $DISK not found!"
fi

info "Selected disk: $DISK"
lsblk "$DISK"
echo ""

read -p "This will ERASE all data on $DISK. Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    error "Installation cancelled."
fi

# Step 2: Swap Size
echo ""
prompt "Recommended swap size:"
echo "  - 8GB for hibernate (if RAM <= 8GB)"
echo "  - 16GB for hibernate (if RAM = 16GB)"
echo "  - 32GB for hibernate (if RAM = 32GB)"
echo "  - 4GB minimal (no hibernate support)"
read -p "Enter swap size in GB [16]: " SWAP_SIZE
SWAP_SIZE=${SWAP_SIZE:-16}
info "Swap size: ${SWAP_SIZE}GB"

# Step 3: LUKS Encryption
echo ""
read -p "Enable LUKS full-disk encryption? (yes/no) [yes]: " USE_LUKS
USE_LUKS=${USE_LUKS:-yes}

if [ "$USE_LUKS" = "yes" ]; then
    info "LUKS encryption will be enabled"
    echo ""
    prompt "Enter LUKS encryption password:"
    read -s LUKS_PASSWORD
    echo ""
    prompt "Confirm LUKS encryption password:"
    read -s LUKS_PASSWORD_CONFIRM
    echo ""

    if [ "$LUKS_PASSWORD" != "$LUKS_PASSWORD_CONFIRM" ]; then
        error "Passwords do not match!"
    fi

    if [ ${#LUKS_PASSWORD} -lt 8 ]; then
        error "Password must be at least 8 characters!"
    fi
else
    info "LUKS encryption will NOT be enabled"
fi

# Step 4: User Configuration
echo ""
info "User Configuration"
read -p "Enter username: " USERNAME
read -p "Enter full name: " FULLNAME
read -p "Enter hostname: " HOSTNAME

echo ""
prompt "Enter user password:"
read -s USER_PASSWORD
echo ""
prompt "Confirm user password:"
read -s USER_PASSWORD_CONFIRM
echo ""

if [ "$USER_PASSWORD" != "$USER_PASSWORD_CONFIRM" ]; then
    error "Passwords do not match!"
fi

# Step 5: Git Configuration (Optional)
echo ""
read -p "Configure Git identity? (yes/no) [yes]: " CONFIGURE_GIT
CONFIGURE_GIT=${CONFIGURE_GIT:-yes}

if [ "$CONFIGURE_GIT" = "yes" ]; then
    read -p "Enter Git username: " GIT_USERNAME
    read -p "Enter Git email: " GIT_EMAIL
else
    GIT_USERNAME="$USERNAME"
    GIT_EMAIL="${USERNAME}@${HOSTNAME}"
fi

# Step 6: Confirm Configuration
echo ""
info "Installation Summary:"
echo "  Disk: $DISK"
echo "  Swap: ${SWAP_SIZE}GB"
echo "  LUKS: $USE_LUKS"
echo "  Username: $USERNAME"
echo "  Full Name: $FULLNAME"
echo "  Hostname: $HOSTNAME"
echo "  Git: $GIT_USERNAME <$GIT_EMAIL>"
echo ""

read -p "Proceed with installation? (yes/no): " PROCEED
if [ "$PROCEED" != "yes" ]; then
    error "Installation cancelled."
fi

# Step 7: Partitioning
info "Creating partitions..."

# Cleanup any existing installations
info "Cleaning up any existing installations..."

# Unmount any existing mounts
umount -R /mnt 2>/dev/null || true

# Turn off swap if active
swapoff -a 2>/dev/null || true

# Close any open LUKS mappings
if [ -e /dev/mapper/cryptroot ]; then
    cryptsetup close cryptroot 2>/dev/null || true
fi

# Wipe disk
wipefs -af "$DISK"
sgdisk -Z "$DISK"

# Create GPT partition table and partitions
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:boot "$DISK"  # EFI
sgdisk -n 2:0:+${SWAP_SIZE}G -t 2:8200 -c 2:swap "$DISK"  # Swap
sgdisk -n 3:0:0 -t 3:8300 -c 3:root "$DISK"  # Root

# Get partition names
if [[ "$DISK" =~ "nvme" ]]; then
    BOOT_PART="${DISK}p1"
    SWAP_PART="${DISK}p2"
    ROOT_PART="${DISK}p3"
else
    BOOT_PART="${DISK}1"
    SWAP_PART="${DISK}2"
    ROOT_PART="${DISK}3"
fi

info "Partitions created:"
lsblk "$DISK"

# Step 8: LUKS Setup (if enabled)
if [ "$USE_LUKS" = "yes" ]; then
    info "Setting up LUKS encryption..."
    echo -n "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 "$ROOT_PART" -
    echo -n "$LUKS_PASSWORD" | cryptsetup open "$ROOT_PART" cryptroot -
    ROOT_DEVICE="/dev/mapper/cryptroot"
else
    ROOT_DEVICE="$ROOT_PART"
fi

# Step 9: Filesystem Creation
info "Creating filesystems..."

mkfs.fat -F 32 -n BOOT "$BOOT_PART"
mkswap -L swap "$SWAP_PART"
mkfs.ext4 -L root "$ROOT_DEVICE"

# Step 10: Mounting
info "Mounting filesystems..."

mount "$ROOT_DEVICE" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot
swapon "$SWAP_PART"

# Step 11: Hardware config will be generated after repo clone
info "Preparing for installation..."

# Step 12: Clone Repository
info "Cloning nixup repository..."

mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos
rm -f configuration.nix hardware-configuration.nix

nix-shell -p git --run "git clone https://github.com/sroberts/nixup.git ."

# Step 13: Create local.nix
info "Creating local configuration..."

# Generate password hash
USER_PASSWORD_HASH=$(echo -n "$USER_PASSWORD" | mkpasswd -m sha-512 -s)

cat > hosts/framework/local.nix << EOF
{
  username = "$USERNAME";
  fullName = "$FULLNAME";
  hostname = "$HOSTNAME";
  gitUsername = "$GIT_USERNAME";
  gitEmail = "$GIT_EMAIL";
  hashedPassword = "$USER_PASSWORD_HASH";
}
EOF

# Step 14: Generate hardware-configuration.nix with filesystem info
info "Generating hardware configuration..."

nixos-generate-config --root /mnt
mv /mnt/etc/nixos/hardware-configuration.nix hosts/framework/

# Step 15: Install NixOS
info "Installing NixOS..."
info "This may take 30-60 minutes depending on your internet connection..."

nixos-install --flake .#framework --no-root-passwd

# Step 16: Success
echo ""
info "Installation complete!"
echo ""
info "Next steps:"
echo "  1. Reboot: reboot"
echo "  2. Remove installation media"
if [ "$USE_LUKS" = "yes" ]; then
    echo "  3. Enter LUKS password at boot"
fi
echo "  4. Log in as: $USERNAME"
echo "  5. Your configuration is in: /etc/nixos"
echo ""
warn "Remember to update your flake inputs: nix flake update"
echo ""
