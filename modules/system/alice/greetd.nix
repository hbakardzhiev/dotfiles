{ pkgs, config, ... }:
let
  sway = "${pkgs.sway}/bin/sway --unsupported-gpu";
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = sway;
        user = config.users.users.alice.name;
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    ${sway} 
  '';

  environment.systemPackages = [ pkgs.gnome-keyring ];

  # Password
  security.pam.services.greetd = { };
  security.pam.services.swaylock = { };
  security.pam.services.greetd.enableGnomeKeyring = true;
  # security.pam.services.gdm-password.enableGnomeKeyring = true;

  systemd.user.services.gnome-keyring-daemon = {
    description = "GNOME Keyring Daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh";
      Restart = "on-failure";
      Type = "forking";
      Environment = "SSH_AUTH_SOCK=%t/keyring/ssh";
    };
  };

  environment.sessionVariables = {
    SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus"; # Adjust user ID if necessary
  };
}
