{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.tools.android;
  android-studio-wayland = pkgs-unstable.android-studio.override { forceWayland = true; };
in
{
  options.tools.android = {
    enable = lib.mkEnableOption "Enable android";
    username = lib.mkOption {
      type = lib.types.str;
      description = "Username to set";
      default = "";
    };
    enableAndroidStudio = lib.mkEnableOption "Enable Android Studio";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.username != "";
        message = "Username must be set";
      }
    ];
    programs.adb.enable = true;
    users.users.${cfg.username}.extraGroups = [ "adbusers" ];
    services.udev.packages = [
      pkgs.android-udev-rules
    ];
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = lib.mkIf cfg.enableAndroidStudio [
      android-studio-wayland
    ];
  };
}
