{ pkgs, ... }:
let
  pomodoroFolder = "/home/alice/.pomodoro/";
  obsidianFolder = "/drives/data/obsidian/";
  script = ''
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

  systemd.user.services.upload-obsidian = {
    startAt = "10:00";
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
