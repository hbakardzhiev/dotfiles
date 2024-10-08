{ pkgs, ... }:
let
  sway = "${pkgs.sway}/bin/sway";
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
          --cmd ${sway}'';
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
