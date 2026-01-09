{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;

    # Nord theme colors
    backgroundColor = "#2e3440";
    textColor = "#d8dee9";
    borderColor = "#88c0d0";
    progressColor = "over #5e81ac";

    # Layout
    font = "JetBrainsMono Nerd Font 11";
    width = 350;
    height = 150;
    margin = "10";
    padding = "15";
    borderSize = 2;
    borderRadius = 10;
    icons = true;
    maxIconSize = 48;

    # Behavior
    defaultTimeout = 5000;
    ignoreTimeout = false;
    maxVisible = 5;
    sort = "-time";
    layer = "overlay";
    anchor = "top-right";

    extraConfig = ''
      [urgency=low]
      border-color=#4c566a
      default-timeout=3000

      [urgency=normal]
      border-color=#88c0d0
      default-timeout=5000

      [urgency=high]
      border-color=#bf616a
      text-color=#eceff4
      default-timeout=0

      [category=mpd]
      default-timeout=2000
      group-by=category
    '';
  };
}
