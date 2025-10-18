{ pkgs, ... }:
{
  services.tor = {
    enable = true;
    client = {
      enable = true;
    };
    settings = {
      UseBridges = true;
      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
      Bridge = [
        "obfs4 91.98.173.170:8443 7FEFD9B756855A32B94627F450E75DB894189F20 cert=hFHCWS7U3/k3LgoZL3pDA85BsJva7iqKSlR++4d2EwPNCna4riYJH0YK59FaPHYYVkAIFw iat-mode=0"
        "obfs4 142.189.114.119:443 0DBB397ADC4F8A16C09331EC337197531899ED74 cert=/fGABEVsy165oq5yrI5LNYz198uisjQUeQ9/ecrGbmi+Y/eSB865w1GtT9Md2wKvROHHIQ iat-mode=0"
      ];
    };
  };
}
