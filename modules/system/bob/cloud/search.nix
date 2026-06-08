{ ... }:
{
  services.websurfx = {
    enable = true;
    settings = {
      port = 4567;
      ### Search Engines ###
      upstream_search_engines = {
        DuckDuckGo = true;
        Searx = true;
        Brave = true;
        Startpage = true;
        LibreX = true;
        Mojeek = true;
        Bing = true;
        Qwant = true;
        Wikipedia = true;
        Yahoo = true;
        SepiaSearch = true;
      };
    };
  };
}
