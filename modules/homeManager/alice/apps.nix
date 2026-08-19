{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    wl-mirror
    libreoffice
    xournalpp
    portfolio
    # bitwarden-desktop
    # (kodi.withPackages (kodiPkgs: with kodiPkgs; [
    #   pvr-hdhomerun
    #   youtube
    # ]))
  ];
}
