{ config, lib, pkgs, ... }:

{
  # Disable other display managers
  services.xserver.displayManager.gdm.enable = false;
  services.displayManager.sddm.enable = false;

  # Enable greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Suppress greetd error messages on TTY
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Environment variables for greetd
  environment.etc."greetd/environments".text = ''
    Hyprland
    zsh
  '';
}
