{ ... }:
{
  sops.secrets."nextcloud/username" = { };
  sops.secrets."nextcloud/Password" = { };

  # sops.templates."your-config-with-secrets.toml" = {
  #   content = ''
  #     default
  #     login "${config.sops.placeholder."nextcloud/username"}"
  #     password "${config.sops.placeholder."nextcloud/Password"}"
  #   '';
  #   path = "/home/alice/.netrc";
  # };
}
