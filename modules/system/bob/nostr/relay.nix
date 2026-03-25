{ ... }:
{
  # services.nostr-rs-relay = {
  #   enable = true;
  #   dataDir = "/var/lib/nostr-rs-relay";
  #   settings = {
  #     info = {
  #       description = "Only I can publish events; open for reading.";
  #       pubkey = "7f12a48deefa2b96f073bc2a21bf5a5c09580a2110801deaee1d0dba8d3135b9";
  #       relay_url = "wss://bobbb.duckdns.org";
  #       name = "bobbb.duckdns.org";
  #     };

  #     network = {
  #       # Bind to this network address
  #       address = "0.0.0.0";
  #       # Listen on port 12849 (this is the default). I have not managed to find any way to change it. KEEP IT default!
  #     };

  #     authorization = {
  #       pubkey_whitelist = [
  #         "7f12a48deefa2b96f073bc2a21bf5a5c09580a2110801deaee1d0dba8d3135b9"
  #       ];
  #     };

  #     options = {
  #       max_event_size = 16384;
  #       reject_future_seconds = 1800;
  #     };

  #     limits = {
  #       max_subscriptions = 20;
  #       max_filters = 100;
  #     };
  #   };

  # };

  services.haven = {
    settings = {
      RELAY_URL = "nostr.v6.army";
      OWNER_PUB = "7f12a48deefa2b96f073bc2a21bf5a5c09580a2110801deaee1d0dba8d3135b9";
    };
    importRelays = [
      "relay.damus.io"
      "nos.lol"
      "relay.primal.net"
      "nostr.wine"
    ];
    enable = true;
  };

  # Open firewall for the relay port
  networking.firewall.allowedTCPPorts = [
    80
    443
  ]; # Add 80/443 if using a reverse proxy

  services.caddy = {
    enable = true;

    extraConfig = ''
      (nostr-proxy) {
        reverse_proxy 127.0.0.1:3355 {
          header_up Host {http.request.host}
          header_up X-Real-IP {http.request.remote.host}
          header_up X-Forwarded-For {http.request.remote.host}
          header_up X-Forwarded-Proto {http.request.scheme}
          transport http { versions 1.1 }
        }
        
        request_body { max_size 100MB }
        
        header {
          Access-Control-Allow-Origin "*"
          Access-Control-Allow-Methods "GET, POST, OPTIONS"
          Access-Control-Allow-Headers "*"
        }
        
        @nip11 header Accept application/nostr+json
        handle @nip11 {
          header { Access-Control-Allow-Origin "*" }
        }
        
        @options method OPTIONS
        handle @options { respond 204 }
      }
    '';

    virtualHosts."bobbb.duckdns.org" = {
      extraConfig = "import nostr-proxy";
    };
    virtualHosts."nostr.v6.army" = {
      extraConfig = "import nostr-proxy";
    };
  };
}
