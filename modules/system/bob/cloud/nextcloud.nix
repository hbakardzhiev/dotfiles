{ pkgs, config, lib, ... }:

let
  cfg = config.cloud.nextcloud;
in
{
  options.cloud.nextcloud = {
    enable = lib.mkEnableOption "Nextcloud";
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Nextcloud hostname";
      default = "";
    };
  };

  config = {
    # Assertions for validation
    assertions = lib.optionals cfg.enable [
      {
        assertion = cfg.hostname != "";
        message = "cloud.nextcloud.hostname must be a non-empty string when cloud.nextcloud.enable is true.";
      }
    ];

    # Enable Nextcloud only if cfg.enable is true
    services.nextcloud = lib.mkIf cfg.enable {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = cfg.hostname;
      https = true;
      settings.overwriteprotocol = "https";
      database.createLocally = true;
      configureRedis = true;
      maxUploadSize = "1G";
      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit groupfolders;
      };
      config = {
        adminuser = "root";
        adminpassFile = config.sops.secrets."nextcloud/Password".path;
      };
      settings.enabledPreviewProviders = [
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

    # Secrets for Nextcloud
    sops.secrets = lib.mkIf cfg.enable {
      "nextcloud/username" = {
        owner = "alice";
      };
      "nextcloud/Password" = {
        owner = "alice";
      };
    };
  };
}
