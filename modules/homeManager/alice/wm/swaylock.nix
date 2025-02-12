{ ... }:
{
  programs.swaylock = {
    enable = true;
    settings = {
      show-failed-attempts = true;
      show-keyboard-layout = true;
    };
  };
}
