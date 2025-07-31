{ pkgs, ... }:
let
  obsidianFolder = "/drives/data/obsidian/";
  # portfolioFolder = "/drives/data/portfolio/";
  # passwordsFolder = "/drives/data/Passwords/";
  # configurationBackupFolder = "/drives/data/configurationBackup/";
  script = ''
    git pull
    git add .
    git commit -m "Automated commit from script" || echo "Nothing to commit"
    git push origin main
  '';
in
{
  systemd.user.timers.upload-github = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "2m";
      Unit = "upload-github.service";
    };
  };
  systemd.user.services.upload-github = {
    wantedBy = [ "network-online.target" ];
    path = with pkgs; [
      git
      openssh
    ];
    script = ''
      #!/bin/bash

      cd ${obsidianFolder}
      ${script}
      echo "obsidian done"

    '';
  };
  # cd ${portfolioFolder}
  # ${script}
  # echo "portfolio done"
  # cd ${passwordsFolder}
  # ${script}
  # echo "password done"
  # cd ${configurationBackupFolder}
  # ${script}
  # echo "configuration backup folder done"
}
