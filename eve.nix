{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  hostname = "eve";
  getNixFiles = import ./modules/functions/getNixFiles.nix;
  filesToImport =
    getNixFiles {
      path = ./modules/system/shared;
      inherit lib;
    }
    ++ getNixFiles {
      path = ./modules/system/eve-bob;
      inherit lib;
    }
    ++ getNixFiles {
      path = ./modules/system/eve;
      inherit lib;
    };
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sops.nix
  ] ++ filesToImport;

  system.stateVersion = "24.05"; # Did you read the comment?
  networking = {
    firewall.enable = true;
    # firewall.allowedUDPPorts = [];
    hostName = hostname;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    2283
  ];
  # services.nextcloud = {
  #   enable = true;
  #   package = pkgs.nextcloud30;
  #   # hostName = "eveee.v6.army";
  #   hostName = "bakarh.ddns.net";
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
  #     dbtype = "pgsql";
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

  services.immich = {
    enable = true;
    port = 2283;
    mediaLocation = "/run/media/et1";
    openFirewall = true;
    settings = {
      backup.database.enabled = true;
      server.externalDomain = "https://bakarh.ddns.net";
    };
  };
  users.users.immich.extraGroups = [ "video" "render" ];
  services.nginx = {
    enable = true;
    virtualHosts."bakarh.ddns.net" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.immich.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    certs = {
      "bakarh.ddns.net".email = "h.bakardzhiev@gmx.com";
    };
  };

  # Systemd service for /run/media/backup
  systemd.services.fix-ntfs-backup = {
    description = "Run ntfsfix on backup drive before mounting";
    wantedBy = [ "multi-user.target" ];
    before = [ "run-media-backup.mount" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ntfs3g}/bin/ntfsfix /dev/disk/by-uuid/19F41D271DCA2DF1";
      RemainAfterExit = true;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
  # Systemd service for /run/media/et1
  systemd.services.fix-ntfs-et1 = {
    description = "Run ntfsfix on et1 drive before mounting";
    wantedBy = [ "multi-user.target" ];
    before = [ "run-media-et1.mount" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ntfs3g}/bin/ntfsfix /dev/disk/by-uuid/D01235C71235B378";
      RemainAfterExit = true;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
  # External strorage
  fileSystems."/run/media/backup" = {
    device = "/dev/disk/by-uuid/19F41D271DCA2DF1";
    fsType = "ntfs-3g";
    options = [ "defaults" "nofail" ];
  };
  fileSystems."/run/media/et1" = {
    device = "/dev/disk/by-uuid/D01235C71235B378";
    fsType = "ntfs-3g";
    options = [ "nofail" "uid=immich" "gid=immich" "umask=022" ];
  };
}
