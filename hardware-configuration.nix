# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8e25e57b-ea12-4ed7-a451-0938cc3c3e4f";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F1C4-5F70";
      fsType = "vfat";
    };

  #swapDevices =
  #  [ { device = "/dev/disk/by-uuid/6b7a5be7-8d31-4e79-b159-735a5d4025de"; }
  #  ];

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
