{ pkgs, ... }:
{
  # 1. Trigger service 3 minutes after boot
  systemd.user.timers.sync-hypr-config = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnStartupSec = "3m";
  };

  # 2. Keep a copy of the Hyprland config on the data drive. The config is a
  # tree of Home Manager symlinks, so copy through them (-L) and write plain
  # files; the mode is not preserved because store files are read-only.
  systemd.user.services.sync-hypr-config = {
    # If the target directory isn't mounted/found, systemd skips the job cleanly
    unitConfig.ConditionPathExists = "/drives/data/configs";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/sh -c 'rm -rf /drives/data/configs/hypr && ${pkgs.coreutils}/bin/cp -rL --no-preserve=mode %h/.config/hypr /drives/data/configs/'";
    };
  };
}
