{
  pkgs,
  config,
  ...
}:
{
  services.tor.settings = {
      UseBridges = true;
      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
      Bridge = "${config.sops.placeholder.tor_bridge_1}";
  };
}
