{ config, ... }:
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
    frontend.enable = false;
    enable = false;
    # Set this if you're using the `secure-node.nix` template
    tor.enforce = false;
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
    config.services.bitcoind.port
  ];

  # ### RIDE THE LIGHTNING (a web interface for lnd and clightning)
  nix-bitcoin.onionServices.lnd.public = true;
  services.rtl = {
    enable = true;
    nightTheme = false;
    # dataDir = "/run/media/et1";
    # Automatically enables clightning.
    nodes.lnd = {
      enable = true;
    };
  };
  services.lnd.lndconnect = {
    enable = true;
    # onion = true;
  };
  services.lnd = {
    enable = true;
    tor.enforce = false;

    extraConfig = ''
      listen=0.0.0.0:${toString config.services.lnd.port}
      externalip=lnd-connect.v6.army:${toString config.services.lnd.port}
      nat=true
    '';
  };

  # See ../configuration.nix for all available features.
  services.bitcoind = {
    enable = true;
    listen = true;
    # Open node for p2p
    address = "0.0.0.0";
    # package = config.nix-bitcoin.pkgs.bitcoind-knots;

    extraConfig = ''
      rpcworkqueue=64
      upnp=1
      disablewallet=1

      # datacarrier=1
      # datacarriersize=42
      # rejectparasites=1
      # rejecttokens=1
      # minrelaytxfee=0.00001000
      # dustrelayfee=0.00001000
      # dustdynamic=target:1008

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
