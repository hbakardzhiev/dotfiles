{
  pkgs,
  lib,
  hostname,
  ...
}:
let
  homeManagerDir = ./modules/homeManager;
  getNixFiles = import ./modules/functions/getNixFiles.nix;
  firstPart = getNixFiles {
    path = "${homeManagerDir}/${hostname}";
    inherit lib;
  };
  secondPart = getNixFiles {
    path = "${homeManagerDir}/shared";
    inherit lib;
  };
in
{
  imports = firstPart ++ secondPart ++ [ ./sops.nix ];

  home.username = "alice";
  home.homeDirectory = "/home/alice";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    htop
    nixfmt-rfc-style
    # libsForQt5.qt5.qtwayland
    # intel-gpu-tools
    p7zip
    udiskie
    tree
    gparted
    smartmontools
  ];

}
