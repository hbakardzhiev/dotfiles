{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.cloud.nextcloud.client.upload;
  serviceName = "upload-to-nextcloud";
in
{
  # Define options for lid switch behavior
  options.cloud.nextcloud.client.upload = {
    enable = lib.mkEnableOption "Enable nextcloud auto upload";
  };
  config = lib.mkIf cfg.enable {
    security.sops.nextcloud.enable = true;

    environment.systemPackages = with pkgs; [
      nextcloud-client
    ];
    systemd.user.services.${serviceName} = {
      startAt = "10:00";
      path = with pkgs; [
        nextcloud-client
      ];
      script = ''
        #!/bin/bash
        username=$(cat ${config.sops.secrets."nextcloud/username".path})
        password=$(cat ${config.sops.secrets."nextcloud/Password".path})
              
        nextcloudcmd --user "$username" --password "$password" --trust --exclude ~/.config/Nextcloud/sync-exclude.lst --path /et1/obsidian /drives/data/obsidian https://bakarh.ddns.net 
        # nextcloudcmd --user "$username" --password "$password" --trust --exclude ~/.config/Nextcloud/sync-exclude.lst --path /et1/Kraimorie/obsidian /drives/data/obsidian https://100.84.168.15 
      '';
    };

    systemd.user.services.upload-configurationBackup-and-passwords-to-nextcloud = {
      startAt = "10:00";
      path = with pkgs; [
        nextcloud-client
      ];
      script = ''
        #!/bin/bash
        username=$(cat ${config.sops.secrets."nextcloud/username".path})
        password=$(cat ${config.sops.secrets."nextcloud/Password".path})

        nextcloudcmd --user "$username" --password "$password" --trust  --exclude ~/.config/Nextcloud/sync-exclude.lst --path /et1/HristoMiA2 /drives/data/configurationBackup https://bakarh.ddns.net 
        # nextcloudcmd --user "$username" --password "$password" --trust --exclude ~/.config/Nextcloud/sync-exclude.lst --path /et1/Kraimorie/HristoMiA2 /drives/data/configurationBackup https://100.84.168.15
        nextcloudcmd --user "$username" --password "$password" --trust  --exclude ~/.config/Nextcloud/sync-exclude.lst --path /et1/Passwords /drives/data/Passwords https://bakarh.ddns.net 
        # nextcloudcmd --user "$username" --password "$password" --trust --exclude ~/.config/Nextcloud/sync-exclude.lst --path /et1/Kraimorie/Passwords /drives/data/Passwords https://100.84.168.15
      '';
    };

  };
}
