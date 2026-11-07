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

  # This ISO deliberately ships no disk layout: partition and mount the target
  # yourself, then install. disko is available as a tool, not configured.
  environment.etc."alice-install.txt".text = ''
    alice installer
    ===============

    This image installs the alice configuration from
    github:hbakardzhiev/dotfiles. It contains no disk layout; nothing is
    partitioned or formatted automatically.

    1. Partition and format the target disk, unlock its LUKS container and
       mount the filesystems under /mnt. The alice configuration refers to
       the existing LUKS and filesystem UUIDs, so a fresh layout needs them
       updated in alice.nix and hardware-configuration.nix first.

    2. Install:

         nixos-install --flake github:hbakardzhiev/dotfiles#alice

    3. The sops age key (~/.config/sops/age/keys.txt) has to be restored on
       the target before the first boot activates secrets.

    Remote installs: the installer runs sshd and accepts the keys in
    /root/.ssh/authorized_keys. `tailscale up` joins the tailnet.
  '';
}
