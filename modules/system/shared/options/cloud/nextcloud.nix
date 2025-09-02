{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cloud.nextcloud;
in
{
  # Define options for lid switch behavior
  options.cloud.nextcloud = {
    enable = lib.mkEnableOption "Enable networking";
    hostname = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Hostnames to set";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.length cfg.hostname != 0;
        message = "Hostnames must be set";
      }
    ];
    security.sops.nextcloud.enable = true;

    networking.firewall.allowedTCPPorts = [
      80
      443
      # 2283
    ];
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = builtins.head cfg.hostname;
      https = true;
      settings.overwriteprotocol = "https";
      # Let NixOS install and configure the database automatically.
      database.createLocally = true;
      # Let NixOS install and configure Redis caching automatically.
      configureRedis = true;
      # Increase the maximum file upload size to avoid problems uploading videos.
      maxUploadSize = "1G";
      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        inherit groupfolders;
      };
      config = {
        adminuser = "root";
        adminpassFile = config.sops.secrets."nextcloud/Password".path;
        dbtype = "sqlite";
      };
      settings = {
        trusted_domains = cfg.hostname;
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\HEIC"
        ];
      };
    };
    services.nginx.virtualHosts = {
      ${config.services.nextcloud.hostName} = {
        forceSSL = true;
        enableACME = true;
      };
    };
    security.acme = {
      acceptTerms = true;
      certs = {
        ${config.services.nextcloud.hostName}.email = "h.bakardzhiev@gmx.com";
      };
    };
  };
}
