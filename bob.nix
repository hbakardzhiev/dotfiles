{
  lib,
  modulesPath,
  config,
  pkgs,
  ...
}:
let
  hostname = "bob";
  getNixFiles = import ./modules/functions/getNixFiles.nix;
  filesToImport =
    getNixFiles {
      path = ./modules/system/${hostname};
      inherit lib;
    }
    ++ getNixFiles {
      path = ./modules/system/shared;
      inherit lib;
    }
    ++ getNixFiles {
      path = ./modules/system/eve-bob;
      inherit lib;
    };
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sops.nix
  ] ++ filesToImport;

  services.logind.lidSwitchExternalPower = "ignore";

  system.stateVersion = "24.05"; # Did you read the comment?
  networking = {
    firewall.enable = true;
    # firewall.allowedUDPPorts = [];
    hostName = hostname;
  };

  # services.samba = {
  #   enable = true;
  #   openFirewall = true;
  #   settings = {
  #     global = {
  #       "workgroup" = "WORKGROUP";
  #       "server string" = "smbnix";
  #       "netbios name" = "smbnix";
  #       security = "user";
  #       "hosts allow" = "192.168.0. 127.0.0.1 localhost 0.0.0.0/0";
  #     };
  #     public = {
  #       "path" = "/run/media/et1";
  #       "browseable" = "yes";
  #       "read only" = "no";
  #       "guest ok" = "yes";
  #       "create mask" = "0777";
  #       "directory mask" = "0777";
  #     };
  #   };
  # };
  # services.samba-wsdd = {
  #   enable = true;
  #   openFirewall = true;
  # };

  # services.nextcloud = {
  #   enable = true;
  #   package = pkgs.nextcloud30;
  #   hostName = "100.84.168.15";
  #   # hostName = "bakarh.ddns.net";
  #   https = true;
  #   settings.overwriteprotocol = "https";
  #   # Let NixOS install and configure the database automatically.
  #   database.createLocally = true;
  #   # Let NixOS install and configure Redis caching automatically.
  #   configureRedis = true;
  #   # Increase the maximum file upload size to avoid problems uploading videos.
  #   maxUploadSize = "1G";
  #   autoUpdateApps.enable = true;
  #   extraAppsEnable = true;
  #   extraApps = with config.services.nextcloud.package.packages.apps; {
  #     # List of apps we want to install and are already packaged in
  #     # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
  #     inherit groupfolders;
  #   };
  #   config = {
  #     adminuser = "root";
  #     adminpassFile = config.sops.secrets."nextcloud/Password".path;
  #   };
  #   settings.enabledPreviewProviders = [
  #     "OC\\Preview\\BMP"
  #     "OC\\Preview\\GIF"
  #     "OC\\Preview\\JPEG"
  #     "OC\\Preview\\Krita"
  #     "OC\\Preview\\MarkDown"
  #     "OC\\Preview\\MP3"
  #     "OC\\Preview\\OpenDocument"
  #     "OC\\Preview\\PNG"
  #     "OC\\Preview\\TXT"
  #     "OC\\Preview\\XBitmap"
  #     "OC\\Preview\\HEIC"
  #   ];
  # };
  # services.nginx.virtualHosts = {
  #   ${config.services.nextcloud.hostName} = {
  #     forceSSL = true;
  #     enableACME = true;
  #   };
  # };
  # security.acme = {
  #   acceptTerms = true;
  #   certs = {
  #     ${config.services.nextcloud.hostName}.email = "h.bakardzhiev@gmx.com";
  #   };
  # };

  # External storage
  fileSystems."/run/media/et1" = {
    device = "/dev/disk/by-uuid/d3472797-efc9-4327-9157-0fb30baa00b9";
    fsType = "ext4";
    options = [ "defaults" ];
  };
}
