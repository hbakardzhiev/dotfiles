{
  lib,
  pkgs,
  ...
}:
let
  # Cycle order, starting after "off": very red -> 4000 K -> a bit bluer.
  levels = [
    3000
    4000
    5000
  ];

  # Each press advances one step; the level after the last one is "off".
  # hyprsunset's IPC has no "get" request, so the index is remembered in
  # $XDG_RUNTIME_DIR. A hyprsunset restart drops the filter, so a missing
  # state file correctly means "off".
  nightlight = pkgs.writeShellApplication {
    name = "nightlight";
    runtimeInputs = with pkgs; [
      hyprland
      libnotify
      procps
    ];
    text = ''
      runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      state_file="$runtime_dir/nightlight-level"
      temps=(${lib.concatMapStringsSep " " toString levels})
      count=''${#temps[@]}

      notify() {
        notify-send -a nightlight -t 1500 "$@" 2>/dev/null || true
      }

      # hyprsunset is autostarted by Hyprland, but start it if it is not
      # running (for example after a crash) so the keybind keeps working.
      ensure_hyprsunset() {
        pgrep -x hyprsunset >/dev/null && return 0
        setsid hyprsunset >/dev/null 2>&1 </dev/null &
        for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
          pgrep -x hyprsunset >/dev/null && return 0
          sleep 0.1
        done
      }

      # Index 0..count-1 selects a level, count means "off".
      current=$count
      if [ -r "$state_file" ]; then
        read -r current <"$state_file" || current=$count
      fi
      case "$current" in
        *[!0-9]*) current=$count ;;
      esac
      if [ -z "$current" ] || [ "$current" -gt "$count" ]; then
        current=$count
      fi

      next=$(((current + 1) % (count + 1)))

      ensure_hyprsunset

      if [ "$next" -lt "$count" ]; then
        temp=''${temps[$next]}
        if ! hyprctl hyprsunset temperature "$temp" >/dev/null; then
          notify -u critical "Nightlight failed" "hyprsunset IPC is not reachable"
          exit 1
        fi
        notify "Nightlight $((next + 1))/$count" "Display temperature ''${temp}K"
      else
        hyprctl hyprsunset identity >/dev/null
        notify "Nightlight off" "Normal display colours"
      fi

      printf '%s\n' "$next" >"$state_file"
    '';
  };
in
{
  home.packages = [ nightlight ];
}
