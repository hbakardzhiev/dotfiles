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
    p7zip
    udiskie
    tree
  ];

}
