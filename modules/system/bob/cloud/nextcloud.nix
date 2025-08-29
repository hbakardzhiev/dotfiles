{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.cloud.nextcloud = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable Nextcloud service";
      default = false;
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Nextcloud hostname";
      default = "";
    };

  };
  config =
    let
      cfg = config.cloud.nextcloud;
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.hostname == "";
          message = "hostname must be defined";
        }
      ];
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud31;
        hostName = cfg.hostname;
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
    };
}
