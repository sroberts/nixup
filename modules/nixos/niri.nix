# Niri Wayland compositor configuration
{ config, pkgs, lib, inputs, ... }:

{
  # Enable Niri from the flake
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # Display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Screen locker
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
  };

  # Enable required services for Wayland desktop
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = { };

  # Environment variables for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Desktop utilities
  environment.systemPackages = with pkgs; [
    # Status bar
    waybar

    # Notifications
    mako
    libnotify

    # Launcher
    fuzzel

    # Screenshots
    grim
    slurp
    swappy

    # Clipboard
    wl-clipboard
    cliphist

    # Screen sharing
    xdg-desktop-portal-gtk

    # Brightness and audio control
    brightnessctl
    pamixer
    playerctl

    # Wallpaper
    swaybg

    # Idle daemon
    swayidle

    # Cursor theme
    adwaita-icon-theme
  ];

  # Theme settings
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
