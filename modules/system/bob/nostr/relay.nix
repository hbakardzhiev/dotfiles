{ ... }:
{
  services.nostr-rs-relay = {
            enable = true;
            dataDir = "/home/alice/nostr";
            settings = {
              # Relay metadata (displayed to clients)
              info = {
                name = "My Private-Write Relay";
                description = "Only I can publish events; open for reading.";
                pubkey = "7f12a48deefa2b96f073bc2a21bf5a5c09580a2110801deaee1d0dba8d3135b9";  # Optional: Hex pubkey for relay admin contact (can be same as your publishing key)
                # contact = "your-email@example.com";  # Optional: Contact info
              };

              # Network settings
              address = {
                host = "0.0.0.0";  # Listen on all interfaces
                port = 8080;  # Default port; change if needed
              };

              # Restrict publishing to only your pubkey
              authorization = {
                pubkey_whitelist = [ "7f12a48deefa2b96f073bc2a21bf5a5c09580a2110801deaee1d0dba8d3135b9" ];  # Replace with your hex pubkey (array for multiple if needed)
              };

              # Optional: Other common settings (adjust as needed)
              options = {
                max_event_size = 16384;  # Default; increase for larger events
                reject_future_seconds = 1800;  # Reject events timestamped too far in the future
              };

              limits = {
                max_subscriptions = 20;  # Per-client subscription limit
                max_filters = 100;  # Max filters per subscription
              };
            };
          };

          # Open firewall for the relay port
          networking.firewall.allowedTCPPorts = [ 8080 ];  # Add 80/443 if using a reverse proxy
          

}
