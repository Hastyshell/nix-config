{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.custom.linux.desktop.bar.waybar.enable {
    programs.waybar = {
      enable = true;
      style = ./style.css;
      settings = {
        default = {
          layer = "top";
          position = "top";
          margin-bottom = -15;
          # position = "bottom";
          # margin-top = -15;
          spacing = 0;

          modules-left = [
          ];
          modules-center = [
            "niri/workspaces"
          ];
          modules-right = [
            "custom/music"
            "cpu"
            "memory"
            "temperature"
            "bluetooth"
            "network"
            "pulseaudio"
            "clock"
            "custom/nixos"
          ];

          "niri/workspaces" = {
            format = "{icon}";
            format-icons = {
              # Icons by state
              active = "";
              default = "";
            };
          };

          "custom/nixos" = {
            format = "";
            interval = 0;
            tooltip = false;
            on-click = "systemctl poweroff";
          };

          "custom/music" = {
            format = "  {}";
            escape = true;
            interval = 5;
            tooltip = false;
            exec = "playerctl metadata --format='{{ artist }} - {{ title }}'";
            on-click = "playerctl play-pause";
            max-length = 30;
          };

          cpu = {
            interval = 1;
            format = "  {usage:>2}%";
            on-click = "alacritty -e btop";
          };

          memory = {
            interval = 30;
            format = "  {used:0.1f}G";
            tooltip-format = "Memory";
            on-click = "alacritty -e btop";
          };

          temperature = {
            hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
            format = " {temperatureC}°C";
            on-click = "alacritty -e btop";
          };

          bluetooth = {
            format = "󰂲";
            format-on = "{icon}";
            format-off = "{icon}";
            format-connected = "{icon}";
            format-icons = {
              on = "󰂯";
              off = "󰂲";
              connected = "󰂱";
            };
            on-click = "alacritty -e bluetui";
            tooltip-format-connected = "{device_enumerate}";
          };

          network = {
            format-wifi = "󰤢";
            format-ethernet = "󰈀";
            format-disconnected = "󰤠";
            interval = 5;
            tooltip-format = "{essid} ({signalStrength}%)";
            on-click = "alacritty -e nmtui";
          };

          pulseaudio = {
            format = "{icon}  {volume}%";
            format-muted = "";
            format-icons = {
              default = [
                ""
                ""
                " "
              ];
            };
            on-click = "alacritty -e wiremix";
          };

          clock = {
            timezone = "Asia/Shanghai";
            tooltip = false;
            format = "{:%H:%M • %a, %d %b}";
            interval = 1;
          };

        };
      };
    };

  };
}
