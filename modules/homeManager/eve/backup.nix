{ pkgs, ... }:
{
  systemd.user.services.foo = {
    Unit = {
      Description = "Backup configuration";
    };
    Service = {
      ExecStart = "${pkgs.rsync}/bin/rsync -av --delete /run/media/et1/ /run/media/backup/ --exclude .git/";
    };
  };

  systemd.user.timers.foo = {
    Unit = {
      Description = "Timer for backup service";
    };
    Timer = {
      OnCalendar = "01:00:00";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
