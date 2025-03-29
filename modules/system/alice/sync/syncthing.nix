{ config, ... }:
let baseDir = "/drives/data/syncthing";
in
{
  services.syncthing = {
    enable = true;
    configDir = "${baseDir}";
    user = "alice";
    group = "users";

    # Override GUI and manual changes
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = {
        "android" = {
          id = config.sops.secrets."syncthing/pixel/id".path;
        };
        "laptop" = {
          id = config.sops.secrets."syncthing/alice/id".path;
        };
      };

      folders = {
        "android-sync" = {
          path = "${baseDir}/android-sync";
          devices = [ "android" ];
          type = "receiveonly";
          ignoreDelete = true;
        };
      };

      # Disable Anonymous Usage Reporting
      options = {
        urAccepted = 0;  # 0 or -1 disables usage reporting
      };
    };
  };
}
