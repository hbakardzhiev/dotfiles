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
  pomodoroHistory = "/home/alice/.pomodoro/history";
  grep = "${pkgs.gnugrep}/bin/grep";
  pomodoroDuration = "$(${pkgs.coreutils-full}/bin/tail -n 1 ${pomodoroHistory} | ${grep} -oP 'duration=\\K[0-9]+')";
in
{
  sops.templates."pomodoro-start" = {
    content = ''
      ${bashSetup}
      ${pomodoStatus}
      ${pkgs.libnotify}/bin/notify-send "Pomodoro start 🚀" "<b>$pomodoroStatus</b>" &
      sleep "${pomodoroDuration}"m
      ${playMusic}
      ${pomodoStatus}
      ${pkgs.libnotify}/bin/notify-send "Pomodoro finished ✅🏁" "<b>$pomodoroStatus</b>"    '';
    path = "/home/alice/.pomodoro/hooks/start";
    mode = "5555";
  };
  users.users.alice.packages = with pkgs; [ openpomodoro-cli ];
}
