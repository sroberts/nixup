# Yazi file manager configuration
{ config, pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
      };

      preview = {
        image_filter = "triangle";
        image_quality = 75;
        max_width = 600;
        max_height = 900;
      };
    };
  };

  # Theme file
  xdg.configFile."yazi/theme.toml".text = ''
    # Tokyo Night theme for Yazi

    [manager]
    cwd = { fg = "#7aa2f7" }

    # Hovered
    hovered = { fg = "#1a1b26", bg = "#7aa2f7" }
    preview_hovered = { underline = true }

    # Find
    find_keyword = { fg = "#e0af68", bold = true }
    find_position = { fg = "#bb9af7", bg = "reset", bold = true }

    # Marker
    marker_selected = { fg = "#9ece6a", bg = "#9ece6a" }
    marker_copied = { fg = "#e0af68", bg = "#e0af68" }
    marker_cut = { fg = "#f7768e", bg = "#f7768e" }

    # Tab
    tab_active = { fg = "#1a1b26", bg = "#7aa2f7" }
    tab_inactive = { fg = "#c0caf5", bg = "#414868" }
    tab_width = 1

    # Border
    border_symbol = "│"
    border_style = { fg = "#414868" }

    [status]
    separator_open = ""
    separator_close = ""
    separator_style = { fg = "#414868", bg = "#414868" }

    # Mode
    mode_normal = { fg = "#1a1b26", bg = "#7aa2f7", bold = true }
    mode_select = { fg = "#1a1b26", bg = "#9ece6a", bold = true }
    mode_unset = { fg = "#1a1b26", bg = "#f7768e", bold = true }

    # Progress
    progress_label = { bold = true }
    progress_normal = { fg = "#7aa2f7", bg = "#414868" }
    progress_error = { fg = "#f7768e", bg = "#414868" }

    # Permissions
    permissions_t = { fg = "#7aa2f7" }
    permissions_r = { fg = "#e0af68" }
    permissions_w = { fg = "#f7768e" }
    permissions_x = { fg = "#9ece6a" }
    permissions_s = { fg = "#565f89" }

    [input]
    border = { fg = "#7aa2f7" }
    title = {}
    value = {}
    selected = { reversed = true }

    [select]
    border = { fg = "#7aa2f7" }
    active = { fg = "#bb9af7" }
    inactive = {}

    [tasks]
    border = { fg = "#7aa2f7" }
    title = {}
    hovered = { underline = true }

    [which]
    mask = { bg = "#414868" }
    cand = { fg = "#7dcfff" }
    rest = { fg = "#565f89" }
    desc = { fg = "#bb9af7" }
    separator = "  "
    separator_style = { fg = "#414868" }

    [help]
    on = { fg = "#bb9af7" }
    exec = { fg = "#7dcfff" }
    desc = { fg = "#565f89" }
    hovered = { bg = "#414868", bold = true }
    footer = { fg = "#414868", bg = "#c0caf5" }

    [filetype]
    rules = [
      { mime = "image/*", fg = "#bb9af7" },
      { mime = "video/*", fg = "#e0af68" },
      { mime = "audio/*", fg = "#e0af68" },
      { mime = "application/zip", fg = "#f7768e" },
      { mime = "application/gzip", fg = "#f7768e" },
      { mime = "application/x-tar", fg = "#f7768e" },
      { mime = "application/pdf", fg = "#9ece6a" },
      { name = "*.nix", fg = "#7aa2f7" },
      { name = "*.md", fg = "#c0caf5" },
      { name = "*.json", fg = "#e0af68" },
      { name = "*.toml", fg = "#e0af68" },
      { name = "*.yaml", fg = "#e0af68" },
      { name = "*.yml", fg = "#e0af68" },
    ]
  '';
}
