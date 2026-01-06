# Niri user configuration
{ config, pkgs, lib, ... }:

{
  # Niri configuration
  xdg.configFile."niri/config.kdl".text = ''
    // Niri Configuration
    // See https://github.com/YaLTeR/niri/wiki/Configuration

    input {
        keyboard {
            xkb {
                layout "us"
            }
            repeat-delay 300
            repeat-rate 50
        }

        touchpad {
            tap
            dwt
            natural-scroll
            accel-speed 0.2
        }

        mouse {
            accel-speed 0.0
        }

        focus-follows-mouse max-scroll-amount="25%"
    }

    layout {
        gaps 8
        default-column-width { proportion 0.5; }

        border {
            width 2
            active-color "#7aa2f7"
            inactive-color "#414868"
        }

        focus-ring {
            off
        }

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
            proportion 1.0
        }
    }

    cursor {
        xcursor-theme "Adwaita"
        xcursor-size 24
    }

    screenshot-path "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"

    spawn-at-startup "waybar"
    spawn-at-startup "mako"

    prefer-no-csd

    hotkey-overlay {
        skip-at-startup
    }

    binds {
        Mod+Return { spawn "ghostty"; }
        Mod+Space { spawn "fuzzel"; }
        Mod+E { spawn "ghostty" "-e" "yazi"; }
        Mod+Q { close-window; }
        Mod+Shift+Q { quit; }
        Mod+L { spawn "swaylock"; }
        Mod+Escape { spawn "power-menu"; }

        Print { screenshot; }
        Mod+Print { screenshot-screen; }
        Mod+Shift+Print { screenshot-window; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H { focus-column-left; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }
        Mod+Semicolon { focus-column-right; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+H { move-column-left; }
        Mod+Shift+J { move-window-down; }
        Mod+Shift+K { move-window-up; }
        Mod+Shift+Semicolon { move-column-right; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        Mod+R { switch-preset-column-width; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+C { consume-window-into-column; }
        Mod+X { expel-window-from-column; }

        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up { focus-workspace-up; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn "pamixer" "-i" "5"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "pamixer" "-d" "5"; }
        XF86AudioMute        allow-when-locked=true { spawn "pamixer" "-t"; }
        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "+5%"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }
        XF86AudioPlay  { spawn "playerctl" "play-pause"; }
        XF86AudioNext  { spawn "playerctl" "next"; }
        XF86AudioPrev  { spawn "playerctl" "previous"; }
    }

    window-rule {
        open-centered true
    }

    window-rule {
        match app-id="pavucontrol"
        open-floating true
    }

    window-rule {
        match app-id="nm-connection-editor"
        open-floating true
    }

    window-rule {
        match app-id="blueman-manager"
        open-floating true
    }
  '';

  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 8;

        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          states = {
            warning = 30;
            critical = 15;
          };
        };

        network = {
          format-wifi = "󰖩 {signalStrength}%";
          format-ethernet = "󰈀";
          format-disconnected = "󰖪";
          tooltip-format = "{ifname}: {ipaddr}";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol";
        };

        tray = {
          spacing = 8;
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", sans-serif;
        font-size: 13px;
      }

      window#waybar {
        background: rgba(26, 27, 38, 0.9);
        color: #c0caf5;
      }

      #workspaces button {
        padding: 0 8px;
        color: #565f89;
        border-bottom: 2px solid transparent;
      }

      #workspaces button.active {
        color: #7aa2f7;
        border-bottom: 2px solid #7aa2f7;
      }

      #clock, #battery, #network, #pulseaudio, #tray {
        padding: 0 12px;
      }

      #battery.warning {
        color: #e0af68;
      }

      #battery.critical {
        color: #f7768e;
      }
    '';
  };

  # Mako notifications
  services.mako = {
    enable = true;
    backgroundColor = "#1a1b26";
    textColor = "#c0caf5";
    borderColor = "#7aa2f7";
    borderRadius = 8;
    borderSize = 2;
    defaultTimeout = 5000;
    font = "JetBrainsMono Nerd Font 11";
  };

  # Fuzzel launcher
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=12
    terminal=ghostty -e
    layer=overlay

    [colors]
    background=1a1b26ff
    text=c0caf5ff
    selection=7aa2f7ff
    selection-text=1a1b26ff
    border=7aa2f7ff
    match=7dcfffff

    [border]
    width=2
    radius=8
  '';

  # Swaylock
  xdg.configFile."swaylock/config".text = ''
    ignore-empty-password
    show-failed-attempts
    daemonize
    color=1a1b26
    inside-color=1a1b26
    inside-clear-color=1a1b26
    inside-ver-color=1a1b26
    inside-wrong-color=1a1b26
    key-hl-color=7aa2f7
    ring-color=414868
    ring-clear-color=e0af68
    ring-ver-color=7aa2f7
    ring-wrong-color=f7768e
    text-color=c0caf5
    text-clear-color=c0caf5
    text-ver-color=c0caf5
    text-wrong-color=f7768e
    font=JetBrainsMono Nerd Font
  '';

  # Power menu script
  home.file.".local/bin/power-menu" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Power menu script for Niri using fuzzel

      set -euo pipefail

      OPTIONS="Lock
      Logout
      Suspend
      Reboot
      Shutdown"

      SELECTION=$(echo -e "$OPTIONS" | fuzzel --dmenu --prompt "Power: ")

      case "$SELECTION" in
          Lock)
              swaylock
              ;;
          Logout)
              niri msg action quit
              ;;
          Suspend)
              systemctl suspend
              ;;
          Reboot)
              systemctl reboot
              ;;
          Shutdown)
              systemctl poweroff
              ;;
          *)
              exit 0
              ;;
      esac
    '';
  };
}
