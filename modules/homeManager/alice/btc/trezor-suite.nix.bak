{ pkgs, ... }:
{
  # xdg.desktopEntries.trezor-suite = {
  #    name = "Trezor Suite";
  #     exec =
  #       "${pkgs.trezor-suite}/bin/trezor-suite --ozone-platform=wayland";
  #     terminal = false;
  #     type = "Application";
  #     icon = "trezor-suite";
  #     # StartupWMClass=Signal Beta
  # };
  home.packages = with pkgs; [
    trezor-suite
  ];
  # programs.bash.shellAliases = {
  #   # --enable-features=UseOzonePlatform
  #   trezor-suite = "${pkgs.trezor-suite}/bin/trezor-suite  --ozone-platform=wayland";
  # };
}
