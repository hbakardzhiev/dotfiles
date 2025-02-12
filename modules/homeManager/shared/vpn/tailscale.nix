{ pkgs, ... }:
{
  home.shellAliases = {
    vpnStatus = "${pkgs.tailscale}/bin/tailscale status";
    vpnOn = "function myFunc() { sudo ${pkgs.tailscale}/bin/tailscale set --exit-node=$1; }; myFunc";
    vpnOff = "sudo ${pkgs.tailscale}/bin/tailscale up --ssh --exit-node=";
  };
}
