{ config, pkgs, ... }:
{
  # SDDM logs alice in automatically, so there is no password for
  # pam_gnome_keyring to unlock the keyring with. Instead, unlock the "login"
  # keyring from the password sops renders at boot. That keyring holds the
  # Chrome/Brave/Chromium "Safe Storage" keys and the Nextcloud credentials.
  #
  # `gnome-keyring-daemon --unlock` only ever unlocks the keyring whose id is
  # "login" (daemon/login/gkd-login.c), which is why the secrets had to be
  # moved there and why ~/.local/share/keyrings/default no longer exists.
  systemd.user.services.gnome-keyring-unlock = {
    description = "Unlock the GNOME login keyring";
    wantedBy = [ "default.target" ];
    # Run before Hyprland's exec-once apps ask the Secret Service for secrets.
    before = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      # The daemon forks and must outlive this unit, otherwise it is reaped
      # together with the oneshot.
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "gnome-keyring-unlock" ''
        exec ${config.security.wrapperDir}/gnome-keyring-daemon --unlock \
          < ${config.sops.secrets."keyring/password".path}
      '';
    };
  };
}
