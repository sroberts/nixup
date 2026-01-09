{ config, pkgs, ... }:

# Nord Theme Color Reference
# ---------------------------
# Polar Night (dark backgrounds)
#   nord0: #2e3440 - Base background
#   nord1: #3b4252 - Elevated surfaces
#   nord2: #434c5e - Selection/highlight
#   nord3: #4c566a - Comments/inactive
#
# Snow Storm (light foregrounds)
#   nord4: #d8dee9 - Primary text
#   nord5: #e5e9f0 - Secondary text
#   nord6: #eceff4 - Bright/emphasis
#
# Frost (accent blues)
#   nord7: #8fbcbb - Teal (types, attributes)
#   nord8: #88c0d0 - Cyan (primary accent)
#   nord9: #81a1c1 - Blue (keywords)
#   nord10: #5e81ac - Deep blue (functions)
#
# Aurora (semantic colors)
#   nord11: #bf616a - Red (errors, deletion)
#   nord12: #d08770 - Orange (warnings)
#   nord13: #ebcb8b - Yellow (strings, modified)
#   nord14: #a3be8c - Green (success, additions)
#   nord15: #b48ead - Purple (numbers, special)

{
  # Color variables for easy reference in other configs
  home.sessionVariables = {
    # Polar Night
    NORD0 = "#2e3440";
    NORD1 = "#3b4252";
    NORD2 = "#434c5e";
    NORD3 = "#4c566a";
    # Snow Storm
    NORD4 = "#d8dee9";
    NORD5 = "#e5e9f0";
    NORD6 = "#eceff4";
    # Frost
    NORD7 = "#8fbcbb";
    NORD8 = "#88c0d0";
    NORD9 = "#81a1c1";
    NORD10 = "#5e81ac";
    # Aurora
    NORD11 = "#bf616a";
    NORD12 = "#d08770";
    NORD13 = "#ebcb8b";
    NORD14 = "#a3be8c";
    NORD15 = "#b48ead";
  };

  # Consistent cursor theme
  home.pointerCursor = {
    name = "Nordzy-cursors";
    package = pkgs.nordzy-cursor-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Wallpaper - create a simple solid color background
  # You can replace this with an actual wallpaper
  home.file.".local/share/backgrounds/nord-gradient.svg".text = ''
    <svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080">
      <defs>
        <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style="stop-color:#2e3440"/>
          <stop offset="50%" style="stop-color:#3b4252"/>
          <stop offset="100%" style="stop-color:#2e3440"/>
        </linearGradient>
      </defs>
      <rect width="100%" height="100%" fill="url(#bg)"/>
    </svg>
  '';

  # You can add hyprpaper or swww for wallpaper management
  # For now, Hyprland will use a solid color
}
