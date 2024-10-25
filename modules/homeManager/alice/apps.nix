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
    obs-studio
    imagemagick
    torrential
    wev
    ventoy-full
    nmap
    kaffeine
    okular
    portfolio
    bitwarden-desktop
  ];
}
