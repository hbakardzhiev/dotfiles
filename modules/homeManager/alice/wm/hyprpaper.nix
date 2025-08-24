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
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ "${pic}" ];
      wallpaper = [ ",${pic}" ];
    };
  };

}
