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
    };
    users.users.alice.extraGroups = [ "docker" ];

    # services.caddy = {
    #   enable = true;
    #   virtualHosts."nocobase.v6.army" = {
    #     extraConfig = ''
    #       reverse_proxy 127.0.0.1:8055
    #     '';
    #   };
    # };
  };
}
