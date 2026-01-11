# NixUp Installation Guide

This guide provides detailed instructions for installing NixOS on a Framework 13 laptop using this configuration.

## Prerequisites

- Framework 13 laptop (AMD or Intel)
- NixOS installation ISO (24.11 or later) - [Download here](https://nixos.org/download.html#nixos-iso)
- USB drive (4GB minimum) for installation media
- Internet connection (WiFi or Ethernet)
- At least 20GB free disk space
- UEFI boot mode enabled

## Preparation

### 1. Create Installation Media

**On Linux/macOS:**
```bash
# Find your USB device
lsblk  # or diskutil list on macOS

# Write ISO to USB (replace /dev/sdX with your USB device)
sudo dd if=nixos-minimal-24.11.iso of=/dev/sdX bs=4M status=progress
sync
```

**On Windows:**
Use [Rufus](https://rufus.ie/) or [balenaEtcher](https://www.balena.io/etcher/) to write the ISO to USB.

### 2. Boot from USB

1. Insert the USB drive
2. Power on the Framework laptop
3. Press `F12` during boot to access boot menu
4. Select the USB drive
5. Choose "NixOS Installer" from the boot menu

### 3. Connect to Internet

**WiFi:**
```bash
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
0
> set_network 0 ssid "YourNetworkName"
OK
> set_network 0 psk "YourPassword"
OK
> set_network 0 key_mgmt WPA-PSK
OK
> enable_network 0
OK
> quit
```

**Verify connection:**
```bash
ping -c 3 nixos.org
```

## Installation Methods

Choose one of the following methods:

### Method 1: Automated Installation (Recommended)

The automated installer handles partitioning, LUKS setup, and configuration generation.

```bash
# Clone the repository
nix-shell -p git
git clone https://github.com/sroberts/nixup.git
cd nixup

# Run the installer
sudo ./install.sh
```

The installer will prompt you for:
- Disk selection
- Swap size
- LUKS encryption password (optional)
- Username, full name, and password
- Hostname
- Git identity (optional)

After completion, reboot and remove the USB drive.

---

### Method 2: Manual Installation

For advanced users who want complete control over the installation process.

#### Step 1: Partition the Disk

Find your disk:
```bash
lsblk
```

For this guide, we'll assume `/dev/nvme0n1`. Adjust for your system.

**Create partitions:**
```bash
# Enter parted
sudo parted /dev/nvme0n1

# Create GPT partition table
(parted) mklabel gpt

# Create EFI partition (512MB)
(parted) mkpart ESP fat32 1MiB 513MiB
(parted) set 1 esp on

# Create swap partition (16GB - adjust based on RAM)
(parted) mkpart swap linux-swap 513MiB 16.5GiB

# Create root partition (remaining space)
(parted) mkpart root ext4 16.5GiB 100%

# Verify
(parted) print
(parted) quit
```

#### Step 2: Set Up LUKS Encryption (Optional)

**Skip this section if you don't want encryption.**

```bash
# Encrypt the root partition
sudo cryptsetup luksFormat --type luks2 /dev/nvme0n1p3

# Open the encrypted partition
sudo cryptsetup open /dev/nvme0n1p3 cryptroot
```

The root device will be at `/dev/mapper/cryptroot` if encrypted, or `/dev/nvme0n1p3` if not.

#### Step 3: Create Filesystems

**With encryption:**
```bash
sudo mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
sudo mkswap -L swap /dev/nvme0n1p2
sudo mkfs.ext4 -L root /dev/mapper/cryptroot
```

**Without encryption:**
```bash
sudo mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
sudo mkswap -L swap /dev/nvme0n1p2
sudo mkfs.ext4 -L root /dev/nvme0n1p3
```

#### Step 4: Mount Filesystems

**With encryption:**
```bash
sudo mount /dev/mapper/cryptroot /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo swapon /dev/nvme0n1p2
```

**Without encryption:**
```bash
sudo mount /dev/nvme0n1p3 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo swapon /dev/nvme0n1p2
```

#### Step 5: Generate Hardware Configuration

```bash
sudo nixos-generate-config --root /mnt
```

#### Step 6: Clone Repository

```bash
cd /mnt/etc/nixos
sudo rm -f configuration.nix
nix-shell -p git --run "sudo git clone https://github.com/sroberts/nixup.git ."
```

#### Step 7: Move Hardware Configuration

```bash
sudo mv /mnt/etc/nixos/hardware-configuration.nix hosts/framework/
```

#### Step 8: Create local.nix

Create your machine-specific configuration:

```bash
# Generate password hash
PASSWORD_HASH=$(mkpasswd -m sha-512)
# Enter your password when prompted

# Create local.nix
sudo nano hosts/framework/local.nix
```

Add the following content (replace with your details):

```nix
{
  username = "yourname";
  fullName = "Your Full Name";
  hostname = "framework";
  gitUsername = "yourgithubname";
  gitEmail = "your.email@example.com";
  hashedPassword = "PASTE_PASSWORD_HASH_HERE";
}
```

#### Step 9: Review Hardware Configuration

Edit the hardware configuration to ensure it matches your setup:

```bash
sudo nano hosts/framework/hardware-configuration.nix
```

**Important**: If you used LUKS encryption, verify the hardware config includes:

```nix
boot.initrd.luks.devices."cryptroot" = {
  device = "/dev/disk/by-uuid/YOUR-ROOT-PARTITION-UUID";
};
```

You can find the UUID with:
```bash
sudo blkid /dev/nvme0n1p3
```

#### Step 10: Install NixOS

```bash
sudo nixos-install --flake .#framework --no-root-passwd
```

This will take 30-60 minutes depending on your internet connection.

#### Step 11: Reboot

```bash
reboot
```

Remove the USB drive when prompted.

---

## Post-Installation

### First Boot

1. **LUKS Users**: Enter your LUKS password when prompted
2. **Login**: Use the username and password you configured
3. **Verify**: You should boot into Niri compositor with greetd

### Initial Configuration

```bash
# Update flake inputs
cd /etc/nixos
nix flake update

# Rebuild with updates
sudo nixos-rebuild switch --flake .#framework
```

### Install Additional Software

Edit `/etc/nixos/modules/nixos/applications.nix` to add system packages, or edit user-specific packages in `/etc/nixos/home/default.nix`.

After editing:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#framework
```

## Troubleshooting

### WiFi Not Working

```bash
# Check network manager
systemctl status NetworkManager

# Restart network manager
sudo systemctl restart NetworkManager

# Connect via nmcli
nmcli device wifi connect "SSID" password "PASSWORD"
```

### Niri Won't Start

Check logs:
```bash
journalctl -u greetd
journalctl --user -u niri
```

### Can't Boot (LUKS Issues)

Boot from USB and:
```bash
# Open encrypted partition
cryptsetup open /dev/nvme0n1p3 cryptroot

# Mount and chroot
mount /dev/mapper/cryptroot /mnt
mount /dev/nvme0n1p1 /mnt/boot
nixos-enter

# Fix configuration
nano /etc/nixos/hosts/framework/hardware-configuration.nix
nixos-rebuild switch --flake /etc/nixos#framework
```

### Display Issues

If Niri doesn't detect your display correctly, edit `/etc/nixos/home/niri.nix`:

```nix
output "eDP-1" {
    mode "2256x1504@60"
    scale 1.25
    position x=0 y=0
}
```

Find your display name with:
```bash
niri msg outputs
```

### Hibernate Not Working

Ensure your swap partition is large enough (equal to RAM size) and kernel parameters are correct in `/etc/nixos/hosts/framework/default.nix`:

```nix
boot.resumeDevice = "/dev/disk/by-label/swap";
boot.kernelParams = [ "resume=/dev/disk/by-label/swap" ];
```

## Next Steps

- Read the [README.md](README.md) for key bindings and usage
- Customize your configuration in `/etc/nixos`
- Join the [NixOS Discourse](https://discourse.nixos.org/) for help
- Check [Niri documentation](https://github.com/YaLTeR/niri) for compositor features

## Getting Help

- **NixOS**: https://nixos.org/manual/nixos/stable/
- **Niri**: https://github.com/YaLTeR/niri/wiki
- **Framework**: https://community.frame.work/
- **Issues**: https://github.com/sroberts/nixup/issues
