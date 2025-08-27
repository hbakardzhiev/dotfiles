{
  pkgs,
  config,
  lib,
  ...
}:
{
  services.tor.settings = {
      UseBridges = true;
      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
      Bridge = lib.splitString "\n" (builtins.readFile config.sops.secrets.tor_bridges.path);
  };
}
