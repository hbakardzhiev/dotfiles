{ pkgs, ... }:
let 
  bashSetup = ''
      #!/usr/bin/env bash
      set -xo pipefail
  '';
  playMusic = "${pkgs.pipewire}/bin/pw-play /home/alice/.pomodoro/hooks/music.mp3";
  pomodoro = "${pkgs.openpomodoro-cli}/bin/pomodoro";
  tail = "${pkgs.coreutils-full}/bin/tail -2";
  pomodoStatus = ''pomodoroStatus="$(${pomodoro} history | ${tail})"'';
in
{
  sops.templates."pomodoro-start" = {
    content = ''
      ${bashSetup}
      ${pomodoStatus}
      ${pkgs.libnotify}/bin/notify-send "Pomodoro start 🚀" "<b>$pomodoroStatus</b>" &
      sleep 25m 
      ${playMusic}
      ${pomodoStatus}
      ${pkgs.libnotify}/bin/notify-send "Pomodoro finished ✅🏁" "<b>$pomodoroStatus</b>"    '';
    path = "/home/alice/.pomodoro/hooks/start";
    mode = "5555";
  };
  sops.templates."pomodoro-break" = {
    content = ''
      ${bashSetup}
      ${pomodoStatus}      
      ${pkgs.libnotify}/bin/notify-send "Pomodoro break 😎" "<b>$pomodoroStatus</b>"
      sleep 5m 
      ${playMusic}
      ${pomodoStatus}
      ${pkgs.libnotify}/bin/notify-send "Pomodoro break finished 😎" "<b>$pomodoroStatus</b>"    '';
    path = "/home/alice/.pomodoro/hooks/break";
    mode = "5555";
  };
  sops.templates."pomodoro-stop" = {
    content = ''
      ${bashSetup}
      ${pomodoStatus}
      ${pkgs.libnotify}/bin/notify-send "Pomodoro finished ✅🏁" "<b>$pomodoroStatus</b>"    
    '';
    path = "/home/alice/.pomodoro/hooks/stop";
    mode = "5555";
  };
  users.users.alice.packages = with pkgs; [ openpomodoro-cli ];

  systemd.user.services.upload-pomodoro-work = {
    startAt = "10:00";
    wantedBy = [ "network-online.target" ];
    path = with pkgs; [ git openssh ];
    script = ''
      #!/bin/bash

      cd "/home/alice/.pomodoro/"
      git add .
      git commit -m "Automated commit from script"
      git push origin main
    '';
  };
}
