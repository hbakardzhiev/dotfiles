{ config, lib, ... }:
let
  cfg = config.tools.networking;
in
{
  # Define options for lid switch behavior
  options.tools.networking = {
    enable = lib.mkEnableOption "Enable networking";
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname to set";
      default = "";
    };
    enableIwdWifi = lib.mkEnableOption "Enable Iwd WiFI";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.hostname != "";
        message = "Hostname must be set";
      }
    ];
    networking = {
      firewall.enable = true;
      # firewall.allowedUDPPorts = [];
      hostName = cfg.hostname;

      useNetworkd = lib.mkIf cfg.enableIwdWifi true;
      # This disables networkmanager and only uses Iwd for WiFi
      networkmanager.enable = if cfg.enableIwdWifi then lib.mkForce false else true;
      # wireless.iwd.enable = true;
      # networkmanager.wifi.backend = "iwd";
      # networkmanager.wifi.powersave = false;
      # networkmanager.wifi.scanRandMacAddress = false;

      # wireless.enable = true;
    };
    # Enable iwd for WiFi (replaces wpa_supplicant)
    networking.wireless.iwd = lib.mkIf cfg.enableIwdWifi {
      enable = true;
      settings = {
        General = {
          # Let systemd-networkd handle IP/DHCP/routing, not iwd
          EnableNetworkConfiguration = false;
        };
        Settings = {
          # Optional: Auto-connect to known networks
          AutoConnect = true;
        };
      };
    };
  };
}
