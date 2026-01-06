# Git configuration
{ config, pkgs, lib, local, ... }:

{
  programs.git = {
    enable = true;

    # User info from local.nix
    userName = local.gitUsername;
    userEmail = local.gitEmail;

    extraConfig = {
      init.defaultBranch = "main";

      core = {
        editor = "nvim";
        autocrlf = "input";
        whitespace = "fix";
      };

      pull.rebase = true;
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      fetch.prune = true;
      rebase.autoStash = true;
      rerere.enabled = true;

      merge.conflictstyle = "diff3";
      diff = {
        colorMoved = "default";
        algorithm = "histogram";
      };

      credential.helper = "libsecret";

      url = {
        "git@github.com:" = { insteadOf = "gh:"; };
        "git@gitlab.com:" = { insteadOf = "gl:"; };
      };

      color.ui = "auto";
    };

    aliases = {
      s = "status";
      a = "add";
      aa = "add --all";
      c = "commit";
      cm = "commit -m";
      co = "checkout";
      cb = "checkout -b";
      br = "branch";
      d = "diff";
      ds = "diff --staged";
      p = "push";
      pl = "pull";
      l = "log --oneline -20";
      lg = "log --oneline --graph --decorate --all";
      lp = "log --patch";
      unstage = "reset HEAD --";
      undo = "reset --soft HEAD~1";
      amend = "commit --amend --no-edit";
      last = "log -1 HEAD --stat";
      branches = "branch -a";
      remotes = "remote -v";
      tags = "tag -l";
      stashes = "stash list";
      cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
      ai = "add --interactive";
      ap = "add --patch";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "TwoDark";

        # Tokyo Night-inspired colors
        minus-style = "syntax #37222c";
        minus-emph-style = "syntax #713137";
        plus-style = "syntax #20303b";
        plus-emph-style = "syntax #2c5a66";

        file-style = "yellow bold";
        file-decoration-style = "yellow box";
        hunk-header-style = "line-number syntax bold";
        hunk-header-decoration-style = "blue box";
      };
    };

    lfs.enable = true;
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
