#!/usr/bin/env bash
# Download and set a default wallpaper
# Run this after installation to set up a wallpaper

set -euo pipefail

WALLPAPER_DIR="${HOME}/.config"
WALLPAPER_PATH="${WALLPAPER_DIR}/wallpaper.jpg"

# Default wallpaper URL (Tokyo Night themed)
# Using a public domain / CC0 dark abstract wallpaper
DEFAULT_URL="https://images.unsplash.com/photo-1519681393784-d120267933ba?w=3840&q=80"

echo "Setting up wallpaper..."

# Create directory if needed
mkdir -p "$WALLPAPER_DIR"

if [[ -f "$WALLPAPER_PATH" ]]; then
    echo "Wallpaper already exists at $WALLPAPER_PATH"
    read -p "Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing wallpaper."
        exit 0
    fi
fi

echo "Downloading wallpaper..."
if curl -L -o "$WALLPAPER_PATH" "$DEFAULT_URL"; then
    echo "Wallpaper saved to $WALLPAPER_PATH"
    echo ""
    echo "To apply, restart Niri or run:"
    echo "  pkill swaybg; swaybg -m fill -i ~/.config/wallpaper.jpg &"
else
    echo "Failed to download wallpaper."
    echo ""
    echo "You can manually set a wallpaper by placing an image at:"
    echo "  ~/.config/wallpaper.jpg"
    exit 1
fi
