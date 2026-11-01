{ config, lib, ... }:
let
  cfg = config.cloud.immich;
  portForImmich = 2283;
in
{
  options.cloud.immich = {
    enable = lib.mkEnableOption "immich";
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "immich hostname to update";
      default = "";
    };
  };

  config = {
    services.immich = lib.mkIf cfg.enable {
      enable = true;
      host = "localhost";
      port = portForImmich;
      openFirewall = false;
      mediaLocation = "/run/media/et1";
    };

  };
}
