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

  # See ../configuration.nix for all available features.
  services.bitcoind = {
    enable = true;
    listen = true;
    # Add some pruning
    prune = 100000;
    dataDir = "/run/media/et1";              
  };
  
  # Enable some services.
  services.clightning.enable = true;
  # When using nix-bitcoin as part of a larger NixOS configuration, set the following to enable
  # interactive access to nix-bitcoin features (like bitcoin-cli) for your system's main user
  nix-bitcoin.operator = {
    enable = true;
    name = "alice";
  };
}
