# Base NixOS system configuration
{ config, pkgs, lib, ... }:

{
  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Boot configuration
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "quiet" "splash" ];
    initrd.systemd.enable = true;
  };

  # Networking
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  # Sound with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # System services
  services = {
    # D-Bus
    dbus.enable = true;

    # Printing
    printing.enable = true;

    # SSH (disabled by default)
    openssh = {
      enable = false;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    # Automatic timezone
    automatic-timezoned.enable = true;
  };

  # Security
  security = {
    polkit.enable = true;
    pam.services.swaylock = { };
  };

  # XDG Portal (for Wayland screen sharing, etc.)
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # System packages (core utilities only - apps in applications.nix)
  environment.systemPackages = with pkgs; [
    # Essential tools
    wget
    curl
    htop
    btop
    tree
    unzip
    zip
    file
    which
    pciutils
    usbutils
    lshw

    # Build essentials
    gcc
    gnumake
    pkg-config

    # Networking
    networkmanagerapplet

    # File management
    xdg-utils
    xdg-user-dirs
  ];

  # Shell
  programs.zsh.enable = true;

  # System state version (DO NOT CHANGE after installation)
  system.stateVersion = "24.11";
}
