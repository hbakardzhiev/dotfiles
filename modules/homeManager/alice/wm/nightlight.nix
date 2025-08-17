{ ... }:
{
  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 50.8;
    longitude = 5.7;
    tray = true;
    temperature.night = 3000;
  };
}
