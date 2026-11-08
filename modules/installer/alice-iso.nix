{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Distinct volume label and image filename (nixos-alice-...).
  isoImage.edition = lib.mkForce "alice";

  networking.hostName = "alice-installer";

  # nixos-install --flake needs flakes enabled in the installer.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # The installer profile already enables sshd and root logins; the keys make
  # headless/remote installs possible.
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHkwExx5RQgW1JsfmQ9oSfrqeHWISa4AiAiuLv/xYJX h.bakardzhiev@gmx.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgNfSEBbf7I2SxSNKN8B8qzVl8JLeTg78nTDVZMsnkH ed25519"
  ];

  environment.systemPackages = with pkgs; [
    curl
    disko
    git
    tailscale
    vim
  ];

  # Convenient for installing over the tailnet.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # The disk layout lives in modules/system/alice/disko.nix; it is only
  # applied when disko is run explicitly, and it names the OS disk by-id.
  environment.etc."alice-install.txt".text = ''
    alice installer
    ===============

    This image installs the alice configuration from
    github:hbakardzhiev/dotfiles. Partitioning is declarative: the layout in
    modules/system/alice/disko.nix wipes the OS disk by its by-id path and
    leaves the encrypted data disk alone.

    1. Partition, format and mount the target:

         disko --mode destroy,format,mount --flake github:hbakardzhiev/dotfiles#alice

    2. Install:

         nixos-install --flake github:hbakardzhiev/dotfiles#alice

    3. The sops age key (~/.config/sops/age/keys.txt) has to be restored on
       the target before the first boot activates secrets.

    Remote installs: the installer runs sshd and accepts the keys in
    /root/.ssh/authorized_keys. `tailscale up` joins the tailnet.
  '';
}
