# nixup

A modular, maintainable NixOS installation script optimized for Framework 13 laptops with the Niri Wayland compositor.

## Features

- **Modular Design**: Separated into libraries and modules for easy maintenance and customization
- **Framework 13 Support**: Hardware-specific optimizations including TLP, firmware updates, and sensor support
- **Niri Wayland Compositor**: Modern, scrollable tiling Wayland compositor pre-configured with sensible defaults
- **LUKS Encryption**: Optional full-disk encryption with LUKS2
- **Hardware Detection**: Automatic detection of CPU, GPU, laptop features, fingerprint readers, and Bluetooth
- **Interactive & Non-Interactive**: Run interactively or provide a config file for automated installations

## Project Structure

```
nixup/
├── install.sh              # Main installation script
├── config.example.sh       # Example configuration for non-interactive install
├── lib/                    # Shell libraries
│   ├── colors.sh           # Terminal color definitions
│   ├── logging.sh          # Logging utilities
│   ├── prompts.sh          # User input prompts
│   └── utils.sh            # General utilities
├── modules/                # Installation modules
│   ├── disk.sh             # Disk partitioning and encryption
│   ├── user.sh             # User configuration
│   ├── hardware.sh         # Hardware detection
│   └── nixos-config.sh     # NixOS configuration generator
└── config/                 # NixOS configuration templates
    ├── system/
    │   └── base.nix        # Base system configuration
    ├── niri/
    │   └── niri.nix        # Niri compositor configuration
    └── home/
        └── niri-config.nix # User-level Niri configuration
```

## Requirements

- NixOS installation ISO (24.11 or later recommended)
- UEFI boot mode
- Internet connection
- At least 20GB disk space

## Quick Start

1. Boot from the NixOS installation ISO
2. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/nixup.git
   cd nixup
   ```
3. Run the installer:
   ```bash
   sudo ./install.sh
   ```
4. Follow the interactive prompts
5. Reboot into your new system

## Usage

### Interactive Installation

```bash
sudo ./install.sh
```

The installer will guide you through:
1. Disk selection and partitioning
2. Optional LUKS encryption setup
3. User account creation
4. System configuration (hostname, timezone, locale)
5. Hardware detection
6. NixOS installation

### Non-Interactive Installation

1. Copy the example config:
   ```bash
   cp config.example.sh config.sh
   ```
2. Edit `config.sh` with your settings
3. Run with the config file:
   ```bash
   sudo ./install.sh --config config.sh
   ```

### Command Line Options

| Option | Description |
|--------|-------------|
| `--help` | Show help message |
| `--dry-run` | Show what would be done without making changes |
| `--skip-disk` | Skip disk partitioning (use existing mounts) |
| `--config FILE` | Use config file for non-interactive installation |

## Default Key Bindings (Niri)

| Key | Action |
|-----|--------|
| `Super + Return` | Open terminal (Ghostty) |
| `Super + Space` | Open application launcher (Fuzzel) |
| `Super + E` | Open file manager |
| `Super + Q` | Close window |
| `Super + L` | Lock screen |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + Arrow Keys` | Focus navigation |
| `Super + Shift + Arrow Keys` | Move windows |
| `Super + F` | Maximize column |
| `Super + Shift + F` | Fullscreen window |
| `Super + R` | Cycle column width presets |
| `Print` | Screenshot |
| `Super + Shift + Q` | Exit Niri |

## Included Software

### Desktop Environment
- **Niri** - Scrollable tiling Wayland compositor
- **Waybar** - Status bar
- **Fuzzel** - Application launcher
- **Mako** - Notification daemon
- **Swaylock** - Screen locker

### Terminals & Editors
- **Ghostty** - GPU-accelerated terminal (default)
- **Alacritty/Foot** - Alternate terminals
- **Neovim** - Default editor (with LazyVim-ready config)
- **Zed** - Modern collaborative editor

### Browsers & Communication
- **Chromium** - Web browser
- **Signal** - Encrypted messaging
- **Discord** - Chat and voice
- **Zoom** - Video conferencing

### Productivity
- **LibreOffice** - Full office suite
- **Obsidian** - Knowledge base / notes
- **Typora** - Markdown editor
- **1Password** - Password manager

### Media
- **Spotify** - Music streaming
- **OBS Studio** - Screen recording / streaming
- **mpv** - Media player

### Development
- **Docker** with Compose and Lazydocker TUI
- **Git** with GitHub CLI and Lazygit
- **Mise** - Multi-runtime version manager
- **Python, Node.js, Go** with UV package manager

### Modern CLI Tools
- **fzf** - Fuzzy finder
- **ripgrep** - Fast search (rg)
- **zoxide** - Smart cd replacement
- **eza** - Modern ls replacement
- **bat** - Cat with syntax highlighting
- **btop/htop** - System monitors
- **delta** - Better git diff

### Other
- **LocalSend** - Cross-platform file sharing
- **Calculator** - GNOME calculator

## Customization

### Post-Installation Configuration

The NixOS configuration is located at `/etc/nixos/`:
- `configuration.nix` - Main system configuration
- `hardware-configuration.nix` - Auto-generated hardware config
- `modules/` - Modular configurations

To modify and rebuild:
```bash
sudo nixos-rebuild switch
```

### Niri Configuration

User Niri config is at `~/.config/niri/config.kdl`. See the [Niri Wiki](https://github.com/YaLTeR/niri/wiki/Configuration) for documentation.

### Waybar Configuration

Waybar config files are at:
- `~/.config/waybar/config` - Module configuration
- `~/.config/waybar/style.css` - Styling

## Framework 13 Specific Features

When a Framework laptop is detected, the installer enables:
- **TLP** for advanced power management
- **fwupd** for firmware updates
- **Framework kernel module** for hardware support
- **Ambient light sensor** support
- Optimized CPU scaling governors for AC/battery

## Troubleshooting

### Installation Logs
Logs are saved to `/tmp/nixup-install.log`

### Common Issues

**"Not running in NixOS installer environment"**
- Make sure you're booted from the NixOS installation ISO

**"UEFI required"**
- This installer only supports UEFI boot mode
- Check your BIOS/firmware settings

**Network not working after install**
- Ensure NetworkManager is enabled
- Run `nmtui` to configure connections

**Display issues with Niri**
- Check GPU drivers in `/etc/nixos/modules/hardware-custom.nix`
- For HiDPI displays, edit `~/.config/niri/config.kdl` output settings

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is open source. See individual files for specific licensing.

## Acknowledgments

- [NixOS](https://nixos.org/) - The reproducible Linux distribution
- [Niri](https://github.com/YaLTeR/niri) - A scrollable-tiling Wayland compositor
- [Framework](https://frame.work/) - Repairable, upgradeable laptops
