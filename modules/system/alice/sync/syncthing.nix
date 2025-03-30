{ ... }:
let baseDir = "/drives/data/syncthing";
in
{
  services.syncthing = {
    enable = true;
    configDir = "${baseDir}";
    user = "alice";
    group = "users";
  };
}
