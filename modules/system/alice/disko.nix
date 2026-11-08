{ ... }:
{
  # Declarative layout for the OS disk only. This is applied exclusively by
  # running disko from the installer:
  #
  #   disko --mode destroy,format,mount --flake <flake>#alice
  #
  # It names the NVMe by-id, so no other disk (in particular the encrypted
  # data disk) can be selected by accident. Nothing here runs at boot or
  # activation time.
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-PUSKILL_SSD_512GB_00000000000410";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0077"
              "dmask=0077"
            ];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
