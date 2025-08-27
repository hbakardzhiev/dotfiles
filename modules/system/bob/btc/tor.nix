{
  pkgs,
  ...
}:
{
  services.tor.settings = {
      UseBridges = true;
      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
      Bridge = [
        "obfs4 93.88.127.74:12345 12A047CCFBD804A421E679EFE7913E5F51ADEA43 cert=3OdJik4wWEbaOdPMBkInqgIPSFch3qSCTTDXfzEeabuVz9xkItxtR4OE3eUK9M/eS4ElVg iat-mode=0"
        "obfs4 172.82.64.66:443 D8B86CCA6A0C73C486AD7EC4A9A90C086817804C cert=cP+yBpR35yi/g1rACmr2lb/D2ne0phAaQO4S+YEndl0+uBtZ2cOnuI0NZpQYmfYvJ7DERQ iat-mode=0"
      ];
  };
}
