{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 4;
        margin-top = 4;
        margin-left = 8;
        margin-right = 8;

        modules-left = [
          "clock#date"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "bluetooth"
          "backlight"
          "battery"
          "power-profiles-daemon"
        ];

        "clock#date" = {
          format = "{:%A, %B %d}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%A, %B %d, %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            format = {
              months = "<span color='#88c0d0'><b>{}</b></span>";
              days = "<span color='#d8dee9'>{}</span>";
              weeks = "<span color='#8fbcbb'>W{}</span>";
              weekdays = "<span color='#81a1c1'>{}</span>";
              today = "<span color='#bf616a'><b>{}</b></span>";
            };
          };
        };

        battery = {
          states = {
            good = 80;
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip-format = "{timeTo}\n{power} W";
        };

        network = {
          format-wifi = "󰖩 {signalStrength}%";
          format-ethernet = "󰈀";
          format-disconnected = "󰖪";
          tooltip-format-wifi = "{essid}\n{ipaddr}/{cidr}";
          tooltip-format-ethernet = "{ifname}\n{ipaddr}/{cidr}";
          on-click = "nm-connection-editor";
        };

        bluetooth = {
          format = "󰂯";
          format-connected = "󰂱 {device_alias}";
          format-disabled = "󰂲";
          tooltip-format = "{controller_alias}\n{status}";
          on-click = "blueman-manager";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol";
          on-click-right = "pamixer -t";
        };

        backlight = {
          format = "󰃟 {percent}%";
          tooltip-format = "Brightness: {percent}%";
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}";
          format-icons = {
            default = "󰗑";
            performance = "󰓅";
            balanced = "󰾅";
            power-saver = "󰾆";
          };
        };

        tray = {
          icon-size = 16;
          spacing = 8;
        };
      };
    };

    style = ''
      /* Nord Color Palette */
      @define-color nord0 #2e3440;
      @define-color nord1 #3b4252;
      @define-color nord2 #434c5e;
      @define-color nord3 #4c566a;
      @define-color nord4 #d8dee9;
      @define-color nord5 #e5e9f0;
      @define-color nord6 #eceff4;
      @define-color nord7 #8fbcbb;
      @define-color nord8 #88c0d0;
      @define-color nord9 #81a1c1;
      @define-color nord10 #5e81ac;
      @define-color nord11 #bf616a;
      @define-color nord12 #d08770;
      @define-color nord13 #ebcb8b;
      @define-color nord14 #a3be8c;
      @define-color nord15 #b48ead;

      * {
        font-family: "JetBrainsMono Nerd Font", "Inter", sans-serif;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: alpha(@nord0, 0.9);
        border-radius: 12px;
        border: 1px solid @nord3;
      }

      #workspaces {
        margin: 4px;
        background: @nord1;
        border-radius: 8px;
        padding: 0 4px;
      }

      #workspaces button {
        color: @nord4;
        padding: 4px 8px;
        margin: 2px;
        border-radius: 6px;
        background: transparent;
        transition: all 0.2s ease;
      }

      #workspaces button:hover {
        background: @nord2;
      }

      #workspaces button.active {
        color: @nord0;
        background: @nord8;
      }

      #workspaces button.urgent {
        background: @nord11;
        color: @nord6;
      }

      #window {
        color: @nord4;
        margin-left: 8px;
      }

      #clock {
        color: @nord4;
        font-weight: bold;
      }

      #battery,
      #network,
      #bluetooth,
      #pulseaudio,
      #backlight,
      #power-profiles-daemon,
      #tray {
        padding: 4px 12px;
        margin: 4px 2px;
        background: @nord1;
        border-radius: 8px;
        color: @nord4;
      }

      #battery.charging {
        color: @nord14;
      }

      #battery.warning:not(.charging) {
        color: @nord13;
      }

      #battery.critical:not(.charging) {
        color: @nord11;
        animation: blink 0.5s linear infinite alternate;
      }

      @keyframes blink {
        to {
          background: @nord11;
          color: @nord6;
        }
      }

      #network.disconnected {
        color: @nord11;
      }

      #bluetooth.disabled {
        color: @nord3;
      }

      #pulseaudio.muted {
        color: @nord11;
      }

      tooltip {
        background: @nord0;
        border: 1px solid @nord3;
        border-radius: 8px;
      }

      tooltip label {
        color: @nord4;
      }
    '';
  };
}
