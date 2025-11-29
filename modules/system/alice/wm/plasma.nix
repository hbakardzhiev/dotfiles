{ pkgs, ... }:
{
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm = {
    wayland.enable = true;
    settings = {
      General.DisplayServer = "wayland";
      Autologin = {
        Session = "plasma.desktop";
        User = "alice";
      };
    };
  };
  services.desktopManager.plasma6.enable = true;
  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
    ];
    systemPackages = with pkgs.kdePackages; [
      kmail
      kcalc
      okular
      kdenlive
      kmail-account-wizard
      loupe
      ktorrent
      keysmith
    ];
  };
}
