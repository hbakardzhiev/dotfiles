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

      http = {
        enable = true;
        address = "127.0.0.0";  # Local bind for HTTP
        port = 12849;  # Match your proxy
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
        respond @cors_preflight 204

        header @cors_preflight Access-Control-Allow-Origin "*"
        header @cors_preflight Access-Control-Allow-Headers "*"
        header @cors_preflight Access-Control-Allow-Methods "GET, OPTIONS"

        # NIP-11 document (served via HTTPS; clients send Accept: application/nostr+json)
        @nip11 header Accept *application/nostr+json*
        header @nip11 Access-Control-Allow-Origin "*"
        header @nip11 Access-Control-Allow-Headers "*"
        header @nip11 Access-Control-Allow-Methods "GET, OPTIONS"
      '';
    };
    virtualHosts."nostr.v6.army" = {
      extraConfig = ''
        # NIP-11: Static JSON for /api/v1/info (matches your [info] + defaults)
        handle /api/v1/info {
          @nip11 {
            header Accept application/nostr+json
            header Accept application/json
          }
          respond @nip11 `{
            "name": "bobbb.duckdns.org",
            "description": "Only I can publish events; open for reading.",
            "pubkey": "7f12a48deefa2b96f073bc2a21bf5a5c09580a2110801deaee1d0dba8d3135b9",
            "relay_url": "wss://nostr.v6.army",
            "software": "nostr-rs-relay",
            "version": "0.10.1",  # Run `nostr-rs-relay --version` (or check pkgs) and update
            "supported_nips": [1, 2, 4, 9, 11, 12, 15, 16, 20, 22, 28, 40, 42, 50, 51],
            "limitation": {
              "message_length": 16384,
              "subscription_limit": 20,
              "subscription_filter_limit": 100,
              "future_time_limit": 1800
            },
            "restrict": {
              "pubkey_whitelist": ["7f12a48deefa2b96f073bc2a21bf5a5c09580a2110801deaee1d0dba8d3135b9"]
            }
          }` 200 {
            content_type application/nostr+json
            header Access-Control-Allow-Origin *
            header Access-Control-Allow-Headers *
            header Access-Control-Allow-Methods GET, OPTIONS
          }
          
          # Fallback for non-NIP-11 /api requests (plain text or proxy)
          handle /api/* {
            reverse_proxy 127.0.0.1:12849
          }
          
        # Root path
        handle / {
          respond "Please use a Nostr client to connect." 200 {
            content_type text/plain
            header Access-Control-Allow-Origin *
          }
        }
        
        # Proxy all else (WS + other paths)
        reverse_proxy 127.0.0.1:12849 {
          header_up X-Real-IP {remote_host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
        }
        
        # Global CORS
        header Access-Control-Allow-Origin *
        header Access-Control-Allow-Headers *
        header Access-Control-Allow-Methods GET, POST, OPTIONS
      '';
    };
  };

}
