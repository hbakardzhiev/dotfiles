{
  ...
}:
{
  # The SMART helper the bar calls: a plain script in the repo.
  home.file.".config/waybar/disk-health".source = ./disk-health;

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [
      {
        layer = "top";
        position = "bottom";
        height = 26;
        spacing = 6;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "custom/disk-health"
          "hyprland/language"
          "pulseaudio"
          "network"
          "bluetooth"
          "backlight"
          "battery"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
          all-outputs = true;
        };

        "hyprland/window" = {
          format = "{title}";
          max-length = 70;
          separate-outputs = true;
        };

        "hyprland/language" = {
          format = "{short}";
        };

        clock = {
          format = "{:%a %d %b  %H:%M}";
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            weeks = true;
            format = {
              # Inverted square behind the current day so it stands out at a glance.
              today = "<span background='#f6f6f6' color='#1f1f1f'><b>&#160;{}&#160;</b></span>";
            };
          };
        };

        "custom/disk-health" = {
          exec = "$HOME/.config/waybar/disk-health waybar";
          interval = 300;
          return-type = "json";
          tooltip = true;
          on-click = "$HOME/.config/waybar/disk-health details";
        };

        pulseaudio = {
          format = "{volume}%";
          format-muted = "muted";
          scroll-step = 5;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        network = {
          format-wifi = "{essid}";
          format-ethernet = "ethernet";
          format-disconnected = "offline";
          tooltip-format = "{ifname}  {ipaddr}";
        };

        bluetooth = {
          format = "bt {status}";
          format-disabled = "";
          format-connected = "bt {device_alias}";
          tooltip-format = "{controller_alias}  {num_connections} connected";
        };

        backlight = {
          format = "{percent}%";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}%";
          format-charging = "charging {capacity}%";
          format-plugged = "ac {capacity}%";
          tooltip-format = "{timeTo}";
        };

        tray = {
          spacing = 6;
        };
      }
    ];

    # Neutral light, no accent palette.
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 11px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: #f6f6f6;
        color: #1f1f1f;
        border-top: 1px solid #d8d8d8;
      }

      #workspaces button {
        padding: 0 6px;
        background: transparent;
        color: #555555;
      }

      #workspaces button.active {
        background: #e2e2e2;
        color: #1f1f1f;
      }

      #workspaces button.urgent {
        background: #b3261e;
        color: #ffffff;
      }

      #clock,
      #window,
      #tray,
      #network,
      #bluetooth,
      #pulseaudio,
      #backlight,
      #battery,
      #language,
      #custom-disk-health {
        padding: 0 8px;
      }

      #battery.warning,
      #custom-disk-health.warn {
        color: #9a6700;
      }

      #battery.critical,
      #custom-disk-health.fail {
        color: #b3261e;
      }
    '';
  };
}
