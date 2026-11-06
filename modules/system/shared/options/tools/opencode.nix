{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.services.opencode;
in
{
  options.services.opencode = {
    enable = lib.mkEnableOption "the OpenCode headless server";

    user = lib.mkOption {
      type = lib.types.str;
      default = "alice";
      description = "User account that runs the OpenCode server.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4096;
      description = ''
        TCP port the OpenCode server listens on. Keep it fixed so the web UI
        URL and the login session stay the same across restarts.
      '';
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Address the OpenCode server binds to. Set to "0.0.0.0" to allow access
        from other hosts, for example over Tailscale.
      '';
    };

    password = lib.mkOption {
      type = lib.types.str;
      default = "opencode";
      description = ''
        Password for the built-in HTTP basic authentication. The username is
        always `opencode`, so the stable login URL is
        `http://opencode:<password>@<host>:<port>`.

        The value is stored world-readably in the Nix store; override it if
        that is not acceptable.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs-unstable.opencode;
      defaultText = lib.literalExpression "pkgs-unstable.opencode";
      description = "OpenCode package providing the `opencode` executable.";
    };

  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.password != "";
        message = "services.opencode.password must not be empty, otherwise the server runs without authentication.";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    # Keep the user systemd manager running without an active login, so the
    # service starts at boot and survives logout.
    users.users.${cfg.user}.linger = true;

    systemd.user.services.opencode = {
      description = "OpenCode headless server";
      wantedBy = [ "default.target" ];
      after = [ "network.target" ];
      environment = {
        OPENCODE_SERVER_PASSWORD = cfg.password;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/opencode serve --hostname ${cfg.hostname} --port ${toString cfg.port}";
        WorkingDirectory = "%h";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
