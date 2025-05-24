{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    shotman
    pcmanfm
    kdePackages.kcalc
    wl-mirror
    eyedropper
    shotwell
    libreoffice
    otpclient
    thunderbird
    xournalpp
    torrential
    wev
    nmap
    kdePackages.okular
    portfolio
    bitwarden-desktop
    kdePackages.kdenlive
    vesktop
    rustdesk
    # (kodi.withPackages (kodiPkgs: with kodiPkgs; [
    #   pvr-hdhomerun
    #   youtube
    # ]))
  ];
}
