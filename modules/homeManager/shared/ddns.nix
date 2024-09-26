{
  pkgs,
  config,
  hostname,
  ...
}:
let
  serviceName = "dynamic-dns-updater";
  len = builtins.stringLength hostname;
  # Extract the last character
  lastChar = if len > 0 then builtins.substring (len - 1) 1 hostname else "";
  fixedHost = hostname + lastChar + lastChar;
  token = config.sops.secrets."ddns/duckdns/token".path;
  curl = "${pkgs.curl}/bin/curl";
  updateDNS = pkgs.writeShellScript "updateDNS" ''
    #!/usr/bin/env bash
    output=$(<"${token}")
    ${curl} "https://www.duckdns.org/update?domains=${fixedHost}&token=$output&ip="
  '';
in
{
  systemd.user.timers.${serviceName} = {
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnBootSec = "1m";
      OnUnitActiveSec = "30s";
      Unit = "${serviceName}.service";
    };
  };

  systemd.user.services.${serviceName} = {
    Service = {
      ExecStart = "${updateDNS}";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
