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
        ExecStart = "${pkgs.rsync}/bin/rsync -av --delete /run/media/et1/ /run/media/backup/ --exclude .git/";
      };
    };
  };
}
