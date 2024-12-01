{ config, ... }:
{
  # services.openssh.settings.StrictModes = false;

  sops.secrets."privateLaptop1" = { };
  sops.secrets."privateLaptop2" = { };
  sops.secrets."privateLaptop3" = { };
  sops.secrets."privateLaptop4" = { };
  sops.secrets."privateLaptop5" = { };

  sops.secrets."rsa1" = { };
  sops.secrets."rsa2" = { };
  sops.secrets."rsa3" = { };
  sops.secrets."rsa4" = { };
  sops.secrets."rsa5" = { };
  sops.secrets."rsa6" = { };
  sops.secrets."rsa7" = { };
  sops.secrets."rsa8" = { };
  sops.secrets."rsa9" = { };
  sops.secrets."rsa10" = { };
  sops.secrets."rsa11" = { };
  sops.secrets."rsa12" = { };
  sops.secrets."rsa14" = { };
  sops.secrets."rsa15" = { };
  sops.secrets."rsa16" = { };
  sops.secrets."rsa17" = { };
  sops.secrets."rsa18" = { };
  sops.secrets."rsa19" = { };
  sops.secrets."rsa20" = { };
  sops.secrets."rsa21" = { };
  sops.secrets."rsa22" = { };
  sops.secrets."rsa23" = { };
  sops.secrets."rsa24" = { };
  sops.secrets."rsa25" = { };
  sops.secrets."rsa26" = { };
  sops.secrets."rsa27" = { };
  sops.secrets."rsa28" = { };
  sops.secrets."rsa29" = { };
  sops.secrets."rsa30" = { };
  sops.secrets."rsa31" = { };
  sops.secrets."rsa32" = { };
  sops.secrets."rsa33" = { };
  sops.secrets."rsa34" = { };
  sops.secrets."rsa35" = { };
  sops.secrets."rsa36" = { };
  sops.secrets."rsa37" = { };

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
  sops.templates."rsaAll" = {
    owner = "alice";
    group = "users";
    content = ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      ${config.sops.placeholder."rsa1"}
      ${config.sops.placeholder."rsa2"}
      ${config.sops.placeholder."rsa3"}
      ${config.sops.placeholder."rsa4"}
      ${config.sops.placeholder."rsa5"}
      ${config.sops.placeholder."rsa6"}
      ${config.sops.placeholder."rsa7"}
      ${config.sops.placeholder."rsa8"}
      ${config.sops.placeholder."rsa9"}
      ${config.sops.placeholder."rsa10"}
      ${config.sops.placeholder."rsa11"}
      ${config.sops.placeholder."rsa12"}
      ${config.sops.placeholder."rsa14"}
      ${config.sops.placeholder."rsa15"}
      ${config.sops.placeholder."rsa16"}
      ${config.sops.placeholder."rsa17"}
      ${config.sops.placeholder."rsa18"}
      ${config.sops.placeholder."rsa19"}
      ${config.sops.placeholder."rsa20"}
      ${config.sops.placeholder."rsa21"}
      ${config.sops.placeholder."rsa22"}
      ${config.sops.placeholder."rsa23"}
      ${config.sops.placeholder."rsa24"}
      ${config.sops.placeholder."rsa25"}
      ${config.sops.placeholder."rsa26"}
      ${config.sops.placeholder."rsa27"}
      ${config.sops.placeholder."rsa28"}
      ${config.sops.placeholder."rsa29"}
      ${config.sops.placeholder."rsa30"}
      ${config.sops.placeholder."rsa31"}
      ${config.sops.placeholder."rsa32"}
      ${config.sops.placeholder."rsa33"}
      ${config.sops.placeholder."rsa34"}
      ${config.sops.placeholder."rsa35"}
      ${config.sops.placeholder."rsa36"}
      ${config.sops.placeholder."rsa37"}
      -----END OPENSSH PRIVATE KEY-----
    '';
    path = "/home/alice/.ssh/id_rsa";
    mode = "0600";
  };
  # sops.secrets."privateLaptopSecond" = {
  #   owner = "alice";
  #   group = "users";
  #   mode = "600";
  #   path = "/home/alice/.ssh/id_rsa";
  # };
}
