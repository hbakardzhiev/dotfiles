{ ... }:
{
  services.metabase = {
    enable = true;
    listen.port = 8888;
    openFirewall = true;
    ssl.enable = false;
  };
}
