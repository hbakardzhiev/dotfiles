{ ... }:

{
  #
  # Sovran Bitcoin stack
  #
  # Sovran's modules/bitcoin is a maintained fork of nix-bitcoin.
  # It intentionally keeps the nix-bitcoin option namespace for
  # compatibility.
  #

  nix-bitcoin.generateSecrets = true;

  nix-bitcoin.nodeinfo.enable = true;

  #
  # Bitcoin
  #
  services.bitcoind = {
    enable = true;

    # Keep the existing blockchain.
    dataDir = "/run/media/bitcoin";

    listen = true;
    address = "0.0.0.0";

    extraConfig = ''
      rpcworkqueue=64
      disablewallet=1
    '';
  };

  #
  # Electrs
  #
  services.electrs = {
    enable = true;
    address = "0.0.0.0";
  };

  #
  # LND
  #
  # IMPORTANT:
  # Do NOT specify a new dataDir.
  #
  # Sovran's LND module is derived from the same nix-bitcoin
  # implementation, so it should continue using:
  #
  #     /var/lib/lnd
  #
  # which contains the existing wallet/channel state.
  #
  services.lnd = {
    enable = true;

    extraConfig = ''
      protocol.option-scid-alias=true
    '';
  };

  #
  # LND Connect
  #
  services.lnd.lndconnect = {
    enable = true;
    onion = true;
  };

  #
  # RTL
  #
  services.rtl = {
    enable = true;

    tor.enforce = true;

    nightTheme = false;

    nodes.lnd = {
      enable = true;
    };
  };

  #
  # Mempool
  #
  services.mempool = {
    enable = true;
    frontend.enable = true;
  };

  #
  # Operator
  #
  nix-bitcoin.operator = {
    enable = true;
    name = "alice";
  };
}
