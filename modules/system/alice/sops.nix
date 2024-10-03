{ ... }:
{
  sops.secrets."nextcloud/username" = { };
  sops.secrets."nextcloud/Password" = { };

  # sops.secrets."ssh/laptop/private" = { 
  # };
  # sops.secrets."privateLaptop" = {
  #   owner = "alice";
  #   group = "users";
  #   mode = "0600";
  #   path = "/home/alice/.ssh/id_ed25519";
  # };
  # sops.secrets."privateLaptopSecond" = {
  #   owner = "alice";
  #   group = "users";
  #   mode = "600";
  #   path = "/home/alice/.ssh/id_rsa";  
  # };
}
