{
  ...
}:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "alacritty";
        layer = "overlay";
        width = 40;
        lines = 12;
      };
      border = {
        width = 1;
        radius = 0;
      };
      colors = {
        background = "f6f6f6ff";
        text = "1f1f1fff";
        match = "205ea6ff";
        selection = "e2e2e2ff";
        selection-text = "1f1f1fff";
        border = "d8d8d8ff";
      };
    };
  };
}
