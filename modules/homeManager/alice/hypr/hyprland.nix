{
  lib,
  ...
}:
let
  # Workspaces 1-10, with 0 as the tenth key, like Sway/Omarchy.
  workspaces = lib.range 1 10;
  keyFor = n: if n == 10 then "0" else toString n;

  workspaceBinds = lib.concatMap (n: [
    "SUPER, ${keyFor n}, workspace, ${toString n}"
    "SUPER SHIFT, ${keyFor n}, movetoworkspace, ${toString n}"
  ]) workspaces;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Plain hyprland.conf, generated from these settings. Lua is the newer
    # format, but hyprlang is what the rest of the module system documents.
    configType = "hyprlang";

    settings = {
      monitor = [ ",preferred,auto,1" ];

      exec-once = [
        "hyprsunset"
        "mako"
        "thunderbird"
        "udiskie --automount --no-tray"
      ];

      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 1;
        layout = "dwindle";
      };

      decoration = {
        rounding = 0;
      };

      animations = {
        enabled = false;
      };

      input = {
        kb_layout = "us,bg";
        kb_variant = ",bds";
        kb_options = "compose:caps,shift:both_capslock_cancel,grp:lalt_lshift_toggle";
        repeat_rate = 40;
        repeat_delay = 250;
        numlock_by_default = true;
        sensitivity = 0.35;
        accel_profile = "flat";
      };

      # Trackpoint curve from the old Sway/Omarchy setup.
      device = [
        {
          name = "tpps/2-alps-trackpoint";
          accel_profile = "custom 200 0.0 0.0";
        }
      ];

      # Four-finger swipe switches workspaces.
      gesture = [ "4, horizontal, workspace" ];

      misc = {
        disable_hyprland_logo = true;
        force_default_wallpaper = 0;
        background_color = "0xfff6f6f6";
      };

      windowrule = [
        "workspace 1, class:^(thunderbird)$"
      ];

      bind = [
        # Launcher
        "SUPER, D, exec, fuzzel"
        "SUPER, SPACE, exec, fuzzel"

        # Applications
        "SUPER, RETURN, exec, alacritty"
        "SUPER SHIFT, RETURN, exec, brave"
        "SUPER SHIFT, F, exec, nautilus"
        "SUPER SHIFT, N, exec, alacritty -e hx"
        "SUPER SHIFT, O, exec, obsidian"

        # Windows
        "SUPER, Q, killactive"
        "SUPER, W, layoutmsg, togglesplit"
        "SUPER, T, togglefloating"
        "SUPER, P, pseudo"
        "SUPER, F, fullscreen, 0"
        "SUPER ALT, F, fullscreen, 1"

        # Focus
        "SUPER, LEFT, movefocus, l"
        "SUPER, RIGHT, movefocus, r"
        "SUPER, UP, movefocus, u"
        "SUPER, DOWN, movefocus, d"
        "SUPER, J, movefocus, l"
        "SUPER, K, movefocus, r"
        "ALT, TAB, cyclenext"
        "ALT SHIFT, TAB, cyclenext, prev"

        # Move windows
        "SUPER SHIFT, LEFT, movewindow, l"
        "SUPER SHIFT, RIGHT, movewindow, r"
        "SUPER SHIFT, UP, movewindow, u"
        "SUPER SHIFT, DOWN, movewindow, d"

        # Workspaces (numbered, plus next/previous workspace on this monitor)
        "SUPER, TAB, workspace, m+1"
        "SUPER SHIFT, TAB, workspace, m-1"
        "SUPER CTRL, LEFT, workspace, e-1"
        "SUPER CTRL, RIGHT, workspace, e+1"
        "SUPER CTRL, J, workspace, e-1"
        "SUPER CTRL, K, workspace, e+1"
        "SUPER SHIFT, J, workspace, e-1"
        "SUPER SHIFT, K, workspace, e+1"

        # Scratchpad
        "SUPER, S, togglespecialworkspace, scratchpad"
        "SUPER ALT, S, movetoworkspace, special:scratchpad"

        # Resize mode
        "SUPER, R, submap, resize"

        # Screenshots: slurp writes the region to stdout, grim reads it.
        ", PRINT, exec, grim - | wl-copy"
        "SUPER SHIFT, S, exec, slurp | grim -g - - | wl-copy"
        "SUPER, PRINT, exec, hyprpicker -a"

        # Session
        "SUPER ALT, L, exec, loginctl lock-session"

        # Media keys
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", F1, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", F4, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ]
      ++ workspaceBinds;

      # Repeating keys.
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", F2, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", F3, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", F5, exec, brightnessctl set 5%-"
        ", F6, exec, brightnessctl set 5%+"
      ];
    };

    submaps.resize.settings.bind = [
      ", J, resizeactive, -20 0"
      ", K, resizeactive, 20 0"
      ", LEFT, resizeactive, -20 0"
      ", RIGHT, resizeactive, 20 0"
      ", UP, resizeactive, 0 -20"
      ", DOWN, resizeactive, 0 20"
      ", ESCAPE, submap, reset"
      ", RETURN, submap, reset"
    ];
  };
}
