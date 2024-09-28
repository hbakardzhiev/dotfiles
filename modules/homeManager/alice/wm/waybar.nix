{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    # package = pkgs.waybar.override { wireplumberSupport = false; };
    settings = {
      mainBar = {
        passthrough = false;
        ipc = true;
        layer = "top";
        mode = "dock";
        position = "bottom";
        height = 32;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "wlr/taskbar"
          "privacy"
        ];
        # modules-center = [ "sway/window" ];
        modules-right = [
          "custom/pomodoro"
          "pulseaudio"
          # "network"
          "cpu"
          "memory"
          "backlight"
          "sway/language"
          "temperature"
          "disk"
          "battery"
          "clock"
          "tray"
        ];
        "custom/pomodoro" = {
          exec = "${pkgs.openpomodoro-cli}/bin/pomodoro status";
          on-click = "${pkgs.openpomodoro-cli}/bin/pomodoro start";
          on-click-right = "${pkgs.openpomodoro-cli}/bin/pomodoro break";
          interval = 1;
        };
        "wlr/taskbar" = {
          on-click = "activate";
          on-click-right = "close";
        };
        "sway/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
        };
        "sway/language" = {
          format = "{flag}";
        };
        "network" = {
          format-wifi = "{essid} ({signalStrength}%)";
          format-ethernet = "{ipaddr}/{cidr} ;";
          format-disconnected = "Disconnected ⚠";
          # on-click = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        };
        "pulseaudio" = {
          format = "{volume}% {icon} {format_source}";
          format-muted = "🔇 {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.alsa-utils}/bin/alsamixer";
        };
        "battery" = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        "backlight" = {
          format = "{percent}% {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
        };
        "temperature" = {
          format = "{temperatureC}°C {icon}";
          format-icons = [
            ""
            ""
            ""
          ];
          critical-threshold = 60;
        };
        "clock" = {
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          format-alt = "{:%Y-%m-%d}";
          format = "{:%Y-%m-%d %H:%M}";
        };
        "cpu" = {
          format = "{usage}% ";
        };
        "memory" = {
          format = "{}% ";
        };
        "disk" = {
          name = [ "os" ];
          path = [ "/" ];
          format = "{used}/{total}";
        };
        "privacy" = {
          icon-spacing = 4;
          icon-size = 18;
          transition-duration = 250;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
            }
            {
              type = "audio-out";
              tooltip = true;
            }
            {
              type = "audio-in";
              tooltip = true;
            }
          ];
        };
      };
    };
  };
  home.packages = with pkgs; [ networkmanagerapplet ];
}
