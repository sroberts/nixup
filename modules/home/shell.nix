# Shell configuration with Zsh and Starship
{ config, pkgs, lib, ... }:

{
  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

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
      nrs = "sudo nixos-rebuild switch --flake .#framework";
      nrt = "sudo nixos-rebuild test --flake .#framework";
      nrb = "sudo nixos-rebuild boot --flake .#framework";
      ncg = "sudo nix-collect-garbage -d";
      nse = "nix search nixpkgs";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "kubectl"
        "fzf"
        "history"
        "sudo"
      ];
    };

    initExtra = ''
      # Add ~/.local/bin to PATH for user scripts
      export PATH="$HOME/.local/bin:$PATH"

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
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$character"
      ];
      directory = {
        style = "blue bold";
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        symbol = " ";
        style = "purple";
      };
      git_status = {
        style = "red";
      };
      nix_shell = {
        symbol = " ";
        style = "cyan";
      };
      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };
    };
  };

  # FZF
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Bat (cat replacement)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  # Eza (ls replacement)
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  # Ripgrep
  programs.ripgrep = {
    enable = true;
  };

  # Btop
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
      theme_background = false;
    };
  };
}
