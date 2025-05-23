{ ... }:
{
  services.mako = {
    enable = true;
    settings = {
      ignore-timeout = true;
      default-timeout = 6000; # 6 seconds
      icons = true;
    };
  };
}
