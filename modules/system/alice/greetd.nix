{ pkgs, ... }:
let
  sway = "${pkgs.sway}/bin/sway --unsupported-gpu";
  swayRun = pkgs.writeShellScript "sway-run" ''
    ${sway}
  '';
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
          --asterisks \
          --user-menu \
          --cmd ${swayRun}'';
    };
  };

  environment.etc."greetd/environments".text = ''
    ${sway} 
  '';

  # Password
  security.pam.services.greetd = { };
  security.pam.services.swaylock = { };
  security.pam.services.greetd.enableGnomeKeyring = true;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
  };

}
