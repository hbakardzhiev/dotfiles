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
        name = "bobbb.duckdns.org";
      };

      network = {
        # Bind to this network address
        address = "0.0.0.0";
        # Listen on port 12849 (this is the default). I have not managed to find any way to change it. KEEP IT default!
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
  networking.firewall.allowedTCPPorts = [
    80
    443
  ]; # Add 80/443 if using a reverse proxy

  services.caddy = {
    enable = true;
    virtualHosts."bobbb.duckdns.org" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:12849
        
        # CORS preflight (OPTIONS)
        @cors_preflight {
          method OPTIONS
        }
        respond @cors_preflight 204 {
          header Access-Control-Allow-Origin *
          header Access-Control-Allow-Headers *
          header Access-Control-Allow-Methods "GET, OPTIONS"
        }
        
        # NIP-11 document (served via HTTPS; clients send Accept: application/nostr+json)
        @nip11 header Accept *application/nostr+json*
        header @nip11 Access-Control-Allow-Origin *
        header @nip11 Access-Control-Allow-Headers *
        header @nip11 Access-Control-Allow-Methods "GET, OPTIONS"
      '';
    };
  };

}
