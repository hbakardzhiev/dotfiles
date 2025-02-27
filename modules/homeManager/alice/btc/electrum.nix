{ pkgs, ... }:
{
  home.packages = with pkgs; [ electrum ];
  xdg.desktopEntries.electrum = {
    name = "Electrum Bitcoin Wallet";
    exec = "${pkgs.electrum}/bin/electrum --oneserver --server zlzhj4nwz7qgmlkhkppyywzjal2dn6qacrvkj6vqdhsrmz5gpaxwmoyd.onion:50001:t --proxy socks5:127.0.0.1:9050";
    terminal = false;
    type = "Application";
    icon = "electrum";
    # StartupWMClass=Signal Beta
    comment = "Private messaging from your desktop";
    mimeType = [
      "x-scheme-handler/bitcoin"
      "x-scheme-handler/lightning"
    ];
    categories = [
      "Finance"
      "Network"
    ];
  };
}
