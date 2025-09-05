{
  config,
  lib,
  ...
}:
let
  cfg = config.custom.containers.docker; # Use a custom top-level option instead of containers.docker
in
{
  # Define options for Docker
  options.custom.containers.docker = {
    enable = lib.mkEnableOption "Enable Docker";
  };

  config = lib.mkIf cfg.enable {
    # Enable Docker
    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        pruning = {
          enabled = true;
          interval = "24h";
        };
      };
    };
    users.users.alice.extraGroups = [ "docker" ];
  };
}
