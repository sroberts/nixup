# Ghostty terminal configuration
{ config, pkgs, lib, ... }:

{
  xdg.configFile."ghostty/config".text = ''
    # Font
    font-family = "JetBrainsMono Nerd Font"
    font-size = 12

    # Tokyo Night theme
    background = #1a1b26
    foreground = #c0caf5

    # Cursor
    cursor-color = #c0caf5

    # Selection
    selection-background = #33467c
    selection-foreground = #c0caf5

    # Normal colors
    palette = 0=#15161e
    palette = 1=#f7768e
    palette = 2=#9ece6a
    palette = 3=#e0af68
    palette = 4=#7aa2f7
    palette = 5=#bb9af7
    palette = 6=#7dcfff
    palette = 7=#a9b1d6

    # Bright colors
    palette = 8=#414868
    palette = 9=#f7768e
    palette = 10=#9ece6a
    palette = 11=#e0af68
    palette = 12=#7aa2f7
    palette = 13=#bb9af7
    palette = 14=#7dcfff
    palette = 15=#c0caf5

    # Window
    window-padding-x = 8
    window-padding-y = 8
    window-decoration = false

    # Behavior
    copy-on-select = clipboard
    confirm-close-surface = false

    # Scrollback
    scrollback-limit = 10000

    # Keybindings
    keybind = ctrl+shift+c=copy_to_clipboard
    keybind = ctrl+shift+v=paste_from_clipboard
    keybind = ctrl+shift+n=new_window
    keybind = ctrl+plus=increase_font_size:1
    keybind = ctrl+minus=decrease_font_size:1
    keybind = ctrl+zero=reset_font_size
  '';
}
