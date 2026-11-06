{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  cfg = config.services.opencode;

  mcpServers = {
    nixos = {
      type = "local";
      command = [ "${pkgs-unstable.mcp-nixos}/bin/mcp-nixos" ];
    };
    language-server = {
      type = "local";
      command = [
        "${pkgs-unstable.mcp-language-server}/bin/mcp-language-server"
        "--workspace"
        "."
        "--lsp"
        cfg.mcp.languageServer.lsp
      ];
      cwd = ".";
    };
    fetch = {
      type = "local";
      command = [ "${pkgs-unstable.mcp-server-fetch}/bin/mcp-server-fetch" ];
    };
    memory = {
      type = "local";
      command = [ "${pkgs-unstable.mcp-server-memory}/bin/mcp-server-memory" ];
      environment = {
        MEMORY_FILE_PATH = cfg.mcp.memoryFile;
      };
    };
    playwright = {
      type = "local";
      command = [
        "${pkgs-unstable.playwright-mcp}/bin/playwright-mcp"
        "--headless"
        "--output-dir" "/tmp/opencode/playwright"
      ];
    };
  };
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

    mcp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Install and configure the bundled MCP servers (nixos,
          language-server, fetch and memory) for every OpenCode instance on
          this machine.
        '';
      };

      languageServer.lsp = lib.mkOption {
        type = lib.types.str;
        default = "${pkgs-unstable.nil}/bin/nil";
        description = ''
          Language server executable used by `mcp-language-server`. The
          default is `nil`, which provides Nix language support. Set this to
          another executable (for example `gopls` or `clangd`) to use a
          different language server.
        '';
      };

      memoryFile = lib.mkOption {
        type = lib.types.str;
        default = "${config.users.users.${cfg.user}.home}/.local/share/opencode/memory.jsonl";
        description = ''
          File the `memory` MCP server uses to persist its knowledge graph.
          The parent directory must already exist.
        '';
      };
    };

  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.password != "";
        message = "services.opencode.password must not be empty, otherwise the server runs without authentication.";
      }
    ];

    environment.systemPackages =
      [ cfg.package ]
      ++ lib.optionals cfg.mcp.enable (
        with pkgs-unstable;
        [
          mcp-nixos
          mcp-language-server
          mcp-server-fetch
          mcp-server-memory
          playwright-mcp
          nil
          mcp-server-filesystem
        ]
      );

    # Machine-wide OpenCode configuration (see /etc/opencode in the docs).
    # The MCP servers are referenced by store path so they work regardless of
    # the service PATH.
    environment.etc."opencode/opencode.json" = lib.mkIf cfg.mcp.enable {
      text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        mcp.servers = mcpServers;
      };
    };

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
