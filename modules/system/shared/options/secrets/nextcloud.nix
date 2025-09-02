{
  config,
  lib,
  ...
}:
let
  cfg = config.security.sops.nextcloud;
in
{
  # Define options for lid switch behavior
  options.security.sops.nextcloud = {
    enable = lib.mkEnableOption "Enable nextcloud sops secrets";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."nextcloud/username" = {
      owner = "alice";
    };
    sops.secrets."nextcloud/Password" = {
      owner = "alice";
    };
  };
}
