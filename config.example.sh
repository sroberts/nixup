#!/usr/bin/env bash
# Example configuration file for nixup non-interactive installation
#
# Copy this file to config.sh and modify the values below
# Then run: ./install.sh --config config.sh
#

# Disk configuration
export DISK="/dev/nvme0n1"           # Target disk for installation
export USE_ENCRYPTION=true           # Enable LUKS encryption
export LUKS_PASSWORD="changeme"      # LUKS password (CHANGE THIS!)
export SWAP_SIZE="16G"               # Swap partition size (or "none")

# User configuration
export USERNAME="user"               # Your username
export USER_FULLNAME="User"          # Your full name
export USER_PASSWORD="changeme"      # User password (CHANGE THIS!)

# System configuration
export HOSTNAME="nixos"              # System hostname
export TIMEZONE="America/New_York"   # Your timezone
export LOCALE="en_US.UTF-8"          # System locale
export KEYBOARD_LAYOUT="us"          # Console keyboard layout

# Hardware overrides (usually auto-detected)
# export CPU_VENDOR="intel"          # intel or amd
# export GPU_VENDOR="intel"          # intel, amd, or nvidia
# export IS_LAPTOP=true              # true or false
# export IS_FRAMEWORK=true           # true or false (Framework laptop)
# export HAS_FINGERPRINT=true        # true or false
# export HAS_BLUETOOTH=true          # true or false
