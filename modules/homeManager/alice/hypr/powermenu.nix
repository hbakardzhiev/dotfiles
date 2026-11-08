{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "fuzzel-power" ''
      menu=(
        "🔒 Lock:loginctl lock-session"
        "💤 Suspend:systemctl suspend"
        "🛑 Hibernate:systemctl hibernate"
        "🔄 Reboot:systemctl reboot"
        "⏻ Shutdown:systemctl poweroff"
        "🚪 Logout:pkill hyprland"
      )

      labels=()
      for entry in "''${menu[@]}"; do
        labels+=("''${entry%%:*}")
      done

      selection=$(printf '%s\n' "''${labels[@]}" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Power:")

      case "$selection" in
        "🔒 Lock") loginctl lock-session ;;
        "💤 Suspend") systemctl suspend ;;
        "🛑 Hibernate") systemctl hibernate ;;
        "🔄 Reboot") systemctl reboot ;;
        "⏻ Shutdown") systemctl poweroff ;;
        "🚪 Logout") pkill hyprland ;;
        *) exit 0 ;;
      esac
    '')
  ];
}
