{ ... }:
{
  services.syncthing = {
    enable = true;
    configDir = /home/alice/syncthing;
    user = "alice";
    group = "users";
  };
}
