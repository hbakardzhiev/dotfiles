{ config, ... }:
let hostname = config.networking.hostName;
baseDir = if hostname == "alice"
            then "/drives/data/syncthing"
          else if hostname == "bob"
            then "/home/alice/syncthing"
          else "error";

in
{
  services.syncthing = {
    enable = true;
    configDir = "${baseDir}";
    user = "alice";
    group = "users";
  };
}
