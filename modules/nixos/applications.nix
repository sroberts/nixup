# System-wide applications
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # ─────────────────────────────────────────────────────────────
    # Terminals
    # ─────────────────────────────────────────────────────────────
    ghostty
    alacritty
    foot

    # ─────────────────────────────────────────────────────────────
    # Editors
    # ─────────────────────────────────────────────────────────────
    neovim
    zed-editor

    # ─────────────────────────────────────────────────────────────
    # Browsers
    # ─────────────────────────────────────────────────────────────
    firefox
    chromium

    # ─────────────────────────────────────────────────────────────
    # File Management (TUI preferred)
    # ─────────────────────────────────────────────────────────────
    yazi
    nautilus
    file-roller

    # ─────────────────────────────────────────────────────────────
    # Development Tools
    # ─────────────────────────────────────────────────────────────
    git
    gh
    lazygit
    tig
    delta
    gitui

    # Docker
    docker-compose
    lazydocker

    # Kubernetes
    k9s

    # Version management
    mise

    # Languages
    python3
    python3Packages.pip
    uv
    nodejs
    nodePackages.npm
    nodePackages.pnpm
    go
    gopls
    rustup

    # Diagrams
    mermaid-cli

    # ─────────────────────────────────────────────────────────────
    # CLI Tools (modern replacements)
    # ─────────────────────────────────────────────────────────────
    eza          # ls replacement
    bat          # cat replacement
    ripgrep      # grep replacement
    fd           # find replacement
    fzf          # fuzzy finder
    zoxide       # cd replacement
    dust         # du replacement
    duf          # df replacement
    procs        # ps replacement
    btop         # top replacement
    ncdu         # disk usage TUI
    bandwhich    # bandwidth monitor
    glow         # markdown viewer
    jq           # JSON processor
    fx           # JSON TUI
    httpie       # HTTP client
    tldr         # man pages simplified
    tree
    unzip
    zip
    curl
    wget

    # ─────────────────────────────────────────────────────────────
    # Media
    # ─────────────────────────────────────────────────────────────
    ncspot       # Spotify TUI
    spotify
    mpv
    imv
    pavucontrol
    obs-studio

    # ─────────────────────────────────────────────────────────────
    # Communication
    # ─────────────────────────────────────────────────────────────
    signal-desktop
    discord
    zoom-us

    # ─────────────────────────────────────────────────────────────
    # Productivity
    # ─────────────────────────────────────────────────────────────
    libreoffice
    obsidian
    _1password-gui
    _1password-cli

    # ─────────────────────────────────────────────────────────────
    # System Utilities
    # ─────────────────────────────────────────────────────────────
    networkmanagerapplet
    blueman
    gnome-system-monitor
    gnome-disk-utility
  ];

  # Git configuration
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}
