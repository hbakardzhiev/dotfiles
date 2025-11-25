{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    shotman
    pcmanfm
    kdePackages.kcalc
    wl-mirror
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
    vscode-fhs
    geary
    kotatogram-desktop
    vlc
    # (kodi.withPackages (kodiPkgs: with kodiPkgs; [
    #   pvr-hdhomerun
    #   youtube
    # ]))
  ];
}
