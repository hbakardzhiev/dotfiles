{ ... }:
  let port = 8888;
in 
{
  services.metabase = {
    enable = true;
    listen.port = port;
    openFirewall = true;
    ssl.enable = false;
  };
  services.caddy = {
    enable = true;
    virtualHosts."metabase.v6.army" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${port}
      '';
    };
  };
}
