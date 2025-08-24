{ pkgs, ... }:
let
  terminal = "${pkgs.alacritty}/bin/alacritty";
  launcher = "${pkgs.wofi}/bin/wofi --show drun --allow-images --allow-markup --insensitive";
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
        inactive_opacity = 0.9;
      };
      animations = {
        enabled = false;
      };
      misc = {
        vrr = 1;
        vfr = true;
        render_unfocused_fps = 15;
      };
      # ── Input ────────────────────────────────────
      input = {
        kb_layout = "us,bg";
        follow_mouse = 1;
        sensitivity = 0;
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 4;
      };
      # ── Keybinds ─────────────────────────────────
      bind = [
        # Language change
        "$mod, SPACE, exec, hyprctl switchxkblayout at-translated-set-2-keyboard next"
        # Launchers
        "$mod, Return, exec, ${terminal}"
        "$mod, D, exec, ${launcher}"
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
        "$mod, E, layoutmsg, addmaster"
        "$mod, W, layoutmsg, removemaster"
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
        ", Print, exec, ${pkgs.grim}/bin/grim -g \"$(slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
      ];

      # ── Autostart ────────────────────────────────
      exec-once = [
        "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
        "${pkgs.tailscale-systray}/bin/tailscale-systray"
        "${pkgs.nextcloud-client}/bin/nextcloud"
        # "${pkgs.hyprpanel}/bin/hyprpanel"
        "${pkgs.waybar}/bin/waybar"
        "[workspace 1 silent] ${pkgs.brave}/bin/brave https://mail.google.com/mail/u/0/#all"
        "[workspace 2 silent] ${terminal}"
      ];
      # ── Monitor ──────────────────────────────────
      monitor = [ ",preferred,auto,1,vrr,1" ];
      # ── Window Rules ─────────────────────────────
      windowrulev2 = [
        "float, class:^(blueman-manager)$"
        "float, class:^(nwg-displays)$"
        "float, title:^(Picture-in-Picture)$"
        "float, title:^(kcalc)$"
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
    nwg-displays
    hyprutils
    grim
    slurp
    wl-clipboard # screenshots
  ];
}
