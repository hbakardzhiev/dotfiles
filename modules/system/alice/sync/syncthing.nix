{ ... }:
{
  services.syncthing = {
    enable = true;
    user = "alice";
    group = "users";
  };
}
