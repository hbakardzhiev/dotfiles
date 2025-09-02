{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  programs.waybar = {
    enable = true;
    package = pkgs-unstable.waybar;
    settings = {
      mainBar = {
        passthrough = false;
        ipc = true;
        layer = "top";
        mode = "dock";
        position = "bottom";
        height = 32;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/submap"
          # "wlr/taskbar"
          "privacy"
        ];
        # modules-center = [ "hyprland/window" ];
        modules-right = [
          "custom/pomodoro"
          "pulseaudio"
          # "network"
          "cpu"
          "memory"
          "hyprland/language"
          "bluetooth"
          "backlight"
          "temperature"
          "disk"
          "battery"
          "clock"
          "tray"
        ];
        "custom/pomodoro" = {
          exec = "${pkgs.openpomodoro-cli}/bin/pomodoro status";
          on-click = "${pkgs.openpomodoro-cli}/bin/pomodoro start";
          on-click-right = "${pkgs.openpomodoro-cli}/bin/pomodoro start -t break -d 5";
          on-click-middle = "${pkgs.openpomodoro-cli}/bin/pomodoro start -t break -d 15";
          interval = 1;
        };
        "wlr/taskbar" = {
          on-click = "activate";
          on-click-right = "close";
        };
        "hyprland/workspaces" = {
          format = "{icon}: {windows}";
          format-window-separator = "";
          workspace-taskbar = {
            enable = true;
            update-active-window = true;
            format = "{icon} {title:.22}";
            icon-size = 18;
          };
          # disable-scroll = false;
          # all-outputs = true;
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
            <tt>{calendar}</tt>'';
          format-alt = "{:%Y-%m-%d %H:%M:%S}";
          format = "{:%Y-%m-%d %H:%M}";
          locale = "en_GB.UTF-8";
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
        bluetooth = {
          format = " {status}";
          format-disabled = "";
          format-connected = " {num_connections} connected";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        };
      };
    };
  };
}
