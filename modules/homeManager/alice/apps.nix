{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    shotman
    wl-mirror
    libreoffice
    otpclient
    xournalpp
    wev
    nmap
    portfolio
    bitwarden-desktop
    vesktop
    rustdesk
    vscode-fhs
    vlc
    # (kodi.withPackages (kodiPkgs: with kodiPkgs; [
    #   pvr-hdhomerun
    #   youtube
    # ]))
  ];
}
