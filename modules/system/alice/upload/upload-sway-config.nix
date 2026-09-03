{ pkgs, ... }:
{
  # 1. Trigger service 3 minutes after boot
  systemd.user.timers.sync-sway-config = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnStartupSec = "3m";
  };

  # 2. Systemd handles the file copy and drive check natively
  systemd.user.services.sync-sway-config = {
    # If the target directory isn't mounted/found, systemd skips the job cleanly
    unitConfig.ConditionPathExists = "/drives/data/configs/sway";

    # Plain copy command (only overwrites if newer)
    serviceConfig.ExecStart = "${pkgs.coreutils}/bin/cp -u %h/.config/sway/config /drives/data/configs/sway/config";
  };
}
