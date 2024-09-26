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
      "ssh/laptop" = {
        # owner = "alice";
        # neededForUsers = true;
      };
      "ssh/phone" = {
        # owner = "alice";
        # neededForUsers = true;
      };
      "ddns/duckdns/token" = {
        # owner = "alice";
      };
      # "nextcloud/username" = {};
      # "nextcloud/bobIP" = {};
      # nextcloud = {
      #   username = {};
      #   bobIP = {};
      #   # username = {};
      #   password = {};
      #   # bobIP = {};
      # };
    };

    # sops.defaultSopsFile = ./secrets/secrets.yaml;
    # sops.defaultSopsFormat = "yaml";
    # secrets.test = {
    #   # sopsFile = ./secrets.yml.enc; # optionally define per-secret files

    #   # %r gets replaced with a runtime directory, use %% to specify a '%'
    #   # sign. Runtime dir is $XDG_RUNTIME_DIR on linux and $(getconf
    #   # DARWIN_USER_TEMP_DIR) on darwin.
    #   path = "%r/test.txt"; 
    # };
  };
}
