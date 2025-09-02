{ pkgs, pkgs-unstable, ... }:
let
  terminal = "${pkgs.alacritty}/bin/alacritty";
  wofiLauncher = "${pkgs.wofi}/bin/wofi";
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  clipboard = "${pkgs.wl-clipboard}";
  wl-paste = "${clipboard}/bin/wl-paste";
  wl-copy = "${clipboard}/bin/wl-copy";
  launcher = "${wofiLauncher} --exec-search --show drun --allow-images --allow-markup --insensitive matching=fuzzy";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = false;

    settings = {
      "$mod" = "SUPER";
      # ── Appearance ───────────────────────────────
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 2;
        allow_tearing = false;
      };
      decoration = {
        rounding = 8;
        blur = {
          enabled = false;
        };

        active_opacity = 1.0;
        inactive_opacity = 1.0;
      };
      animations = {
        enabled = false;
      };
      misc = {
        vrr = 1;
        vfr = true;
        render_unfocused_fps = 15;

        # Performance optimizations
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        always_follow_on_dnd = true;
        layers_hog_keyboard_focus = true;
        animate_manual_resizes = false;
        animate_mouse_windowdragging = false;
        enable_swallow = true;
        swallow_regex = "^(Alacritty)$";
      };

      # Back and forth
      binds = {
        allow_workspace_cycles = true;
      };

      # ── Intel-optimized rendering ────────────────
      render = {
        explicit_sync = 1; # Lower value for Intel
        direct_scanout = true;
      };

      # ── Cursor optimizations ─────────────────────
      cursor = {
        no_hardware_cursors = false;
        enable_hyprcursor = true;
      };

      # ── Input ────────────────────────────────────
      input = {
        # Language change
        kb_layout = "us,bg";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        sensitivity = 0;

        # Performance additions
        repeat_rate = 50;
        repeat_delay = 300;
        numlock_by_default = true;
        resolve_binds_by_sym = 1;
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 4;
      };
      # ── Keybinds ─────────────────────────────────
      bind = [
        # Clipboard
        "$mod, V, exec, ${cliphist} list | ${wofiLauncher} --dmenu | ${cliphist} decode | ${wl-copy}"

        # Color picker
        "$mod, C, exec, ${pkgs.hyprpicker}/bin/hyprpicker -a -q" # automatically copy to clipboard and disable logging

        # Back and forth
        "ALT, Tab, workspace, previous"

        # Window actions
        "$mod, Q, killactive"
        "$mod, L, exec, hyprlock"
        "$mod SHIFT, R, exec, hyprctl reload"

        # Focus movement
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        # Move windows
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"

        # Move windows (arrows)
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # Sway-style tiling orientation
        "$mod, W, exec, hyprctl dispatch togglegroup"

        # Workspaces (switch)
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move windows to workspaces
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # App key mappings
        "$mod, P, exec, hyprctl keyword monitor 'eDP-1, disable'"
        "$mod, B, exec, ${pkgs.bluejay}/bin/bluejay"

        # Launchers
        "$mod, Return, exec, ${terminal}"
        "$mod, D, exec, ${launcher}"

        # Workspaces (cycle with Ctrl+Super+Arrow)
        "CTRL $mod, left, workspace, -1"
        "CTRL $mod, right, workspace, +1"

        # Volume + Brightness
        ", XF86AudioMute, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle"
        ", XF86AudioLowerVolume, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ", XF86AudioRaiseVolume, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 5%-"
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s +5%"
        # Screenshot
        ", Print, exec, ${pkgs.grim}/bin/grim -g \"$(slurp)\" - | ${wl-copy}"
      ];

      # Mouse binds
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      # ── Lid Switch Bindings ──────────────────────
      bindl = [
        ", switch:off:Lid Switch, exec, hyprctl keyword monitor 'eDP-1, preferred, auto, 1, vrr, 1'"
        ", switch:on:Lid Switch, exec, hyprctl keyword monitor 'eDP-1, disable'"
      ];

      # ── Autostart ────────────────────────────────
      exec-once = [
        "${pkgs.iwgtk}/bin/iwgtk -i"
        "${pkgs.tailscale-systray}/bin/tailscale-systray"
        "${pkgs.nextcloud-client}/bin/nextcloud"
        "${pkgs-unstable.waybar}/bin/waybar"
        "[workspace 1 silent] ${pkgs.brave}/bin/brave https://mail.google.com/mail/u/0/#all"
        "[workspace 2 silent] ${terminal}"
        "[workspace 3 silent] ${pkgs.obsidian}/bin/obsidian"
        "${wl-paste} --type text --watch ${cliphist} store"
        "${wl-paste} --type image --watch ${cliphist} store"
      ];
      # ── Monitor ──────────────────────────────────
      monitor = [ ",preferred,auto,1,vrr,1" ];
      # ── Window Rules ─────────────────────────────
      windowrulev2 = [
        "maxsize 700 300, title:^(Bluejay)$"
        "minsize 700 300, title:^(Bluejay)$"
        "float, title:^(Bluejay)$"

        "float, class:^(blueman-manager)$"
        "float, title:^(Picture-in-Picture)$"
        "float, title:^(Kcalc)$"
        "float, title:^(iwgtk)$"
      ];
      # ── Gestures ─────────────────────────────────
      bindg = [
        ", swipe:3:r, workspace, r+1"
        ", swipe:3:l, workspace, previous"
      ];
    };
  };
  # Extra packages you’ll want available
  home.packages = with pkgs; [
    adwaita-icon-theme
    dconf
    grim
    slurp
  ];
}
