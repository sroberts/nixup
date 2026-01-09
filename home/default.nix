{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./wofi.nix
    ./mako.nix
    ./zsh.nix
    ./ghostty.nix
    ./neovim.nix
    ./zed.nix
    ./podman.nix
    ./git.nix
    ./theme.nix
  ];

  home.username = "scott";
  home.homeDirectory = "/home/scott";

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

  # Cursor theme
  home.pointerCursor = {
    name = "Nordzy-cursors";
    package = pkgs.nordzy-cursor-theme;
    size = 24;
    gtk.enable = true;
  };

  # GTK theming
  gtk = {
    enable = true;
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
    iconTheme = {
      name = "Nordzy";
      package = pkgs.nordzy-icon-theme;
    };
  };

  # Qt theming
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "gtk2";
  };

  # This value determines the Home Manager release
  home.stateVersion = "24.05";
}
