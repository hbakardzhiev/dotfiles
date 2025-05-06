{ pkgs, ... }:
{
  xdg.desktopEntries.postman = {
    name = "Postman";
    exec = "${pkgs.postman}/bin/postman --enable-features=UseOzonePlatform --ozone-platform=wayland";
    terminal = false;
    type = "Application";
    icon = "postman";
    # StartupWMClass=Signal Beta
  };

  home.packages = with pkgs; [ postman ];
}
