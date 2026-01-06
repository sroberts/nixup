# Applications configuration for NixOS
# Desktop applications, productivity tools, and user software
# Preference: TUI > GUI when practical
{ config, pkgs, lib, ... }:

{
  # Allow unfree packages (needed for many apps)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # ─────────────────────────────────────────────────────────────
    # Text Editors
    # ─────────────────────────────────────────────────────────────
    neovim           # Default editor (configure LazyVim via home config)
    zed-editor       # Modern collaborative GUI editor

    # ─────────────────────────────────────────────────────────────
    # Terminals
    # ─────────────────────────────────────────────────────────────
    ghostty          # Default terminal (GPU-accelerated)
    alacritty        # Backup terminal
    foot             # Lightweight Wayland terminal

    # ─────────────────────────────────────────────────────────────
    # File Managers
    # ─────────────────────────────────────────────────────────────
    yazi             # TUI file manager (default)
    xdragon          # Drag-and-drop for yazi
    ffmpegthumbnailer # Video thumbnails for yazi
    unar             # Archive extraction for yazi
    poppler          # PDF previews for yazi
    # GUI fallbacks
    pcmanfm          # GUI file manager
    gnome.nautilus   # GNOME file manager

    # ─────────────────────────────────────────────────────────────
    # Browsers
    # ─────────────────────────────────────────────────────────────
    firefox          # Primary browser (best Wayland support)
    chromium         # Alternative browser

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
    _1password-gui   # Password manager GUI
    _1password       # 1Password CLI

    # ─────────────────────────────────────────────────────────────
    # Media
    # ─────────────────────────────────────────────────────────────
    # TUI
    ncspot           # TUI Spotify client (default)
    spotify          # GUI Spotify (fallback)

    # Media players
    mpv              # Video player
    loupe            # Image viewer (GNOME)

    # Audio
    pavucontrol      # PulseAudio volume control
    obs-studio       # Screen recording / streaming

    # ─────────────────────────────────────────────────────────────
    # Development Tools
    # ─────────────────────────────────────────────────────────────
    # Git (TUI preferred)
    git
    gh               # GitHub CLI
    lazygit          # Git TUI (default)
    tig              # Git TUI viewer

    # Docker (TUI preferred)
    docker-compose   # Container orchestration
    lazydocker       # Docker TUI (default)

    # Kubernetes (TUI)
    k9s              # Kubernetes TUI

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

    # Documentation / Diagrams
    mermaid-cli      # Generate diagrams from text (mmdc)

    # ─────────────────────────────────────────────────────────────
    # Modern CLI / TUI Tools
    # ─────────────────────────────────────────────────────────────
    # File operations
    fzf              # Fuzzy finder
    ripgrep          # Fast search (rg)
    fd               # Fast find alternative
    zoxide           # Smart cd replacement
    eza              # Modern ls replacement
    bat              # Cat with syntax highlighting
    sd               # Better sed

    # Data processing
    jq               # JSON processor
    yq               # YAML processor
    xsv              # CSV toolkit
    fx               # JSON viewer TUI

    # System monitoring (TUI)
    btop             # System monitor TUI (default)
    htop             # Process viewer TUI
    bottom           # System monitor (btm)
    procs            # Better ps
    bandwhich        # Network utilization TUI
    duf              # Better df
    dust             # Better du
    ncdu             # Disk usage TUI

    # Network tools (TUI)
    trippy           # Network diagnostics TUI
    dogdns           # DNS client

    # Documentation
    tldr             # Simplified man pages
    glow             # Markdown viewer TUI

    # Git enhancements
    delta            # Better git diff
    gitui            # Git TUI (alternative to lazygit)

    # Misc tools
    hyperfine        # Benchmarking tool
    tokei            # Code statistics
    onefetch         # Git repo info (like neofetch for repos)

    # ─────────────────────────────────────────────────────────────
    # Other Apps
    # ─────────────────────────────────────────────────────────────
    localsend        # Cross-platform file sharing
    qalculate-gtk    # Calculator (powerful)
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

  # ─────────────────────────────────────────────────────────────
  # Yazi file manager
  # ─────────────────────────────────────────────────────────────
  programs.yazi = {
    enable = true;
  };
}
