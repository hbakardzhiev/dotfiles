{ ... }:
{
  services.nostr-rs-relay = {
    enable = true;
    dataDir = "/var/lib/nostr-rs-relay";
    settings = {
      info = {
        description = "Only I can publish events; open for reading.";
        pubkey = "7f12a48deefa2b96f073bc2a21bf5a5c09580a2110801deaee1d0dba8d3135b9";
        relay_url = "wss://bobbb.duckdns.org";
        name = "nostr.tail6dbb0b.ts.net";
      };
      network = {
        # Bind to this network address
        address = "0.0.0.0";
        # Listen on port 12849 (this is the default). I have not managed to find any way to change it. KEEP IT default!
      };
      authorization = {
        nip42_auth = true;
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
  # Inject the environment variable into the systemd unit
  systemd.services.nostr-rs-relay.environment = {
    RUST_LOG = "debug";
  };
}
