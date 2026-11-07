{ lib, pkgs, ... }:
let
  # Damage on the two USB NTFS volumes, found 2026-11-07. Both were worked
  # around rather than repaired, because repairing NTFS needs `chkdsk` on
  # Windows. Remove the matching entries once the volumes are checked.
  #
  # /run/media/backup/.ntfs-corrupt/Gosho-bodrum-100PHOTO used to live at
  # `Gosho bodrum/100PHOTO`; its NTFS index is damaged and ntfs-3g fails the
  # whole readdir with EINVAL, which aborted the run with rsync exit code 23.
  # Renaming works, reading does not, so it was moved aside on the same volume.
  # The good copy is re-copied from /run/media/et1 below.
  #
  # On /run/media/et1 the same kind of damage left 70 directory entries that
  # readdir still lists but that can no longer be stat'ed ("file has vanished").
  # They sit in the five directories listed in extraExcludes; those are skipped
  # so the job can finish. Nothing readable is skipped: the affected
  # directories are either entirely unreadable or already fully mirrored.
  corruptDir = "/.ntfs-corrupt";

  extraExcludes = [
    "/ALL THE PICTURES FROM MAMS COMPUTER/Pictures/111OLYMP/"
    "/ALL THE PICTURES FROM MAMS COMPUTER/Pictures/14.09.2007-na Evrenezovo/"
    "/ALL THE PICTURES FROM MAMS COMPUTER/Pictures/09.06.2005-2/"
    "/ALL THE PICTURES FROM MAMS COMPUTER/Pictures/15.09.2007/"
    "/Oshte mnogo snimki/My Pictures/"
  ];

  backupScript = pkgs.writeShellScript "backup-et1-to-backup" ''
    set -euo pipefail

    src=/run/media/et1
    dst=/run/media/backup

    # Both disks are mounted with nofail, so booting succeeds without them.
    # Refuse to run in that case instead of copying into the root filesystem.
    for path in "$src" "$dst"; do
      if ! ${pkgs.util-linux}/bin/mountpoint -q "$path"; then
        echo "error: $path is not a mount point, refusing to back up" >&2
        exit 1
      fi
    done

    excludes=(
      --exclude='${corruptDir}/'
      --exclude='.git/'
    ${lib.concatMapStringsSep "\n" (p: "  --exclude='${p}'") extraExcludes}
    )

    exec ${pkgs.rsync}/bin/rsync -av --delete "''${excludes[@]}" "$src/" "$dst/"
  '';
in
{
  systemd.user.services.foo = {
    Unit = {
      Description = "Backup configuration";
    };
    Service = {
      Type = "oneshot";
      ExecStart = backupScript;
      # Skip the run when either USB disk is absent.
      ConditionPathIsMountPoint = [
        "/run/media/et1"
        "/run/media/backup"
      ];
    };
  };

  systemd.user.timers.foo = {
    Unit = {
      Description = "Timer for backup service";
    };
    Timer = {
      OnCalendar = "01:00:00";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
