{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    shotman
    pcmanfm
    wl-mirror
    loupe
    libreoffice
    otpclient
    xournalpp
    torrential
    wev
    nmap
    portfolio
    bitwarden-desktop
    vesktop
    rustdesk
    gossip
    vscode-fhs
    vlc
    # (kodi.withPackages (kodiPkgs: with kodiPkgs; [
    #   pvr-hdhomerun
    #   youtube
    # ]))
  ];
}
