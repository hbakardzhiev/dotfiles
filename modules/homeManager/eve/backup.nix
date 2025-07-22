{ pkgs, ... }:
{
  home-manager.users.alice = {
    systemd.user.services.foo = {
      Unit = {
        Description = "Backup configuration";
      };
      Service = {
        ExecStart = "${pkgs.rsync}/bin/rsync -av --delete /run/media/et1/ /run/media/backup/ --exclude .git/";
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
      startAt = "01:00";
    };
  };
}
