{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard
    shotman
    pcmanfm
    virt-manager
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
    ventoy-full
    nmap
    okular
    portfolio
    bitwarden-desktop
    libsForQt5.kdenlive
    # (kodi.withPackages (kodiPkgs: with kodiPkgs; [
    #   pvr-hdhomerun
    #   youtube
    # ]))
  ];
}
