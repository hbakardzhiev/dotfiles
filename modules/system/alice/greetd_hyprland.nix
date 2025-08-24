{ pkgs, config, ... }:
let
  hyprland = "${pkgs.hyprland}/bin/Hyprland";
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = hyprland;
        user = config.users.users.alice.name;
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    ${hyprland} 
  '';

  environment.systemPackages = [ pkgs.gnome-keyring ];

  security.pam.services.greetd = { };
  security.pam.services.hyprlock = { };
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.greetd.kwallet.enable = true;

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
    DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
  };
}
