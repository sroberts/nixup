# This file is a placeholder. Replace with output from:
#   nixos-generate-config --show-hardware-config
#
# Run this on your Framework laptop during installation.
# The generated config will include disk/partition UUIDs, 
# kernel modules, and other hardware-specific settings.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Example - replace with actual generated config
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Filesystems - REPLACE THESE with your actual UUIDs
  # Run: blkid to get your UUIDs
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-UUID";
    fsType = "ext4";  # or btrfs, xfs, etc.
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-YOUR-UUID";
    fsType = "vfat";
  };

  # Swap - for hibernate support
  # Option 1: Swap partition (recommended for hibernate)
  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];

  # Option 2: Swap file (comment out above, uncomment below)
  # swapDevices = [{
  #   device = "/swapfile";
  #   size = 16384;  # MB - should be >= RAM for hibernate
  # }];

  # Enables DHCP on each ethernet and wireless interface
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
