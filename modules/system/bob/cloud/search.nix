{ ... }:
{
  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 3456;
        secret_key = "test123!";
      };
      #   upstream_search_engines = {
      #     DuckDuckGo = true;
      #     Searx = true;
      #     Brave = true;
      #     Startpage = true;
      #     LibreX = true;
      #     Mojeek = true;
      #     Bing = true;
      #     Qwant = true;
      #     Wikipedia = true;
      #     Yahoo = true;
      #     SepiaSearch = true;
      #   };
    };
  };
}
