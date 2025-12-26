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
    sops.secrets."ddns/duckdns/token" = lib.mkIf cfg.enable { };
    services.duckdns = lib.mkIf cfg.enable {
      enable = true;
      domains = [ cfg.hostname ];
      tokenFile = config.sops.secrets."ddns/duckdns/token".path;
    };

    services.immich = lib.mkIf cfg.enable {
      enable = true;
      host = "localhost";
      port = portForImmich;
      openFirewall = true;
      mediaLocation = "/run/media/et1";
    };

    services.caddy = lib.mkIf cfg.enable {
      enable = true;
      virtualHosts."${cfg.hostname}" = {
        extraConfig = ''
          reverse_proxy localhost:${builtins.toString portForImmich}
        '';
      };
    };
  };
}
