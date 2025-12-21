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
    rebootWindow = {
      lower = "01:00";
      upper = "05:00";
    };
    allowReboot = false;
    randomizedDelaySec = "45min";
  };
}
