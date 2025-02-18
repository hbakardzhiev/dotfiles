{
  config,
  pkgs,
  lib,
  ...
}:
let
  mode = "(l)ock, (e)xit, switch_(u)ser, (s)uspend, (h)ibernate, (r)eboot, (Shift+s)hutdown";
  pic = builtins.path {
    path = ./bds.jpeg;
    name = "bds";
  };
in
{
  wayland.windowManager.sway = {
    enable = true;
    xwayland = false;
    config = {
      modifier = "Mod4"; # Super key
      terminal = "${pkgs.alacritty}/bin/alacritty";
      focus.wrapping = "workspace";
      menu = "${pkgs.wofi}/bin/wofi --show drun --allow-images --allow-markup --insensitive --prompt \"Yes, master!\"";
      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
          alt = "Mod1";
        in
        lib.mkOptionDefault {
          # Keyboard
          "${modifier}+j" = "focus left";
          "${modifier}+Shift+j" = "move left";
          "${modifier}+Shift+k" = "move right";
          "${modifier}+Ctrl+Left" = "workspace prev";
          "${modifier}+Ctrl+Right" = "workspace next";
          "${modifier}+Ctrl+j" = "workspace prev";
          "${modifier}+Ctrl+k" = "workspace next";
          "${alt}+Tab" = "workspace back_and_forth";
          "${modifier}+k" = "focus right";
          "${modifier}+q" = "kill";
          "${modifier}+l" = "exec ${pkgs.swaylock}/bin/swaylock";
          "${modifier}+Shift+r" = "reload";
          "${modifier}+0" = ''mode "${mode}"'';
          "${modifier}+p" = "exec ${pkgs.nwg-displays}/bin/nwg-displays";
          "${modifier}+b" = "exec ${pkgs.blueman}/bin/blueman-manager";
          "${modifier}+F2" = "exec ${pkgs.pcmanfm}/bin/pcmanfm";
          "${modifier}+F3" = "exec ${pkgs.firefox}/bin/firefox";
          XF86AudioMute = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          XF86AudioMicMute = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          XF86MonBrightnessUp = "exec ${pkgs.brightnessctl}/bin/brightnessctl s +5%";
          XF86MonBrightnessDown = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%-";
          "Print" = "exec ${pkgs.shotman}/bin/shotman -C -c output";
          "${modifier}+Print" = "exec ${pkgs.shotman}/bin/shotman -C -c region";
          "${modifier}+Shift+s" = "exec ${pkgs.shotman}/bin/shotman -C -c region";
          XF86AudioLowerVolume = "exec ${pkgs.pulseaudio}/bin/pactl -- set-sink-volume 0 -5%";
          XF86AudioRaiseVolume = "exec ${pkgs.pulseaudio}/bin/pactl -- set-sink-volume 0 +5%";
        };
      modes = lib.mkOptionDefault {
        "${mode}" = {
          "r" = "exec reboot";
          "Shift+s" = "exec poweroff";
          "e" = "exec swaymsg exit";
          "l" = "exec ${pkgs.swaylock}/bin/swaylock; mode default";
          "s" =
            "exec ${pkgs.swaylock}/bin/swaylock; mode default; exec ${pkgs.systemd}/bin/systemctl suspend-then-hibernate;";
          "h" =
            "exec ${pkgs.swaylock}/bin/swaylock; mode default; exec ${pkgs.systemd}/bin/systemctl suspend-then-hibernate;";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
      };
      startup = [
        # {
        #   command = "${pkgs.signal-desktop-beta}/bin/signal-desktop-beta";
        #   always = false;
        # }
        # {
        #   command = "${pkgs.tailscale-systray}/bin/tailscale-systray";
        #   always = false;
        # }
        # {
        #   command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &";
        #   always = false;
        # }
        {
          command = "${pkgs.thunderbird}/bin/thunderbird";
          always = false;
        }
        # {
        #   command = "${pkgs.iwgtk}/bin/iwgtk -i";
        #   always = false;
        # }
        {
          command = "${pkgs.discord}/bin/discord";
          always = false;
        }
        {
          command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
          always = true;
        }
        {
          command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP";
          always = true;
        }
      ];
      bars = [
        {
          "hiddenState" = "hide";
          "mode" = "dock";
          "position" = "bottom";
          "extraConfig" = "modifier ${config.wayland.windowManager.sway.config.modifier}";
          "command" = "${pkgs.waybar}/bin/waybar";
        }
      ];
      output = {
        "Virtual-1" = {
          mode = "1920x1080@60Hz";
        };
        "*".bg = "${pic} fit";
      };
    };
    extraConfig = ''
            input "type:keyboard" {
                xkb_layout us,bg
                # xkb_variant ,phonetic
                xkb_options grp:alt_shift_toggle
            }
            smart_borders on
            for_window {
              [app_id = ".blueman-manager-wrapped"] floating enable
              [app_id = "nwg-displays"] floating enable
              [app_id = "com.github.finefindus.eyedropper"] floating enable
              [app_id = "org.kde.kcalc"] floating enable
              [app_id = "discord"] workspace number 1
              [app_id = "thunderbird"] workspace number 4
              [app_id = "org.twosheds.iwgtk"] floating enable
              [title = "Extension: (Bitwarden - Free Password Manager) - Bitwarden — Mozilla Firefox"] floating enable
              [window_role="pop-up"] floating enable
              [window_role="bubble"] floating enable
              [window_role="dialog"] floating enable
            }
            # Mouse
            bindgesture swipe:right workspace next;
            bindgesture swipe:left workspace prev;   
            # Allow container movements by pinching them
      		  bindgesture pinch:inward+up move up
      		  bindgesture pinch:inward+down move down
      		  bindgesture pinch:inward+left move left
      		  bindgesture pinch:inward+right move right
            # Open application on certain window
    '';
  };

  home.packages = with pkgs; [
    adwaita-icon-theme
    dconf
    nwg-displays
  ];
}
