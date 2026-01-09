# NixOS Framework 13 Configuration

Minimal NixOS configuration for Framework 13 AMD laptop with Hyprland and Nord theme.

## Components

| Component | Choice |
|-----------|--------|
| OS | NixOS unstable |
| Window Manager | Hyprland |
| Bar | Waybar |
| Launcher | Wofi |
| Notifications | Mako |
| Greeter | greetd + tuigreet |
| Terminal | Ghostty |
| Shell | Zsh + Starship |
| Editors | Neovim, Zed |
| Containers | Podman |
| Theme | Nord |

## Installation

### Option 1: Fresh Install

1. **Boot NixOS installer**
   - Download from https://nixos.org/download
   - Boot from USB

2. **Partition disk**
   ```bash
   # Example for NVMe drive with UEFI
   parted /dev/nvme0n1 -- mklabel gpt
   parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
   parted /dev/nvme0n1 -- set 1 esp on
   parted /dev/nvme0n1 -- mkpart primary linux-swap 512MB 24GB  # Adjust for your RAM
   parted /dev/nvme0n1 -- mkpart primary ext4 24GB 100%

   # Format
   mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
   mkswap -L swap /dev/nvme0n1p2
   mkfs.ext4 -L nixos /dev/nvme0n1p3

   # Mount
   mount /dev/disk/by-label/nixos /mnt
   mkdir -p /mnt/boot
   mount /dev/disk/by-label/BOOT /mnt/boot
   swapon /dev/disk/by-label/swap
   ```

3. **Generate hardware config**
   ```bash
   nixos-generate-config --root /mnt
   ```

4. **Clone this repository**
   ```bash
   nix-shell -p git
   cd /mnt/etc/nixos
   git clone https://github.com/YOUR_USERNAME/nixos-framework.git .
   ```

5. **Update hardware.nix**
   - Copy generated config from `/mnt/etc/nixos/hardware-configuration.nix`
   - Replace `hosts/framework/hardware.nix` content

6. **Update personal settings**
   - Edit `home/git.nix` - set your email
   - Edit `hosts/framework/default.nix` - adjust timezone if needed

7. **Install**
   ```bash
   nixos-install --flake /mnt/etc/nixos#framework
   ```

8. **Reboot and set password**
   ```bash
   reboot
   # After reboot, login as root and set user password:
   passwd scott
   ```

### Option 2: Existing NixOS Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/nixos-framework.git ~/nixos-framework
   cd ~/nixos-framework
   ```

2. **Copy your hardware config**
   ```bash
   cp /etc/nixos/hardware-configuration.nix hosts/framework/hardware.nix
   ```

3. **Update personal settings**
   - Edit `home/git.nix`
   - Adjust timezone in `hosts/framework/default.nix`

4. **Build and switch**
   ```bash
   sudo nixos-rebuild switch --flake .#framework
   ```

## Post-Installation

### Enroll Fingerprint
```bash
fprintd-enroll
fprintd-verify  # Test enrollment
```

### Update System
```bash
# Update flake inputs
nix flake update

# Rebuild
sudo nixos-rebuild switch --flake .#framework
```

### Key Commands
```bash
# Rebuild system
rebuild        # alias for nixos-rebuild switch

# Update flake
update         # alias for nix flake update

# Garbage collect
clean          # alias for nix-collect-garbage -d

# Search packages
search QUERY   # alias for nix search nixpkgs
```

## Keybindings

### Hyprland

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal |
| `Super + Space` | App launcher |
| `Super + Q` | Close window |
| `Super + V` | Toggle floating |
| `Super + F` | Fullscreen |
| `Super + E` | File manager |
| `Super + C` | Clipboard history |
| `Super + 1-0` | Switch workspace |
| `Super + Shift + 1-0` | Move to workspace |
| `Super + h/j/k/l` | Focus direction |
| `Super + Shift + h/j/k/l` | Move window |
| `Print` | Screenshot region |
| `Super + Print` | Screenshot full |

### Neovim

| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `Space + ff` | Find files |
| `Space + fg` | Live grep |
| `Space + e` | File tree |
| `Space + w` | Save |
| `Space + q` | Quit |
| `gd` | Go to definition |
| `K` | Hover docs |
| `Tab/Shift+Tab` | Cycle buffers |

## Troubleshooting

### Hibernate not working
1. Ensure swap is >= RAM size
2. Check `cat /sys/power/state` includes `disk`
3. Verify resume device in `hosts/framework/default.nix`

### Fingerprint issues
```bash
# Re-enroll
fprintd-delete $USER
fprintd-enroll
```

### Display scaling
Edit `home/hyprland.nix`:
```nix
monitor = [ "eDP-1, preferred, auto, 1.5" ];  # Adjust scale
```

### Power management
```bash
# Check current profile
powerprofilesctl get

# Set profile
powerprofilesctl set power-saver
powerprofilesctl set balanced
powerprofilesctl set performance
```

## File Structure

```
.
├── flake.nix              # Flake entry point
├── flake.lock             # Pinned dependencies
├── hosts/
│   └── framework/
│       ├── default.nix    # Host configuration
│       └── hardware.nix   # Hardware specifics
├── modules/
│   ├── desktop/
│   │   └── greetd.nix     # Display manager
│   └── hardware/
│       ├── framework-amd.nix
│       ├── fingerprint.nix
│       └── power.nix
└── home/
    ├── default.nix        # Home-manager entry
    ├── hyprland.nix
    ├── waybar.nix
    ├── wofi.nix
    ├── mako.nix
    ├── zsh.nix
    ├── ghostty.nix
    ├── neovim.nix
    ├── zed.nix
    ├── podman.nix
    ├── git.nix
    └── theme.nix
```

## Customization

### Add packages
Edit `hosts/framework/default.nix` for system packages or `home/default.nix` for user packages.

### Change theme
The Nord color palette is defined in `home/theme.nix`. Each component config applies these colors.

### Add new module
1. Create file in `modules/` or `home/`
2. Import in parent `default.nix`
3. Rebuild

## License

MIT
