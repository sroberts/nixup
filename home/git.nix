{ config, pkgs, local, ... }:

{
  programs.git = {
    enable = true;

    userName = local.gitUsername;
    userEmail = local.gitEmail;

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";

      # Credential helper - uses system keyring
      credential.helper = "libsecret";
    };

    # Git aliases
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      lg = "log --oneline --graph --decorate --all";
      amend = "commit --amend --no-edit";
      undo = "reset --soft HEAD~1";
    };

    # Delta for better diffs
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        syntax-theme = "Nord";
        line-numbers = true;
        side-by-side = false;
      };
    };

    # Ignore patterns
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".direnv"
      ".envrc"
      "result"
      "result-*"
      ".idea"
      ".vscode"
      "node_modules"
      "__pycache__"
      "*.pyc"
      ".pytest_cache"
      "target"
      "dist"
      "build"
    ];
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
