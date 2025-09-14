{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.tools.android;
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
  # Define options for lid switch behavior
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
    environment.systemPackages = lib.mkIf cfg.enableAndroidStudio [ pkgs.android-studio ];
  };
}
