# Shell configuration for NixOS
# Zsh with modern CLI tool aliases and starship prompt
{ config, pkgs, lib, ... }:

{
  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Shell aliases for modern CLI tools
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Modern replacements
      ls = "eza --icons --group-directories-first";
      ll = "eza -la --icons --group-directories-first";
      la = "eza -a --icons --group-directories-first";
      lt = "eza --tree --icons --level=2";
      tree = "eza --tree --icons";

      cat = "bat --paging=never";
      less = "bat";

      grep = "rg";
      find = "fd";
      du = "dust";
      df = "duf";
      ps = "procs";
      top = "btop";
      htop = "btop";

      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";
      lg = "lazygit";

      # Docker shortcuts
      d = "docker";
      dc = "docker compose";
      dps = "docker ps";
      lzd = "lazydocker";

      # Kubernetes
      k = "kubectl";
      kk = "k9s";

      # Safety nets
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # Misc
      c = "clear";
      e = "$EDITOR";
      v = "nvim";
      vim = "nvim";
      open = "xdg-open";
      ports = "ss -tulanp";
      myip = "curl -s https://ipinfo.io/ip";
      weather = "curl -s 'wttr.in?format=3'";

      # NixOS
      nrs = "sudo nixos-rebuild switch";
      nrt = "sudo nixos-rebuild test";
      nrb = "sudo nixos-rebuild boot";
      ncg = "sudo nix-collect-garbage -d";
      nse = "nix search nixpkgs";
    };

    # Oh-my-zsh configuration
    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "kubectl"
        "fzf"
        "zoxide"
        "history"
        "sudo"
      ];
    };

    # Additional zsh configuration
    interactiveShellInit = ''
      # Initialize zoxide
      eval "$(zoxide init zsh)"

      # FZF configuration
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

      # FZF Tokyo Night theme
      export FZF_DEFAULT_OPTS='
        --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
        --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
        --color=info:#9ece6a,prompt:#7aa2f7,pointer:#f7768e
        --color=marker:#e0af68,spinner:#bb9af7,header:#565f89
        --border --layout=reverse --height=40%
      '

      # Bat theme
      export BAT_THEME="TwoDark"

      # Better history
      HISTSIZE=50000
      SAVEHIST=50000
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE

      # Directory navigation
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS

      # Completion improvements
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      # Minimal, clean prompt
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$python"
        "$nodejs"
        "$golang"
        "$rust"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
        format = "[$all_status$ahead_behind]($style) ";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bold yellow";
        format = "[$duration]($style) ";
      };

      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = " ";
        style = "bold blue";
      };

      python = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "bold yellow";
      };

      nodejs = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "bold green";
      };

      golang = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "bold cyan";
      };

      rust = {
        format = "[$symbol$version]($style) ";
        symbol = " ";
        style = "bold red";
      };
    };
  };

  # Add starship to packages
  environment.systemPackages = with pkgs; [
    starship
  ];
}
