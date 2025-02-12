{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";
      window = {
        decorations = "none";
        title = "Alacritty";
        dynamic_title = true;
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
      };
      font = {
        normal = {
          family = "monospace";
          style = "regular";
        };
        bold = {
          family = "monospace";
          style = "regular";
        };
        italic = {
          family = "monospace";
          style = "regular";
        };
        bold_italic = {
          family = "monospace";
          style = "regular";
        };
        size = 13.0;
      };
      colors = {
        primary = {
          background = "#FFFFFF";
          foreground = "#000000";
        };
      };
    };
  };
}
