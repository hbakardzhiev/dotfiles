{ pkgs, ... }:
{
  systemd.user.services = {
    foo = {
      Unit = {
        Description = "Backup configuration";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        # ExecStart = "${pkgs.coreutils-full}/bin/cp -u -r /etc/nixos/ /drives/data/configurationBackup/configuration/";
        ExecStart = "${pkgs.rsync}/bin/rsync -av --delete /etc/nixos/ /drives/data/configurationBackup/configuration/ --exclude .git/";
      };
    };
  };
}
