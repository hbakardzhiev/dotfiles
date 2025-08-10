{ ... }:
{
  services.nostr-rs-relay = {
    enable = true;
    dataDir = "/var/lib/nostr-rs-relay";
    port = 8080;
    settings = {
      info = {
        name = "My Private-Write Relay";
        description = "Only I can publish events; open for reading.";
        pubkey = "7f12a48deefa2b96f073bc2a21bf5a5c09580a2110801deaee1d0dba8d3135b9";
      };

      network = {
        address = "0.0.0.0";
        port = 8080;
      };

      authorization = {
        pubkey_whitelist = [
          "7f12a48deefa2b96f073bc2a21bf5a5c09580a2110801deaee1d0dba8d3135b9"
        ];
      };

      options = {
        max_event_size = 16384;
        reject_future_seconds = 1800;
      };

      limits = {
        max_subscriptions = 20;
        max_filters = 100;
      };
    };

  };

  # Open firewall for the relay port
  networking.firewall.allowedTCPPorts = [ 8080 ]; # Add 80/443 if using a reverse proxy

}
