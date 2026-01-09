{ config, pkgs, inputs, ... }:

{
  # Install Ghostty from flake input
  home.packages = [
    inputs.ghostty.packages.${pkgs.system}.default
  ];

  # Ghostty configuration
  xdg.configFile."ghostty/config".text = ''
    # Font
    font-family = JetBrainsMono Nerd Font
    font-size = 12
    font-feature = calt
    font-feature = liga

    # Nord Theme
    background = 2e3440
    foreground = d8dee9
    selection-background = 4c566a
    selection-foreground = d8dee9
    cursor-color = d8dee9

    # Nord palette
    palette = 0=#3b4252
    palette = 1=#bf616a
    palette = 2=#a3be8c
    palette = 3=#ebcb8b
    palette = 4=#81a1c1
    palette = 5=#b48ead
    palette = 6=#88c0d0
    palette = 7=#e5e9f0
    palette = 8=#4c566a
    palette = 9=#bf616a
    palette = 10=#a3be8c
    palette = 11=#ebcb8b
    palette = 12=#81a1c1
    palette = 13=#b48ead
    palette = 14=#8fbcbb
    palette = 15=#eceff4

    # Window
    window-padding-x = 10
    window-padding-y = 10
    window-decoration = false
    gtk-titlebar = false

    # Behavior
    copy-on-select = clipboard
    confirm-close-surface = false
    mouse-hide-while-typing = true

    # Scrollback
    scrollback-limit = 50000

    # Shell integration
    shell-integration = zsh

    # Keybindings
    keybind = ctrl+shift+c=copy_to_clipboard
    keybind = ctrl+shift+v=paste_from_clipboard
    keybind = ctrl+shift+t=new_tab
    keybind = ctrl+shift+n=new_window
    keybind = ctrl+plus=increase_font_size:1
    keybind = ctrl+minus=decrease_font_size:1
    keybind = ctrl+zero=reset_font_size
  '';
}
