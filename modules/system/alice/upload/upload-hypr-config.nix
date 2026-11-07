{ pkgs, ... }:
{
  # Keep a copy of the Hyprland config on the data drive. Home Manager owns
  # the files and symlinks them, so copy through the links and drop the
  # read-only store modes.
  systemd.user.timers.sync-hypr-config = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnStartupSec = "3m";
  };

  systemd.user.services.sync-hypr-config = {
    unitConfig.ConditionPathExists = "/drives/data/configs";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/sh -c 'rm -rf /drives/data/configs/hypr && ${pkgs.coreutils}/bin/cp -rL --no-preserve=mode %h/.config/hypr /drives/data/configs/'";
    };
  };
}
