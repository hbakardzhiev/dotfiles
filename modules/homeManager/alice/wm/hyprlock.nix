{
  ...
}:
let
  pic = builtins.path {
    path = ./bds.jpeg;
    name = "bds";
  };
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 5;
        ignore_empty_input = true;
      };
      background = {
        monitor = "";
        path = "${pic}";
      };
      input-field = {
        monitor = "";
        size = "200, 50";
        position = "0, -20";
        halign = "center";
        valign = "center";
        fade_on_empty = true;
        fail_text = "<i>Authentication failed ($ATTEMPTS attempts)</i>";
        capslock_color = "rgba(255, 0, 0, 1)";
      };
      label = {
        monitor = "";
        text = "cmd[update:1000] echo \"$TIME\"";
        color = "rgba(200, 200, 200, 1.0)";
        font_size = 25;
        position = "0, 80";
        halign = "center";
        valign = "center";
      };
    };
  };
}
