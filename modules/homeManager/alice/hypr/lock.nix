{
  ...
}:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          monitor = "";
          color = "rgb(246, 246, 246)";
        }
      ];

      label = [
        {
          monitor = "";
          text = "cmd[update:1000] date +%H:%M";
          color = "rgb(31, 31, 31)";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 64;
          position = "0, 160";
          halign = "center";
          valign = "center";
        }
      ];

      "input-field" = [
        {
          monitor = "";
          size = "240, 44";
          outline_thickness = 1;
          dots_center = true;
          outer_color = "rgb(31, 31, 31)";
          inner_color = "rgb(255, 255, 255)";
          font_color = "rgb(31, 31, 31)";
          font_family = "JetBrainsMono Nerd Font";
          fade_on_empty = false;
          placeholder_text = "Password";
          position = "0, -60";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
