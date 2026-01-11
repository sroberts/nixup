{ config, pkgs, inputs, local, ... }:

{
  imports = [
    ./niri.nix
    ./waybar.nix
    ./mako.nix
    ./zsh.nix
    ./ghostty.nix
    ./neovim.nix
    ./zed.nix
    ./podman.nix
    ./git.nix
    ./theme.nix
  ];

  home.username = local.username;
  home.homeDirectory = "/home/${local.username}";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # User packages
  home.packages = with pkgs; [
    # CLI tools
    lazygit
    neofetch
    tree
    tldr
    trash-cli
    zoxide
    direnv

    # Development
    nodejs_22
    python3
    rustup
    go

    # Media
    imv        # Image viewer
    mpv        # Video player
    pavucontrol

    # Utilities
    gnome-calculator
    gnome-disk-utility
  ];

  # XDG directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  # Cursor theme, GTK theming, and Qt theming are configured in theme.nix

  # This value determines the Home Manager release
  home.stateVersion = "24.05";
}
