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
    pixelorama
    obs-studio
    imagemagick
    torrential
    wev
    ventoy-full
    nmap
    kaffeine
    okular
  ];

  # programs.java.enable = true;
}
