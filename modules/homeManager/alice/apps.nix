{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    wl-mirror
    libreoffice
    xournalpp
    portfolio
    bitwarden-desktop
    vesktop
    rustdesk
    vscode-fhs
    # (kodi.withPackages (kodiPkgs: with kodiPkgs; [
    #   pvr-hdhomerun
    #   youtube
    # ]))
  ];
}
