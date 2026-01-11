{ config, pkgs, inputs, local, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/hardware/framework-amd.nix
    ../../modules/hardware/fingerprint.nix
    ../../modules/hardware/power.nix
    # greetd is configured in modules/nixos/niri.nix
    ../../modules/nixos/applications.nix
    ../../modules/nixos/framework.nix
    ../../modules/nixos/niri.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Hibernate support
  boot.resumeDevice = "/dev/disk/by-label/swap"; # Adjust to your swap partition
  boot.kernelParams = [ "resume=/dev/disk/by-label/swap" ];

  # Networking
  networking.hostName = local.hostname;
  networking.networkmanager.enable = true;

  # Time zone - adjust as needed
  time.timeZone = "America/New_York";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # User account
  users.users.${local.username} = {
    isNormalUser = true;
    description = local.fullName;
    hashedPassword = local.hashedPassword;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.zsh;
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Podman (rootless containers)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.enable = true;

  # Bluetooth is configured in modules/nixos/framework.nix

  # Additional system packages (most packages are in modules/nixos/applications.nix)
  environment.systemPackages = with pkgs; [
    polkit_gnome
  ];

  # Polkit for GUI authentication
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
      inter
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.05";
}
