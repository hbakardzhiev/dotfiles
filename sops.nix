{ ... }:
{
  sops = {
    age.keyFile = "/home/alice/.config/sops/age/keys.txt"; # must have no password!
    # It's also possible to use a ssh key, but only when it has no password:
    # age.sshKeyPaths = [ "/home/alice/.ssh/id_ed25519" ];
    defaultSopsFormat = "yaml";
    defaultSopsFile = ./secrets/allSecrets/secrets.yaml;
    secrets = {
      test = { };
      # "ssh/laptop" = {
      # owner = "alice";
      # neededForUsers = true;
      # };
      # "ssh/phone" = {
      # owner = "alice";
      # neededForUsers = true;
      # };
      "ddns/duckdns/token" = {
        # owner = "alice";
      };
    };
  };
}
