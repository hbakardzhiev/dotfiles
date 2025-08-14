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
        # Listen on this port
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
  networking.firewall.allowedTCPPorts = [
    80
    443
  ]; # Add 80/443 if using a reverse proxy

services.caddy = {
  enable = true;
  virtualHosts."bobbb.duckdns.org" = {
    enableACME = true;

    extraConfig = ''
      # WebSocket path
      @ws {
          path /ws*
      }

      # Proxy WebSocket connections
      reverse_proxy @ws 127.0.0.1:8080 {
          header_up Host {host}
          header_up X-Real-IP {remote}
          header_up X-Forwarded-For {remote}
          header_up X-Forwarded-Port {server_port}
          header_up X-Forwarded-Proto {scheme}
      }

      # Proxy all other requests
      reverse_proxy 127.0.0.1:8080 {
          header_up Host {host}
          header_up X-Real-IP {remote}
          header_up X-Forwarded-For {remote}
          header_up X-Forwarded-Port {server_port}
          header_up X-Forwarded-Proto {scheme}
      }
    '';
  };
};

}
