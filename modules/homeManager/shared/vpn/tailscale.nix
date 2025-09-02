{ pkgs-unstable, ... }:
{
  home.shellAliases = {
    vpnStatus = "${pkgs-unstable.tailscale}/bin/tailscale status";
    vpnOn = "function myFunc() { sudo ${pkgs-unstable.tailscale}/bin/tailscale set --exit-node=$1; }; myFunc";
    vpnOff = "sudo ${pkgs-unstable.tailscale}/bin/tailscale up --ssh --exit-node=";
  };
}
