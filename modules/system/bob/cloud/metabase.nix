{ ... }:
let
  port = 8888;
in
{
  services.metabase = {
    enable = true;
    listen.port = port;
    openFirewall = false;
    ssl.enable = false;
  };
}
