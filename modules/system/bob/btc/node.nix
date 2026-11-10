{ lib, ... }:

{
  #
  # Sovran Bitcoin stack
  #
  # Sovran's modules/bitcoin is a maintained fork of nix-bitcoin.
  # It intentionally keeps the nix-bitcoin option namespace for
  # compatibility.
  #
  # Bob does NOT run Sovran's bundled LND (bitcoind-backed, generated
  # secrets). It runs the hand-rolled neutrino LND from ./lnd-neutrino.nix,
  # so the preset's `services.lnd.*` definitions are switched off at the
  # source instead of being fought over with mkForce.
  #
  sovran-bitcoin = {
    enable = true;
    operatorName = "alice"; # your user, gets bitcoin-cli / lncli / nodeinfo
    features.lnd = false;
  };

  nix-bitcoin.generateSecrets = true;

  nix-bitcoin.nodeinfo.enable = true;

  #
  # Bitcoin
  #
  services.bitcoind = {
    enable = true;

    # Keep the existing blockchain.
    dataDir = "/run/media/btcnode";

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
    tor.enforce = false;
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
  # The actual daemon is ./lnd-neutrino.nix (its own systemd unit).
  # `mkForce` is required: rtl.nix sets `services.lnd.enable = true` as soon
  # as services.rtl.nodes.lnd.enable is true (equal priority 100 otherwise).
  #
  services.lnd = {
    enable = lib.mkForce false;

    extraConfig = ''
      protocol.option-scid-alias=true
    '';
  };

  #
  # LND Connect
  #
  services.lnd.lndconnect = {
    enable = false;
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
