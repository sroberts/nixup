{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Modern replacements
      ls = "eza --icons --group-directories-first";
      ll = "eza -la --icons --group-directories-first";
      lt = "eza --tree --icons --level=2";
      cat = "bat";
      grep = "rg";
      find = "fd";

      # Git
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      gd = "git diff";
      lg = "lazygit";

      # NixOS
      rebuild = "sudo nixos-rebuild switch --flake .#framework";
      update = "nix flake update";
      clean = "sudo nix-collect-garbage -d";
      search = "nix search nixpkgs";

      # Podman (docker-like)
      docker = "podman";
      dc = "podman-compose";

      # Safety
      rm = "trash-put";
      cp = "cp -iv";
      mv = "mv -iv";

      # Misc
      v = "nvim";
      c = "clear";
    };

    initExtra = ''
      # Better history search with up/down arrows
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward

      # Ctrl+arrows for word navigation
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

      # Initialize zoxide
      eval "$(zoxide init zsh)"

      # Initialize direnv
      eval "$(direnv hook zsh)"

      # FZF keybindings
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # FZF Nord colors
      export FZF_DEFAULT_OPTS="
        --color=bg+:#3b4252,bg:#2e3440,spinner:#81a1c1,hl:#88c0d0
        --color=fg:#d8dee9,header:#88c0d0,info:#5e81ac,pointer:#81a1c1
        --color=marker:#81a1c1,fg+:#d8dee9,prompt:#81a1c1,hl+:#88c0d0
        --layout=reverse --border --height=40%
      "

      # Better defaults
      export EDITOR="nvim"
      export VISUAL="nvim"
      export PAGER="bat"

      # Man pages with bat
      export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    '';

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      format = ''
        [](#3b4252)$os$username[](bg:#434c5e fg:#3b4252)$directory[](fg:#434c5e bg:#4c566a)$git_branch$git_status[](fg:#4c566a bg:#86BBD8)$c$elixir$elm$golang$haskell$java$julia$nodejs$nim$python$rust$scala[](fg:#86BBD8 bg:#06969A)$docker_context[](fg:#06969A bg:#33658A)$time[ ](fg:#33658A)
        $character
      '';

      username = {
        show_always = true;
        style_user = "bg:#3b4252 fg:#88c0d0";
        style_root = "bg:#3b4252 fg:#bf616a";
        format = "[$user ]($style)";
        disabled = false;
      };

      os = {
        style = "bg:#3b4252 fg:#d8dee9";
        disabled = false;
        symbols = {
          NixOS = "󱄅 ";
        };
      };

      directory = {
        style = "bg:#434c5e fg:#d8dee9";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          Documents = "󰈙 ";
          Downloads = " ";
          Music = " ";
          Pictures = " ";
          Projects = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:#4c566a fg:#d8dee9";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bg:#4c566a fg:#d8dee9";
        format = "[$all_status$ahead_behind ]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:#86BBD8 fg:#2e3440";
        format = "[ $symbol ($version) ]($style)";
      };

      python = {
        symbol = "";
        style = "bg:#86BBD8 fg:#2e3440";
        format = "[ $symbol ($version) ]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:#86BBD8 fg:#2e3440";
        format = "[ $symbol ($version) ]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:#86BBD8 fg:#2e3440";
        format = "[ $symbol ($version) ]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:#06969A fg:#2e3440";
        format = "[ $symbol $context ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#33658A fg:#d8dee9";
        format = "[ 󰥔 $time ]($style)";
      };

      character = {
        success_symbol = "[❯](bold #a3be8c)";
        error_symbol = "[❯](bold #bf616a)";
      };
    };
  };
}
