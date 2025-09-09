{ config, lib, ... }:
let
  cfg = config.cloud.dynv6;
in
{
  options.cloud.dynv6 = {
    enable = lib.mkEnableOption "DynV6";
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "DynV6 hostname to update. Must be defined in sops-secret.";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.hostname != "";
        message = "Hostname must be set";
      }
    ];
    sops.secrets."${cfg.hostname}" = {};

    services.ddclient = {
      enable = true;
      configFile = config.sops.secrets."${cfg.hostname}".path;
    };
  };
}
