{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    shotman
    pcmanfm
    kdePackages.kcalc
    wl-mirror
    eyedropper
    loupe
    libreoffice
    otpclient
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
    gossip
    # (kodi.withPackages (kodiPkgs: with kodiPkgs; [
    #   pvr-hdhomerun
    #   youtube
    # ]))
  ];
}
