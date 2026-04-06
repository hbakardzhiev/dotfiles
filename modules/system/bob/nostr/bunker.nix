{ config, pkgs, ... }:

{
  # === SOPS-NIX SETUP ===
  sops = {
    secrets = {
      "nostr/nsec" = {
        owner = "nak-bunker"; # we'll create this user
        group = "nak-bunker";
        mode = "0400"; # only readable by the service user
      };
    };
  };

  # === SYSTEMD SERVICE FOR NAK BUNKER ===
  users.users.nak-bunker = {
    isSystemUser = true;
    group = "nak-bunker";
    description = "Nostr nak bunker service user";
  };

  users.groups.nak-bunker = { };

  systemd.services.nak-bunker = {
    description = "Nostr NIP-46 Bunker (nak)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "tailscaled.service"
    ];
    requires = [ "tailscaled.service" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "nak-bunker-start" ''
        exec ${pkgs.nak}/bin/nak bunker \
          --profile main \
          --persist \
          --sec "$(cat ${config.sops.secrets."nostr/nsec".path})" \
          wss://relay.damus.io \
          wss://nos.lol \
          wss://nostr-01.uid.ovh \
          wss://nostr-02.uid.ovh \
          wss://nostr.mom \
          wss://nostr.v6.army \
          wss://nostr.wine \
          wss://relay.camelus.app \
          wss://relay.ditto.pub \
          wss://relay.primal.net \
          wss://relay.snort.social
      '';
      Restart = "always";
      RestartSec = "5s";

      Environment = "HOME=/var/lib/nak-bunker";

      # Security hardening
      User = "nak-bunker";
      Group = "nak-bunker";
      DynamicUser = false; # we use static user for secret access
      StateDirectory = "nak-bunker";
      WorkingDirectory = "/var/lib/nak-bunker";

      # Strong sandboxing
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      NoNewPrivileges = true;
      RestrictRealtime = true;
      RestrictNamespaces = true;
      MemoryDenyWriteExecute = true;
    };
  };
}
