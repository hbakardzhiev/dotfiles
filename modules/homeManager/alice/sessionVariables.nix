{ pkgs, hostname, ... }:
{
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
    MOZ_DBUS_REMOTE = "1";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland";
    # needs qt5.qtwayland in systemPackages
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # Fix for some Java AWT applications (e.g. Android Studio),
    # use this if they aren't displayed properly:
    _JAVA_AWT_WM_NONREPARENTING = 1;
    # gtk applications on wayland
    GDK_BACKEND = "wayland";
    SUDO_EDITOR = "${pkgs.helix.outPath}/bin/hx";
    NIXOS_XDG_OPEN_USE_PORTAL = "1";
    GTK_USE_PORTAL = "1";
    CLUTTER_BACKEND = "wayland";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    LIBVA_DRIVER_NAME = "iHD";
    WORKSPACE_BASE = "/home/${hostname}/workspace";
    NIXOS_OZONE_WL = 1;
    XDG_RUNTIME_DIR = "/run/user/$UID";
    HOME = "/home/alice";

    # If mouse cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = 1;
  };
}
