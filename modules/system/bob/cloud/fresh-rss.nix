{ ... }:
{
  services.freshrss = {
    enable = true;
    authType = "none";
    language = "en";
    api.enable = true;
    baseUrl = "https://fresh-rss.tail6dbb0b.ts.net";
    webserver = "nginx";
    virtualHost = "freshrss";
  };

  services.nginx.virtualHosts.freshrss = {
    serverAliases = [ "fresh-rss.tail6dbb0b.ts.net" ];
    listen = [
      {
        addr = "127.0.0.1";
        port = 2799;
      }
    ];
  };
}
