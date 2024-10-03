{ config, ... }:
{
  sops.secrets."nextcloud/username" = { };
  sops.secrets."nextcloud/Password" = { };

  services.openssh.settings.StrictModes = false;

  # sops.secrets."ssh/laptop/private" = { 
  # };
  # sops.secrets."privateLaptop" = {
  #   owner = "alice";
  #   group = "users";
  #   mode = "0600";
  #   path = "/home/alice/.ssh/id_ed25519";
  # };

  sops.secrets."privateLaptop1" = {};
  sops.secrets."privateLaptop2" = {};
  sops.secrets."privateLaptop3" = {};
  sops.secrets."privateLaptop4" = {};
  sops.secrets."privateLaptop5" = {};

  sops.templates."privateLaptopAll" = {
    owner = "alice";
    group = "users";
    content = ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      ${config.sops.placeholder."privateLaptop1"}
      ${config.sops.placeholder."privateLaptop2"}
      ${config.sops.placeholder."privateLaptop3"}
      ${config.sops.placeholder."privateLaptop4"}
      ${config.sops.placeholder."privateLaptop5"}
      -----END OPENSSH PRIVATE KEY-----
    '';
    path = "/home/alice/.ssh/id_ed25519";
    mode = "0600";
  };
  # sops.secrets."privateLaptopSecond" = {
  #   owner = "alice";
  #   group = "users";
  #   mode = "600";
  #   path = "/home/alice/.ssh/id_rsa";  
  # };
}
