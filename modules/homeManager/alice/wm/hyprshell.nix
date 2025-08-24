{
  hyprshell,
  ...
}:
{
  imports = [
    hyprshell.homeModules.default
  ];
  programs.hyprshell = {
    enable = true;
    systemd.args = "-v";
    settings = {
      windows = {
        overview = {
          key = "Tab";
          modifier = "alt";
          launcher = {
            max_items = 6;
          };
        };
      };
    };
  };
}
