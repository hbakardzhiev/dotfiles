{
  lib,
  pkgs,
  modulesPath,
  pkgs-unstable,
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
  ]
  ++ filesToImport;

  config = {
    system.stateVersion = "24.05"; # Did you read the comment?

    tools.networking = {
      enable = true;
      hostname = hostname;
    };

    cloud.nextcloud = {
      enable = true;
      hostname = [
        # To be used as a general hostname
        "nextcloud.tail6dbb0b.ts.net"
        # tailscale hostnames
        "100.80.185.72"
      ];
    };

    services.opencode = {
      enable = true;
      port = 4096;
      package = pkgs-unstable.opencode.overrideAttrs (old: {
        node_modules = old.node_modules.overrideAttrs (_: {
          outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
        });
      });
    };

    # -----------------
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
      options = [
        "defaults"
        "nofail"
      ];
    };
    fileSystems."/run/media/et1" = {
      device = "/dev/disk/by-uuid/D01235C71235B378";
      fsType = "ntfs-3g";
      options = [
        "defaults"
        "nofail"
      ];
    };
  };
}
