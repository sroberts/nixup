# Home-manager Niri configuration
# This file provides a default Niri configuration for the user
{ config, pkgs, lib, ... }:

{
  # Niri configuration file
  xdg.configFile."niri/config.kdl".text = ''
    // Niri Configuration
    // See https://github.com/YaLTeR/niri/wiki/Configuration

    // Input configuration
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

        // Focus follows mouse
        focus-follows-mouse max-scroll-amount="25%"
    }

    // Output (monitor) configuration
    // Uncomment and modify for your setup
    // output "eDP-1" {
    //     scale 1.5
    //     position x=0 y=0
    // }

    // Layout configuration
    layout {
        gaps 8

        // Default column width
        default-column-width { proportion 0.5; }

        // Window border
        border {
            width 2
            active-color "#7aa2f7"
            inactive-color "#414868"
        }

        // Focus ring (shown on top of border)
        focus-ring {
            off
        }

        // Preset column widths (cycle with Mod+R)
        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
            proportion 1.0
        }
    }

    // Cursor configuration
    cursor {
        xcursor-theme "Adwaita"
        xcursor-size 24
    }

    // Screenshot path
    screenshot-path "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png"

    // Spawn at startup
    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "swaybg" "-m" "fill" "-i" "~/.config/wallpaper.jpg"

    // Idle and lock
    spawn-at-startup "swayidle" "-w" \
        "timeout" "300" "swaylock -f" \
        "timeout" "600" "niri msg action power-off-monitors" \
        "before-sleep" "swaylock -f"

    // Environment variables for Niri session
    environment {
        DISPLAY ":0"
    }

    // Prefer server-side decorations
    prefer-no-csd

    // Hotkey overlay
    hotkey-overlay {
        skip-at-startup
    }

    // Key bindings
    binds {
        // Mod key is Super (Windows key)

        // Launch terminal
        Mod+Return { spawn "alacritty"; }
        Mod+Shift+Return { spawn "foot"; }

        // Application launcher
        Mod+Space { spawn "fuzzel"; }

        // File manager
        Mod+E { spawn "pcmanfm"; }

        // Close window
        Mod+Q { close-window; }
        Mod+Shift+Q { quit; }

        // Lock screen
        Mod+L { spawn "swaylock"; }

        // Screenshots
        Print { screenshot; }
        Mod+Print { screenshot-screen; }
        Mod+Shift+Print { screenshot-window; }

        // Focus movement
        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H { focus-column-left; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }
        Mod+Semicolon { focus-column-right; }

        // Move windows
        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+H { move-column-left; }
        Mod+Shift+J { move-window-down; }
        Mod+Shift+K { move-window-up; }
        Mod+Shift+Semicolon { move-column-right; }

        // Workspace navigation
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        // Move window to workspace
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        // Column width
        Mod+R { switch-preset-column-width; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // Fullscreen
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        // Consume/expel windows (merge/split columns)
        Mod+C { consume-window-into-column; }
        Mod+X { expel-window-from-column; }

        // Center column
        Mod+Ctrl+C { center-column; }

        // Scroll workspaces
        Mod+Page_Down      { focus-workspace-down; }
        Mod+Page_Up        { focus-workspace-up; }
        Mod+Shift+Page_Down { move-column-to-workspace-down; }
        Mod+Shift+Page_Up   { move-column-to-workspace-up; }

        // Mouse scroll for workspaces (on empty area)
        Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }

        // Media keys
        XF86AudioRaiseVolume allow-when-locked=true { spawn "pamixer" "-i" "5"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "pamixer" "-d" "5"; }
        XF86AudioMute        allow-when-locked=true { spawn "pamixer" "-t"; }
        XF86AudioMicMute     allow-when-locked=true { spawn "pamixer" "--default-source" "-t"; }
        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "+5%"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }
        XF86AudioPlay  { spawn "playerctl" "play-pause"; }
        XF86AudioPause { spawn "playerctl" "pause"; }
        XF86AudioNext  { spawn "playerctl" "next"; }
        XF86AudioPrev  { spawn "playerctl" "previous"; }

        // Power menu (using fuzzel)
        Mod+Shift+E { spawn "bash" "-c" "echo -e 'logout\nsuspend\nreboot\nshutdown' | fuzzel --dmenu | xargs -I {} bash -c 'case {} in logout) niri msg action quit;; suspend) systemctl suspend;; reboot) systemctl reboot;; shutdown) systemctl poweroff;; esac'"; }
    }

    // Window rules
    window-rule {
        // Make all windows start centered
        open-centered true
    }

    // Window rules for specific apps
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

    // Floating windows opacity
    window-rule {
        match is-floating=true
        opacity 0.95
    }
  '';

  # Waybar configuration
  xdg.configFile."waybar/config".text = builtins.toJSON {
    layer = "top";
    position = "top";
    height = 30;
    spacing = 4;

    modules-left = [ "niri/workspaces" "niri/window" ];
    modules-center = [ "clock" ];
    modules-right = [ "pulseaudio" "network" "cpu" "memory" "backlight" "battery" "tray" ];

    "niri/workspaces" = {
      format = "{icon}";
      format-icons = {
        "1" = "1";
        "2" = "2";
        "3" = "3";
        "4" = "4";
        "5" = "5";
        default = "";
      };
    };

    "niri/window" = {
      format = "{}";
      max-length = 50;
    };

    clock = {
      format = "{:%H:%M}";
      format-alt = "{:%Y-%m-%d %H:%M}";
      tooltip-format = "<tt><small>{calendar}</small></tt>";
    };

    cpu = {
      format = " {usage}%";
      interval = 2;
    };

    memory = {
      format = " {}%";
      interval = 2;
    };

    backlight = {
      format = "{icon} {percent}%";
      format-icons = [ "" "" "" "" "" "" "" "" "" ];
    };

    battery = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{icon} {capacity}%";
      format-charging = " {capacity}%";
      format-plugged = " {capacity}%";
      format-icons = [ "" "" "" "" "" ];
    };

    network = {
      format-wifi = " {signalStrength}%";
      format-ethernet = " {ipaddr}";
      format-disconnected = "⚠ Disconnected";
      tooltip-format = "{ifname}: {ipaddr}";
    };

    pulseaudio = {
      format = "{icon} {volume}%";
      format-muted = " muted";
      format-icons = {
        default = [ "" "" "" ];
      };
      on-click = "pavucontrol";
    };

    tray = {
      spacing = 10;
    };
  };

  xdg.configFile."waybar/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font", monospace;
      font-size: 13px;
    }

    window#waybar {
      background-color: rgba(26, 27, 38, 0.9);
      color: #c0caf5;
      border-bottom: 2px solid #7aa2f7;
    }

    #workspaces button {
      padding: 0 8px;
      color: #565f89;
      background-color: transparent;
      border-radius: 0;
    }

    #workspaces button.active {
      color: #7aa2f7;
      background-color: rgba(122, 162, 247, 0.2);
    }

    #workspaces button:hover {
      background-color: rgba(122, 162, 247, 0.1);
    }

    #clock, #battery, #cpu, #memory, #backlight, #network, #pulseaudio, #tray {
      padding: 0 10px;
    }

    #battery.warning {
      color: #e0af68;
    }

    #battery.critical {
      color: #f7768e;
    }
  '';

  # Mako notification daemon configuration
  xdg.configFile."mako/config".text = ''
    font=JetBrainsMono Nerd Font 10
    background-color=#1a1b26ee
    text-color=#c0caf5
    border-color=#7aa2f7
    border-size=2
    border-radius=8
    padding=10
    margin=10
    default-timeout=5000
    group-by=app-name
    max-visible=5
    layer=overlay
  '';

  # Swaylock configuration
  xdg.configFile."swaylock/config".text = ''
    color=1a1b26
    font=JetBrainsMono Nerd Font
    indicator-radius=100
    indicator-thickness=7
    ring-color=7aa2f7
    ring-ver-color=9ece6a
    ring-wrong-color=f7768e
    key-hl-color=e0af68
    text-color=c0caf5
    line-color=00000000
    inside-color=1a1b26aa
    separator-color=00000000
    show-failed-attempts
    ignore-empty-password
  '';

  # Fuzzel launcher configuration
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=12
    terminal=alacritty -e
    layer=overlay
    prompt="❯ "

    [colors]
    background=1a1b26ee
    text=c0caf5ff
    selection=7aa2f744
    selection-text=c0caf5ff
    border=7aa2f7ff
    match=7aa2f7ff

    [border]
    width=2
    radius=8
  '';

  # Alacritty terminal configuration
  xdg.configFile."alacritty/alacritty.toml".text = ''
    [font]
    size = 11.0

    [font.normal]
    family = "JetBrainsMono Nerd Font"
    style = "Regular"

    [font.bold]
    style = "Bold"

    [font.italic]
    style = "Italic"

    [window]
    padding = { x = 10, y = 10 }
    opacity = 0.95
    decorations = "None"

    # Tokyo Night theme
    [colors.primary]
    background = "#1a1b26"
    foreground = "#c0caf5"

    [colors.normal]
    black = "#15161e"
    red = "#f7768e"
    green = "#9ece6a"
    yellow = "#e0af68"
    blue = "#7aa2f7"
    magenta = "#bb9af7"
    cyan = "#7dcfff"
    white = "#a9b1d6"

    [colors.bright]
    black = "#414868"
    red = "#f7768e"
    green = "#9ece6a"
    yellow = "#e0af68"
    blue = "#7aa2f7"
    magenta = "#bb9af7"
    cyan = "#7dcfff"
    white = "#c0caf5"
  '';
}
