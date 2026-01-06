#!/usr/bin/env bash
# Power menu script for Niri using fuzzel
# Provides logout, suspend, reboot, and shutdown options

set -euo pipefail

# Define menu options
OPTIONS="Lock
Logout
Suspend
Reboot
Shutdown"

# Show menu and get selection
SELECTION=$(echo -e "$OPTIONS" | fuzzel --dmenu --prompt "Power: ")

# Handle selection
case "$SELECTION" in
    Lock)
        swaylock
        ;;
    Logout)
        niri msg action quit
        ;;
    Suspend)
        systemctl suspend
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    *)
        # User cancelled or invalid selection
        exit 0
        ;;
esac
