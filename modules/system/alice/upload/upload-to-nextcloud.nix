{ config, pkgs, ... }:
let 
  serviceName = "upload-obsidian-to-nextcloud";
in
{
  systemd.user.services.${serviceName} = {
    startAt = "9:00";
    path = with pkgs; [
      nextcloud-client
    ];
    script = ''
      #!/bin/bash
      username=$(cat ${config.sops.secrets."nextcloud/username".path})
      password=$(cat ${config.sops.secrets."nextcloud/Password".path})
            
      nextcloudcmd --user "$username" --password "$password" --exclude ~/.config/Nextcloud/sync-exclude.lst --path /et1/obsidian /drives/data/obsidian https://bakarh.ddns.net 
    '';
  };

  systemd.user.services.upload-configurationBackup-and-passwords-to-nextcloud = {
    startAt = "9:00";
    path = with pkgs; [
      nextcloud-client
    ];
    script = ''
      #!/bin/bash
      username=$(cat ${config.sops.secrets."nextcloud/username".path})
      password=$(cat ${config.sops.secrets."nextcloud/Password".path})

      nextcloudcmd --user "$username" --password "$password" --exclude ~/.config/Nextcloud/sync-exclude.lst --path /et1/HristoMiA2 /drives/data/configurationBackup https://bakarh.ddns.net 
      nextcloudcmd --user "$username" --password "$password" --exclude ~/.config/Nextcloud/sync-exclude.lst --path /et1/Passwords /drives/data/Passwords https://bakarh.ddns.net 
    '';
  };
}
