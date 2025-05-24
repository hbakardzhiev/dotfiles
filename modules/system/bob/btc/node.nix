{ pkgs, config, ... }:
{
  # security.doas.enable = lib.mkForce false;
  # security.sudo.enable = lib.mkForce true;
  # Automatically generate all secrets required by services.
  # The secrets are stored in /etc/nix-bitcoin-secrets
  nix-bitcoin.generateSecrets = true;
  nix-bitcoin.nodeinfo.enable = true;
  nix-bitcoin.onionServices.mempool-frontend.enable = true;
  nix-bitcoin.useVersionLockedPkgs = true;

  # Custom mempool.space
  services.mempool = {
    frontend.enable = true;
    enable = true;
  };

  # Set this to enable electrs, an efficient Electrum server implemented in Rust.
  services.electrs = {
    enable = true;
    # Listen to connections on all interfaces
    address = "0.0.0.0";

    # Set this if you're using the `secure-node.nix` template
    tor.enforce = false;
  };
  # Open the electrs port in the firewall
  networking.firewall.allowedTCPPorts = [
    config.services.electrs.port
    config.services.mempool.frontend.port
    config.services.lnd.port
  ];

  # ### RIDE THE LIGHTNING (a web interface for lnd and clightning)
  nix-bitcoin.onionServices.lnd.public = true;
  services.rtl = {
    enable = true;
    nightTheme = false;
    dataDir = "/home/alice/BTC/rtl";
    # Automatically enables clightning.
    nodes.lnd = {
      enable = true;
    };
  };
  services.lnd.lndconnect = {
    enable = true;
    onion = true;
  };

  # See ../configuration.nix for all available features.
  services.bitcoind = {
    enable = true;
    listen = true;
    package = config.nix-bitcoin.pkgs.bitcoind-knots;
    extraConfig = ''
      rpcworkqueue=64
      upnp=1

      datacarrier=0
      rejectparasites=1

      disablewallet=1
    '';
    dataDir = "/run/media/et1";
  };

  # When using nix-bitcoin as part of a larger NixOS configuration, set the following to enable
  # interactive access to nix-bitcoin features (like bitcoin-cli) for your system's main user
  nix-bitcoin.operator = {
    enable = true;
    name = "alice";
  };
}
