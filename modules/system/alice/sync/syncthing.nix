{ ... }:
{
  services.syncthing = {
    enable = true;
    configDir = ../../../../../../drives/data/syncthing/Photos;
    user = "alice";
    group = "users";
  };
}
