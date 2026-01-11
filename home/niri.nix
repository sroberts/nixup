{ config, pkgs, lib, ... }:

{
  # Niri is configured system-wide in modules/nixos/niri.nix
  # This file contains user-specific niri configuration

  home.file.".config/niri/config.kdl".text = ''
    // Niri configuration in KDL format

    // Input configuration
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }

        touchpad {
            tap
            natural-scroll
            accel-speed 0.2
        }

        mouse {
            accel-speed 0.2
        }
    }

    // Output configuration
    output "eDP-1" {
        mode "2256x1504@60"
        scale 1.25
        position x=0 y=0
    }

    // Layout configuration
    layout {
        gaps 8
        center-focused-column "on-overflow"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            width 2
            active-color "#88C0D0"
            inactive-color "#4C566A"
        }

        border {
            width 1
            active-color "#88C0D0"
            inactive-color "#4C566A"
        }
    }

    // Keybindings
    binds {
        // Window management
        Mod+Q { close-window; }
        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H { focus-column-left; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }
        Mod+L { focus-column-right; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+H { move-column-left; }
        Mod+Shift+J { move-window-down; }
        Mod+Shift+K { move-window-up; }
        Mod+Shift+L { move-column-right; }

        // Column resizing
        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+Shift+1 { move-window-to-workspace 1; }
        Mod+Shift+2 { move-window-to-workspace 2; }
        Mod+Shift+3 { move-window-to-workspace 3; }
        Mod+Shift+4 { move-window-to-workspace 4; }
        Mod+Shift+5 { move-window-to-workspace 5; }
        Mod+Shift+6 { move-window-to-workspace 6; }
        Mod+Shift+7 { move-window-to-workspace 7; }
        Mod+Shift+8 { move-window-to-workspace 8; }
        Mod+Shift+9 { move-window-to-workspace 9; }

        // Applications
        Mod+Return { spawn "ghostty"; }
        Mod+D { spawn "fuzzel"; }
        Mod+E { spawn "ghostty" "-e" "yazi"; }

        // Screenshots
        Print { spawn "grim" "-g" "$(slurp)" "-" "|" "swappy" "-f" "-"; }
        Mod+Print { spawn "grim" "-" "|" "swappy" "-f" "-"; }

        // Media controls
        XF86AudioRaiseVolume { spawn "pamixer" "-i" "5"; }
        XF86AudioLowerVolume { spawn "pamixer" "-d" "5"; }
        XF86AudioMute { spawn "pamixer" "-t"; }
        XF86AudioPlay { spawn "playerctl" "play-pause"; }
        XF86AudioNext { spawn "playerctl" "next"; }
        XF86AudioPrev { spawn "playerctl" "previous"; }

        // Brightness
        XF86MonBrightnessUp { spawn "brightnessctl" "set" "+5%"; }
        XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }

        // System
        Mod+Shift+E { spawn "swaylock"; }
        Mod+Shift+Q { quit; }
    }

    // Animations
    animations {
        slowdown 1.0

        window-open {
            duration-ms 200
            curve "ease-out-expo"
        }

        window-close {
            duration-ms 150
            curve "ease-out-quad"
        }

        window-movement {
            duration-ms 200
            curve "ease-out-cubic"
        }

        workspace-switch {
            duration-ms 200
            curve "ease-out-cubic"
        }
    }

    // Window rules
    window-rule {
        geometry-corner-radius 8
        clip-to-geometry true
    }

    // Cursor
    cursor {
        size 24
    }

    // Screenshot path
    screenshot-path "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"

    // Spawn at startup
    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "wl-paste" "--type" "text" "--watch" "cliphist" "store"
    spawn-at-startup "wl-paste" "--type" "image" "--watch" "cliphist" "store"
  '';
}
