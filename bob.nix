{
  lib,
  modulesPath,
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
  ]
  ++ filesToImport;

  config = {
    system.stateVersion = "24.05"; # Did you read the comment?

    cloud.dynv6 = {
      enable = true;
      hostname = "v6.army.bob";
    };
    cloud.ddns = {
      enable = true;
      hostname = [ "bobbb.duckdns.org" ];
    };
    cloud.immich = {
      enable = true;
      hostname = "sofiaaa.duckdns.org";
    };
    tools.lidswitch = {
      enable = true;
      enableBattery = true;
    };
    tools.networking = {
      enable = true;
      hostname = hostname;
    };
    custom.containers.docker = {
      enable = true;
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

    # External storage
    fileSystems."/run/media/et1" = {
      device = "/dev/disk/by-uuid/d3472797-efc9-4327-9157-0fb30baa00b9";
      fsType = "ext4";
      options = [ "defaults" ];
    };
  };
}
