{ ... }:
{
  services.n8n = {
    enable = true;
    openFirewall = true;
    webhookUrl = "https://n888n.v6.army";
  };
  systemd.services.n8n.environment = {
    N8N_EDITOR_BASE_URL = "https://n888n.v6.army";
    N8N_HOST = "n888n.v6.army";
    N8N_PROTOCOL = "https";
    # Example: Enable basic auth (use a generated secret in prod)
    # N8N_BASIC_AUTH_ACTIVE = "true";
    # N8N_BASIC_AUTH_USER = "admin";
    # N8N_BASIC_AUTH_PASSWORD = (lib.fileContents /etc/nixos/secrets/n8n-password);  # Or use sops-nix for secrets
  };
  services.caddy = {
    enable = true;
    virtualHosts."n888n.v6.army" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:5678
      '';
    };
  };
}
