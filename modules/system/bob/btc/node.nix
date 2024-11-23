{ ... }:
{
  # Automatically generate all secrets required by services.
  # The secrets are stored in /etc/nix-bitcoin-secrets
  nix-bitcoin.generateSecrets = true;
  nix-bitcoin.nodeinfo.enable = true;

  # Custom mempool.space
  services.mempool.enable = true;

  # Add some backup
  services.backups.enable = true;

  # Set this to enable electrs, an efficient Electrum server implemented in Rust.
  services.electrs.enable = true;

  ### RIDE THE LIGHTNING (a web interface for lnd and clightning)
  services.rtl = {
    enable = true;
    # Automatically enables clightning.
    nodes.clightning = {
      enable = true;
    };
  };

  # See ../configuration.nix for all available features.
  services.bitcoind = {
    enable = true;
    listen = true;
    dataDir = "/run/media/et1";              
  };
  
  # When using nix-bitcoin as part of a larger NixOS configuration, set the following to enable
  # interactive access to nix-bitcoin features (like bitcoin-cli) for your system's main user
  nix-bitcoin.operator = {
    enable = true;
    name = "alice";
  };
}
