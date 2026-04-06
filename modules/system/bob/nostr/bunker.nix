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
      ExecStart = '''
        ${pkgs.nak}/bin/nak bunker 
          --sec "$(cat ${config.sops.secrets."nostr/nsec".path})"
          nos.lol 
          nostr-01.uid.ovh 
          nostr-02.uid.ovh 
          nostr.mom 
          nostr.v6.army 
          nostr.wine 
          relay.camelus.app 
          relay.damus.io 
          relay.ditto.pub 
          relay.primal.net 
          relay.snort.social 
      ''';
      Restart = "always";
      RestartSec = "5s";

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
