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
}
