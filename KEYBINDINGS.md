# Niri Keybindings

All keybindings use **Super** (Windows key) as the modifier.

## Applications

| Key | Action |
|-----|--------|
| `Super + Space` | Application launcher (Fuzzel) |
| `Super + Return` | Terminal (Ghostty) |
| `Super + Shift + Return` | Alternate terminal (Alacritty) |
| `Super + E` | File manager TUI (Yazi) |
| `Super + Shift + E` | File manager GUI (PCManFM) |
| `Super + L` | Lock screen |
| `Super + Escape` | Power menu (logout/suspend/reboot/shutdown) |

## Windows

| Key | Action |
|-----|--------|
| `Super + Q` | Close window |
| `Super + F` | Maximize column |
| `Super + Shift + F` | Fullscreen window |
| `Super + C` | Consume window into column |
| `Super + X` | Expel window from column |
| `Super + Ctrl + C` | Center column |

## Focus Navigation

| Key | Action |
|-----|--------|
| `Super + Left` | Focus column left |
| `Super + Right` | Focus column right |
| `Super + Up` | Focus window up |
| `Super + Down` | Focus window down |
| `Super + H` | Focus column left (vim) |
| `Super + J` | Focus window down (vim) |
| `Super + K` | Focus window up (vim) |
| `Super + ;` | Focus column right (vim) |

## Move Windows

| Key | Action |
|-----|--------|
| `Super + Shift + Left` | Move column left |
| `Super + Shift + Right` | Move column right |
| `Super + Shift + Up` | Move window up |
| `Super + Shift + Down` | Move window down |
| `Super + Shift + H` | Move column left (vim) |
| `Super + Shift + J` | Move window down (vim) |
| `Super + Shift + K` | Move window up (vim) |
| `Super + Shift + ;` | Move column right (vim) |

## Workspaces

| Key | Action |
|-----|--------|
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + Shift + 1-9` | Move window to workspace 1-9 |
| `Super + Page Up` | Previous workspace |
| `Super + Page Down` | Next workspace |
| `Super + Shift + Page Up` | Move window to previous workspace |
| `Super + Shift + Page Down` | Move window to next workspace |
| `Super + Scroll Up` | Previous workspace (mouse) |
| `Super + Scroll Down` | Next workspace (mouse) |

## Window Sizing

| Key | Action |
|-----|--------|
| `Super + R` | Cycle preset column widths (33% / 50% / 66% / 100%) |
| `Super + -` | Decrease column width by 10% |
| `Super + =` | Increase column width by 10% |
| `Super + Shift + -` | Decrease window height by 10% |
| `Super + Shift + =` | Increase window height by 10% |

## Screenshots

| Key | Action |
|-----|--------|
| `Print` | Screenshot (select region) |
| `Super + Print` | Screenshot current screen |
| `Super + Shift + Print` | Screenshot current window |

Screenshots are saved to `~/Pictures/Screenshots/`

## Media Keys

These work even when the screen is locked.

| Key | Action |
|-----|--------|
| `Volume Up` | Increase volume 5% |
| `Volume Down` | Decrease volume 5% |
| `Mute` | Toggle mute |
| `Mic Mute` | Toggle microphone mute |
| `Brightness Up` | Increase brightness 5% |
| `Brightness Down` | Decrease brightness 5% |
| `Play/Pause` | Toggle media playback |
| `Next` | Next track |
| `Previous` | Previous track |

## Session

| Key | Action |
|-----|--------|
| `Super + L` | Lock screen |
| `Super + Escape` | Power menu |
| `Super + Shift + Q` | Exit Niri |

## Niri Concepts

### Columns
Niri uses a scrolling layout where windows are organized into **columns**. Each column can contain one or more windows stacked vertically.

- `Super + C` merges the focused window into the column to the left
- `Super + X` splits the focused window into its own column

### Preset Widths
Press `Super + R` to cycle through preset column widths:
- 33% (one-third)
- 50% (half)
- 66% (two-thirds)
- 100% (full width)

## Customization

Edit `~/.config/niri/config.kdl` to customize keybindings.

See the [Niri Wiki](https://github.com/YaLTeR/niri/wiki/Configuration) for full documentation.
