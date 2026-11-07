{
  ...
}:
{
  # The SMART helper the Waybar module calls. It is a plain script in the
  # repo, symlinked into place by Home Manager.
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

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "alacritty";
        layer = "overlay";
        width = 40;
        lines = 12;
      };
      border = {
        width = 1;
        radius = 0;
      };
      colors = {
        background = "f6f6f6ff";
        text = "1f1f1fff";
        match = "205ea6ff";
        selection = "e2e2e2ff";
        selection-text = "1f1f1fff";
        border = "d8d8d8ff";
      };
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          monitor = "";
          color = "rgb(246, 246, 246)";
        }
      ];

      label = [
        {
          monitor = "";
          text = "cmd[update:1000] date +%H:%M";
          color = "rgb(31, 31, 31)";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 64;
          position = "0, 160";
          halign = "center";
          valign = "center";
        }
      ];

      "input-field" = [
        {
          monitor = "";
          size = "240, 44";
          outline_thickness = 1;
          dots_center = true;
          outer_color = "rgb(31, 31, 31)";
          inner_color = "rgb(255, 255, 255)";
          font_color = "rgb(31, 31, 31)";
          font_family = "JetBrainsMono Nerd Font";
          fade_on_empty = false;
          placeholder_text = "Password";
          position = "0, -60";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 10";
      anchor = "top-right";
      layer = "overlay";
      width = 360;
      height = 160;
      margin = 10;
      padding = 10;
      border-size = 1;
      border-color = "#d8d8d8";
      background-color = "#f6f6f6";
      text-color = "#1f1f1f";
      default-timeout = 8000;
      max-visible = 4;
      icons = true;
    };
    extraConfig = ''
      [urgency=critical]
      border-color=#b3261e
      text-color=#b3261e
      default-timeout=0
    '';
  };
}
