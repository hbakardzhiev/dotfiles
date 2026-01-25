# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ pkgs, ... }:
{
  services.fwupd.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };

  boot = {
    tmp.cleanOnBoot = true;
    supportedFilesystems = [ "ntfs" ];
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "mitigations=off" ];
  };

  networking = {
    networkmanager.enable = true;
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff \
           /run/current-system "$systemConfig"
    '';
  };

  security.polkit.enable = true;

  # fileSystems."/drives/Kraimorie" = {
  #   device = "https://admin@bakarh.ddns.net/remote.php/dav/files/admin";
  #   fsType = "davfs";
  #   options = [
  #     "x-systemd.automount"
  #     "noauto"
  #     "x-systemd.after=network-online.target"
  #     "x-systemd.mount-timeout=90"
  #   ];
  # };

  # 1. enable vaapi on OS-level
  # Intel graphics
  hardware.graphics = {
    # hardware.opengl in 24.05
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell+ Intel GPUs (most common for VA-API video decode)
      intel-vaapi-driver # Alternative driver, often better for browsers on Skylake+
      intel-compute-runtime # For OpenCL support if needed (e.g., filters)
      vpl-gpu-rt # Keep this if you have 11th gen+ Intel; it's for QSV
      libva-vdpau-driver # Helps with compatibility in hybrid setups
      libvdpau-va-gl # VDPAU to VA-API bridge, useful for NVIDIA fallback
    ];
  };

  # SSD
  services.fstrim.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.dbus.enable = true;
  security.rtkit.enable = true;

  users.groups = {
    plugdev = { };
    dialout = { };
    uucp = { };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    alice = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "video"
        "networkmanager"
        "kvm"
        "wireshark"
        "plugdev"
        "dialout"
        "uucp"
        "input"
      ];
      hashedPassword = "$y$j9T$Je7oMqyFeQFF244VubtEw.$53YOarmB6y1l8ZIvqIOCZtGuzg/c7C4rG6wGfVPnAR5";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHkwExx5RQgW1JsfmQ9oSfrqeHWISa4AiAiuLv/xYJX h.bakardzhiev@gmx.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgNfSEBbf7I2SxSNKN8B8qzVl8JLeTg78nTDVZMsnkH ed25519"
      ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowBroken = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "mydatabase" ];
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     #type database  DBuser  auth-method
  #     local all       all     trust
  #   '';
  #   # initialScript = pkgs.writeText "init-sql-script" ''alter user postgres with password 'myPassword';'';
  # };
}
