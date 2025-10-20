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
        # Bind to this network address (enables HTTP/WS on same port)
        address = "0.0.0.0";
        listen = "0.0.0.0:12849";  # Explicit port (overrides default)
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
        # Global CORS
        header Access-Control-Allow-Origin *
        header Access-Control-Allow-Headers *
        header Access-Control-Allow-Methods GET, POST, OPTIONS

        # NIP-11: Static JSON for /api/v1/info (only on matching Accept)
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
            "version": "0.9.0",
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

          # Non-matching /api/v1/info (e.g., wrong Accept) proxy to relay
          reverse_proxy 127.0.0.1:12849 {
            header_up Accept {http.request.header.Accept}
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
          }
        }

        # Other /api paths proxy to relay
        handle /api/* {
          reverse_proxy 127.0.0.1:12849 {
            header_up Accept {http.request.header.Accept}
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
          }
        }

        # Root path
        handle / {
          respond "Please use a Nostr client to connect." 200 {
            content_type text/plain
            header Access-Control-Allow-Origin *
          }
        }

        # Proxy everything else (WS + other paths)
        handle {
          reverse_proxy 127.0.0.1:12849 {
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
          }
        }
      '';
    };
  };
}
