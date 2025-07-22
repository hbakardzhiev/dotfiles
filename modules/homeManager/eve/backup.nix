{ pkgs, ... }:
{
  systemd.user.services.foo = {
    description = "Backup configuration";
    startAt = "01:00";
    serviceConfig = {
      ExecStart = "${pkgs.rsync}/bin/rsync -av --delete /run/media/et1/ /run/media/backup/ --exclude .git/";
    };
  };
}
