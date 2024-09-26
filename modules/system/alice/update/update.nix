{ pkgs, ... }:
{
  systemd.services.pull-updates = {
    description = "Pulls changes to system config";
    restartIfChanged = false;
    onSuccess = [ "nixos-upgrade.service" ];
    startAt = "04:40";
    path = [pkgs.git pkgs.openssh];
    script = ''
      test "$(git branch --show-current)" = "main"
      git pull --ff-only
    '';
    serviceConfig = {
      WorkingDirectory = "/etc/nixos";
      User = "alice";
      Type = "oneshot";
    };
  };
  system.autoUpgrade = {
    enable = true;
    flake = "git+file:///etc/nixos";
    flags = [
      # "--update-input"
      # "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "05:00";
    allowReboot = true;
    randomizedDelaySec = "45min";
  };

        # hostname="$(hostname -s)"
        # --flake /etc/nixos/.#"''${hostname}"

  # systemd.services.rebuild = {
  #   description = "Rebuilds and activates system config";
  #   restartIfChanged = false;
  #   path = [ pkgs.nixos-rebuild pkgs.systemd ];
  #   script = ''
  #     nixos-rebuild boot 
  #     booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
  #     built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"

  #     if [ "''${booted}" = "''${built}" ]; then
  #       nixos-rebuild switch 
  #     else
  #       reboot now
  #     fi
  #   '';
  #   serviceConfig.Type = "oneshot";
  # };
}
