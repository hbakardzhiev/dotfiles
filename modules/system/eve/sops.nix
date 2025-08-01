{ ... }:
{
  sops.secrets."nextcloud/username" = {
    owner = "alice";
  };
  sops.secrets."nextcloud/Password" = {
    owner = "alice";
  };
  sops.secrets.gmx = { };
}
