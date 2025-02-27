{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    shotman
    pcmanfm
    libsForQt5.kcalc
    wl-mirror
    eyedropper
    shotwell
    libreoffice
    otpclient
    thunderbird
    xournalpp
    imagemagick
    torrential
    wev
    nmap
    okular
    portfolio
    bitwarden-desktop
    libsForQt5.kdenlive
    vesktop
    # (kodi.withPackages (kodiPkgs: with kodiPkgs; [
    #   pvr-hdhomerun
    #   youtube
    # ]))
  ];
}
