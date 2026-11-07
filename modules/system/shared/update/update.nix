{ config, ... }:
{
  # systemd.services.pull-updates = {
  #   description = "Pulls changes to system config";
  #   restartIfChanged = false;
  #   # onSuccess = [ "nixos-upgrade.service" ];
  #   startAt = "04:40";
  #   path = [pkgs.git pkgs.openssh];
  #   script = ''
  #     test "$(git branch --show-current)" = "main"
  #     git pull --ff-only
  #   '';
  #   serviceConfig = {
  #     WorkingDirectory = "/etc/nixos";
  #     User = "alice";
  #     Type = "oneshot";
  #   };
  # };
  system.autoUpgrade = {
    enable = true;
    # flake = "git+file:///etc/nixos";
    flake = "https://github.com/hbakardzhiev/dotfiles/archive/main.tar.gz#${config.networking.hostName}";
    flags = [
      # "--update-input"
      # "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "03:00";
    # Reboot window starts after the 01:00 user backup (foo.timer) has had time
    # to finish, so an automatic reboot never kills it mid-run. The decision is
    # made once, right after the upgrade, and is not deferred: if it falls
    # outside this window the reboot is skipped until the next upgrade.
    rebootWindow = {
      lower = "04:00";
      upper = "06:00";
    };
    allowReboot = true;
    randomizedDelaySec = "45min";
  };
}
