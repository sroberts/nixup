# Applications configuration for NixOS
# Desktop applications, productivity tools, and user software
{ config, pkgs, lib, ... }:

{
  # Allow unfree packages (needed for many apps)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # ─────────────────────────────────────────────────────────────
    # Text Editors
    # ─────────────────────────────────────────────────────────────
    neovim           # Default editor (configure LazyVim via home config)
    zed-editor       # Modern collaborative editor

    # ─────────────────────────────────────────────────────────────
    # Terminals
    # ─────────────────────────────────────────────────────────────
    ghostty          # Default terminal (GPU-accelerated)
    alacritty        # Backup terminal
    foot             # Lightweight Wayland terminal

    # ─────────────────────────────────────────────────────────────
    # Browsers
    # ─────────────────────────────────────────────────────────────
    chromium

    # ─────────────────────────────────────────────────────────────
    # Communication
    # ─────────────────────────────────────────────────────────────
    signal-desktop   # Encrypted messaging
    discord          # Chat and voice
    zoom-us          # Video conferencing

    # ─────────────────────────────────────────────────────────────
    # Productivity
    # ─────────────────────────────────────────────────────────────
    # LibreOffice full suite
    libreoffice-fresh   # Writer, Calc, Impress, Draw, Base, Math

    obsidian         # Knowledge base / note-taking
    typora           # Markdown editor (commercial)
    _1password-gui   # Password manager
    _1password       # 1Password CLI

    # ─────────────────────────────────────────────────────────────
    # Media
    # ─────────────────────────────────────────────────────────────
    spotify          # Music streaming
    obs-studio       # Screen recording / streaming

    # ─────────────────────────────────────────────────────────────
    # Development Tools
    # ─────────────────────────────────────────────────────────────
    # Git
    git
    gh               # GitHub CLI
    lazygit          # Git TUI

    # Docker
    docker-compose   # Container orchestration
    lazydocker       # Docker TUI

    # Version management
    mise             # Multi-runtime version manager (replaces asdf)

    # Languages and runtimes
    python3
    python3Packages.pip
    uv               # Fast Python package manager
    nodejs
    nodePackages.npm
    nodePackages.pnpm
    go
    gopls            # Go language server

    # ─────────────────────────────────────────────────────────────
    # Modern CLI Tools
    # ─────────────────────────────────────────────────────────────
    fzf              # Fuzzy finder
    ripgrep          # Fast search (rg)
    zoxide           # Smart cd replacement
    eza              # Modern ls replacement
    bat              # Cat with syntax highlighting
    fd               # Fast find alternative
    jq               # JSON processor
    yq               # YAML processor
    tldr             # Simplified man pages
    delta            # Better git diff
    duf              # Better df
    dust             # Better du
    procs            # Better ps
    sd               # Better sed
    hyperfine        # Benchmarking tool
    tokei            # Code statistics
    bottom           # System monitor (btm)

    # ─────────────────────────────────────────────────────────────
    # Other Apps
    # ─────────────────────────────────────────────────────────────
    localsend        # Cross-platform file sharing
    gnome-calculator # Calculator
    gnome.gnome-calculator  # Fallback name
  ];

  # ─────────────────────────────────────────────────────────────
  # Docker
  # ─────────────────────────────────────────────────────────────
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # ─────────────────────────────────────────────────────────────
  # 1Password integration
  # ─────────────────────────────────────────────────────────────
  programs._1password = {
    enable = true;
  };
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ ]; # Will be populated with username
  };

  # ─────────────────────────────────────────────────────────────
  # Neovim as default editor
  # ─────────────────────────────────────────────────────────────
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # ─────────────────────────────────────────────────────────────
  # Git system configuration
  # ─────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}
