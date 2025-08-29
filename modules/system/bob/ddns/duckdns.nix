{ config, lib, ... }:
 let
  cfg = config.cloud.ddns;
in
{
  options.cloud.ddns = {
    enable = lib.mkEnableOption "DDNS";
    hostname = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "DuckDNS hostname to update";
      default = "";
    };
  };

  config = { 
    sops.secrets."ddns/duckdns/token" = { };
    services.duckdns = {
      enable = true;
      domains = cfg.hostname;
      tokenFile = config.sops.secrets."ddns/duckdns/token".path;
    };
  };
}
