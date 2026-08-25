{ ... }:
let
  port = 8888;
in
{
  services.metabase = {
    enable = true;
    listen.port = port;
    openFirewall = true;
    ssl.enable = false;
  };
}
