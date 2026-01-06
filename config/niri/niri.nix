# Niri Wayland compositor configuration for NixOS
{ config, pkgs, lib, ... }:

{
  # Enable Niri
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # Required services for Niri
  services = {
    # Display manager - greetd with tuigreet
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
          user = "greeter";
        };
      };
    };

    # GNOME Keyring for secrets
    gnome.gnome-keyring.enable = true;

    # GVfs for file manager integration
    gvfs.enable = true;

    # Thumbnail generation
    tumbler.enable = true;
  };

  # Niri-related environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
  };

  # Programs commonly used with Niri (apps in applications.nix)
  environment.systemPackages = with pkgs; [
    # Application launcher
    fuzzel

    # Status bar
    waybar

    # Notifications
    mako
    libnotify

    # Screen locking
    swaylock
    swayidle

    # Screenshots
    grim
    slurp
    swappy

    # Clipboard
    wl-clipboard
    cliphist

    # Wallpaper
    swaybg

    # Display management
    wlr-randr
    kanshi

    # Image viewer (lightweight for Wayland)
    imv

    # Brightness and audio control
    brightnessctl
    playerctl
    pamixer

    # Authentication agent
    polkit_gnome

    # Wayland utilities
    wev
    wtype

    # Theming
    qt5.qtwayland
    qt6.qtwayland
    adwaita-qt
    adwaita-icon-theme
    papirus-icon-theme
  ];

  # Qt theming
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita";
  };

  # Enable dconf for GNOME-based apps
  programs.dconf.enable = true;

  # Polkit authentication agent autostart
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
}
