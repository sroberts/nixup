{ config, pkgs, ... }:

{
  home.packages = [ pkgs.zed-editor ];

  # Zed configuration
  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    # Theme
    theme = "Nord";
    
    # UI
    ui_font_size = 15;
    buffer_font_size = 14;
    buffer_font_family = "JetBrainsMono Nerd Font";
    
    # Editor
    tab_size = 2;
    soft_wrap = "editor_width";
    show_whitespaces = "selection";
    format_on_save = "on";
    
    # Vim mode - disable if you prefer standard editing
    vim_mode = false;
    
    # File handling
    autosave = "on_focus_change";
    
    # Git
    git = {
      git_gutter = "tracked_files";
    };
    
    # Terminal
    terminal = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 13;
      shell = {
        program = "zsh";
      };
    };
    
    # Telemetry
    telemetry = {
      metrics = false;
      diagnostics = false;
    };
    
    # LSP
    lsp = {
      nil = {
        initialization_options = {
          formatting = {
            command = [ "nixpkgs-fmt" ];
          };
        };
      };
    };
  };

  # Zed keymap
  xdg.configFile."zed/keymap.json".text = builtins.toJSON [
    {
      context = "Workspace";
      bindings = {
        "ctrl-shift-e" = "workspace::ToggleLeftDock";
        "ctrl-shift-f" = "pane::DeploySearch";
        "ctrl-p" = "file_finder::Toggle";
        "ctrl-shift-p" = "command_palette::Toggle";
      };
    }
    {
      context = "Editor";
      bindings = {
        "ctrl-/" = "editor::ToggleComments";
        "ctrl-d" = "editor::SelectNext";
        "ctrl-shift-k" = "editor::DeleteLine";
      };
    }
  ];
}
