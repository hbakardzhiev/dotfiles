{
  pkgs,
  ...
}:
{
  services.tor.settings = {
      UseBridges = true;
      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
      Bridge = "obfs4 93.88.127.74:12345 12A047CCFBD804A421E679EFE7913E5F51ADEA43 cert=3OdJik4wWEbaOdPMBkInqgIPSFch3qSCTTDXfzEeabuVz9xkItxtR4OE3eUK9M/eS4ElVg iat-mode=0";
  };
}
