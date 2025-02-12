{ pkgs, ... }:
{
  # xdg.desktopEntries.signal-desktop-beta = {
  #   name = "Signal Beta";
  #   exec = "${pkgs.signal-desktop-beta}/bin/signal-desktop-beta --enable-features=UseOzonePlatform --ozone-platform=wayland --no-sandbox %U";
  #   terminal = false;
  #   type = "Application";
  #   icon = "signal-desktop-beta";
  #   # StartupWMClass=Signal Beta
  #   comment = "Private messaging from your desktop";
  #   mimeType = [
  #     "x-scheme-handler/sgnl"
  #     "x-scheme-handler/signalcaptcha"
  #   ];
  #   categories = [
  #     "Network"
  #     "InstantMessaging"
  #     "Chat"
  #   ];
  # };

  home.packages = with pkgs; [ signal-desktop ];
}
