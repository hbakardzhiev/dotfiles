{ pkgs, ... }:
let
  pomodoro = "${pkgs.openpomodoro-cli}/bin/pomodoro";
in
{
  programs.bash = {
    shellAliases = {
      pomodoroBreak = "function myFunc() { ${pomodoro} start -t break -d $1 }; myFunc";
      pomodoroStart = "function myFunc() { ${pomodoro} start -t $1 }; myFunc";
    };
  };
}
