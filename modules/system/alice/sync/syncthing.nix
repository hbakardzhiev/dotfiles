{ ... }:
{
  services.syncthing = {
    enable = true;
    configDir = "/drives/data/syncthing";
    user = "alice";
    group = "users";
  };
}
