{ pkgs, ... }:
{
  home.packages = with pkgs; [ tradingview ];
  xdg.desktopEntries.tradingview = {
    name = "Trading View";
    exec = "${pkgs.tradingview}/bin/tradingview --ozone-platform=wayland";
    terminal = false;
    type = "Application";
    icon = "tradingview";
    # StartupWMClass=Signal Beta
    comment = "TradingView Charts";
    categories = [
      "Finance"
    ];
  };
}
