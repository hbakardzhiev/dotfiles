{ pkgs, ... }:
let
  pomodoroFolder = "/home/alice/.pomodoro/";
  obsidianFolder = "/drives/data/obsidian/";
  script = ''
    git pull
    git add .
    git commit -m "Automated commit from script"
    git push origin main
  '';
in
{
  systemd.user.services.upload-pomodoro = {
    startAt = "10:00";
    wantedBy = [ "network-online.target" ];
    path = with pkgs; [
      git
      openssh
    ];
    script = ''
      #!/bin/bash

      cd ${pomodoroFolder}
      ${script}
    '';
  };

  systemd.user.timers.upload-obsidian = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "10m";
      Unit = "upload-obsidian.service";
    };
  };
  systemd.user.services.upload-obsidian = {
    # startAt = "10:00";
    wantedBy = [ "network-online.target" ];
    path = with pkgs; [
      git
      openssh
    ];
    script = ''
      #!/bin/bash

      cd ${obsidianFolder}
      ${script}
    '';
  };
}
