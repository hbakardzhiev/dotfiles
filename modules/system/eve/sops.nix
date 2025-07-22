{ ... }:
{
  sops = {
    "Nextcloud/Password" = {
      owner = "alice";
      neededForUsers = true;
    };
  };
}
