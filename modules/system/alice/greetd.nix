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

  # Password
  security.pam.services.greetd = { };
  security.pam.services.swaylock = { };
  security.pam.services.greetd.enableGnomeKeyring = true;

}
