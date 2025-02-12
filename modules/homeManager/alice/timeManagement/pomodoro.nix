{ pkgs, ... }:
let
  pomodoro = "${pkgs.openpomodoro-cli}/bin/pomodoro";
in
{
  programs.bash = {
    shellAliases = {
      pomodoroBreak = "${pomodoro} start -t break -d";
      pomodoroStart = "${pomodoro} start -t";
      pomodoroFinish = "${pomodoro} finish";
      pomodoroHistory = "${pomodoro} history";
    };
  };
}
