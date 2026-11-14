{
  pkgs,
  ...
}:
let
  # Waybar's S.M.A.R.T. helper. The Python source stays a plain file, but the
  # executable is a Nix derivation so python3, busctl (udisks2 is queried over
  # D-Bus) and notify-send are pinned instead of coming from whatever PATH
  # Waybar happens to inherit.
  disk-health = pkgs.writeShellApplication {
    name = "disk-health";
    runtimeInputs = with pkgs; [
      libnotify
      python3
      systemd
    ];
    text = ''
      exec python3 ${./disk-health.py} "$@"
    '';
  };
in
{
  home.packages = [ disk-health ];
}
