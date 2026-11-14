{
  lib,
  ...
}:
let
  inherit (lib.generators) mkLuaInline;

  # Hyprland 0.57 dropped the hyprlang format, so Home Manager writes the
  # Lua config from these settings. `mkLuaInline` keeps the dispatchers
  # readable while everything else stays plain Nix values.

  str = s: builtins.toJSON s;

  # hl.bind(key, dispatcher[, options])
  bind = key: dispatcher: options: {
    _args = [
      key
      (mkLuaInline dispatcher)
    ]
    ++ lib.optional (options != { }) options;
  };

  exec = key: command: bind key "hl.dsp.exec_cmd(${str command})" { };
  execOpt =
    key: command: options:
    bind key "hl.dsp.exec_cmd(${str command})" options;

  workspaces = lib.range 1 10;
  keyFor = n: if n == 10 then "0" else toString n;

  focusWorkspace =
    key: n: bind "SUPER + ${key}" "hl.dsp.focus({ workspace = ${str (toString n)} })" { };
  moveToWorkspace =
    key: n:
    bind "SUPER + SHIFT + ${key}"
      "hl.dsp.window.move({ workspace = ${str (toString n)}, follow = true })"
      { };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    settings = {
      monitor = {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      };

      # Autostart. Runs once, on the compositor's start event.
      on = {
        _args = [
          "hyprland.start"
          (mkLuaInline (
            lib.concatStrings [
              "function()\n"
              (lib.concatMapStrings (command: "  hl.exec_cmd(${str command})\n") [
                "hyprsunset"
                "mako"
                "thunderbird"
                "nextcloud"
                "tailscale systray"
                "udiskie --automount --no-tray"
              ])
              "end"
            ]
          ))
        ];
      };

      config = {
        general = {
          gaps_in = 0;
          gaps_out = 0;
          border_size = 1;
          layout = "dwindle";
        };

        decoration = {
          rounding = 0;
          blur.enabled = false;
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

        misc = {
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;
          background_color = "rgb(f6f6f6)";
        };
      };

      # Trackpoint curve from the old Sway/Omarchy setup.
      device = {
        name = "tpps/2-alps-trackpoint";
        accel_profile = "custom 200 0.0 0.0";
      };

      # Four-finger swipe switches workspaces.
      gesture = {
        fingers = 4;
        direction = "horizontal";
        action = "workspace";
      };

      # A list renders one hl.window_rule(...) call per element.
      window_rule = [
        {
          match.class = "^(thunderbird)$";
          workspace = "1";
        }
        {
          # GNOME apps report their .desktop name as the Wayland app_id.
          match.class = "^(org\\.gnome\\.Calculator)$";
          float = true;
        }
      ];

      bind = [
        # Launcher (regular fuzzel still available via SUPER + SPACE)
        (exec "SUPER + D" "fuzzel")

        # Power menu via super + alt + p (managed by Home Manager via powermenu.nix)
        (exec "SUPER + ALT + P" "fuzzel-power")

        # Applications
        (exec "SUPER + RETURN" "alacritty")
        (exec "SUPER + SHIFT + RETURN" "brave")
        (exec "SUPER + SHIFT + F" "nautilus")
        (exec "SUPER + SHIFT + N" "alacritty -e hx")
        (exec "SUPER + SHIFT + O" "obsidian")
        (exec "SUPER + B" "blueman-manager")

        # Windows
        (bind "SUPER + Q" "hl.dsp.window.close()" { })
        (bind "SUPER + W" "hl.dsp.layout(\"togglesplit\")" { })
        (bind "SUPER + T" "hl.dsp.window.float({ action = \"toggle\" })" { })
        (bind "SUPER + P" "hl.dsp.window.pseudo()" { })
        (bind "SUPER + F" "hl.dsp.window.fullscreen({ mode = \"fullscreen\" })" { })
        (bind "SUPER + ALT + F" "hl.dsp.window.fullscreen({ mode = \"maximized\" })" { })

        # Focus
        (bind "SUPER + LEFT" "hl.dsp.focus({ direction = \"left\" })" { })
        (bind "SUPER + RIGHT" "hl.dsp.focus({ direction = \"right\" })" { })
        (bind "SUPER + UP" "hl.dsp.focus({ direction = \"up\" })" { })
        (bind "SUPER + DOWN" "hl.dsp.focus({ direction = \"down\" })" { })
        (bind "SUPER + J" "hl.dsp.focus({ direction = \"left\" })" { })
        (bind "SUPER + K" "hl.dsp.focus({ direction = \"right\" })" { })
        (bind "ALT + TAB" "hl.dsp.window.cycle_next()" { })
        (bind "ALT + SHIFT + TAB" "hl.dsp.window.cycle_next({ next = false })" { })

        # Move windows
        (bind "SUPER + SHIFT + LEFT" "hl.dsp.window.move({ direction = \"left\" })" { })
        (bind "SUPER + SHIFT + RIGHT" "hl.dsp.window.move({ direction = \"right\" })" { })
        (bind "SUPER + SHIFT + UP" "hl.dsp.window.move({ direction = \"up\" })" { })
        (bind "SUPER + SHIFT + DOWN" "hl.dsp.window.move({ direction = \"down\" })" { })

        # Workspaces (numbered, plus next/previous workspace on this monitor)
        (bind "SUPER + TAB" "hl.dsp.focus({ workspace = \"m+1\" })" { })
        (bind "SUPER + SHIFT + TAB" "hl.dsp.focus({ workspace = \"m-1\" })" { })
        (bind "SUPER + CTRL + LEFT" "hl.dsp.focus({ workspace = \"e-1\" })" { })
        (bind "SUPER + CTRL + RIGHT" "hl.dsp.focus({ workspace = \"e+1\" })" { })
        (bind "SUPER + CTRL + J" "hl.dsp.focus({ workspace = \"e-1\" })" { })
        (bind "SUPER + CTRL + K" "hl.dsp.focus({ workspace = \"e+1\" })" { })
        (bind "SUPER + SHIFT + J" "hl.dsp.focus({ workspace = \"e-1\" })" { })
        (bind "SUPER + SHIFT + K" "hl.dsp.focus({ workspace = \"e+1\" })" { })

        # Scratchpad
        (bind "SUPER + S" "hl.dsp.workspace.toggle_special(\"scratchpad\")" { })
        (bind "SUPER + ALT + S" "hl.dsp.window.move({ workspace = \"special:scratchpad\", follow = false })"
          { }
        )

        # Resize mode
        (bind "SUPER + R" "hl.dsp.submap(\"resize\")" { })

        # Screenshots: slurp writes the region to stdout, grim reads it.
        (exec "PRINT" "grim - | wl-copy")
        (exec "SUPER + SHIFT + S" "slurp | grim -g - - | wl-copy")
        (exec "SUPER + PRINT" "hyprpicker -a")

        # Session. `loginctl lock-session` only emits logind's Lock signal;
        # something has to listen and draw the lock, and hypridle used to be
        # that listener. With hypridle gone, start hyprlock directly.
        (exec "SUPER + L" "pidof hyprlock || hyprlock")

        # Quick power actions (removed: reboot, shutdown, logout)
        # (SUPER + Alt + R, SUPER + Alt + S, SUPER + Alt + L are no longer needed)

        # Media keys
        (exec "XF86AudioMute" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        (exec "XF86AudioMicMute" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
        (exec "XF86AudioPlay" "playerctl play-pause")
        (exec "XF86AudioPause" "playerctl play-pause")
        (exec "XF86AudioNext" "playerctl next")
        (exec "XF86AudioPrev" "playerctl previous")
        (exec "F1" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        (exec "F4" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")

        # Repeating keys
        (execOpt "XF86AudioRaiseVolume" "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+" {
          locked = true;
          repeating = true;
        })
        (execOpt "XF86AudioLowerVolume" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" {
          locked = true;
          repeating = true;
        })
        (execOpt "XF86MonBrightnessUp" "brightnessctl set 5%+" {
          locked = true;
          repeating = true;
        })
        (execOpt "XF86MonBrightnessDown" "brightnessctl set 5%-" {
          locked = true;
          repeating = true;
        })
        (execOpt "F2" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" {
          locked = true;
          repeating = true;
        })
        (execOpt "F3" "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+" {
          locked = true;
          repeating = true;
        })
        (execOpt "F5" "brightnessctl set 5%-" {
          locked = true;
          repeating = true;
        })
        (execOpt "F6" "brightnessctl set 5%+" {
          locked = true;
          repeating = true;
        })
      ]
      ++ lib.concatMap (n: [
        (focusWorkspace (keyFor n) n)
        (moveToWorkspace (keyFor n) n)
      ]) workspaces;
    };

    submaps.resize.settings.bind = [
      (bind "J" "hl.dsp.window.resize({ x = -20, y = 0, relative = true })" { repeating = true; })
      (bind "K" "hl.dsp.window.resize({ x = 20, y = 0, relative = true })" { repeating = true; })
      (bind "LEFT" "hl.dsp.window.resize({ x = -20, y = 0, relative = true })" { repeating = true; })
      (bind "RIGHT" "hl.dsp.window.resize({ x = 20, y = 0, relative = true })" { repeating = true; })
      (bind "UP" "hl.dsp.window.resize({ x = 0, y = -20, relative = true })" { repeating = true; })
      (bind "DOWN" "hl.dsp.window.resize({ x = 0, y = 20, relative = true })" { repeating = true; })
      (bind "ESCAPE" "hl.dsp.submap(\"reset\")" { })
      (bind "RETURN" "hl.dsp.submap(\"reset\")" { })
    ];
  };
}
