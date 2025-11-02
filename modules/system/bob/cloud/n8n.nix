{ ... }:
{
  services.n8n = {
    enable = true;
    openFirewall = true;
    settings = {
      N8N_EDITOR_BASE_URL = "https://n888n.v6.army";
    };
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
