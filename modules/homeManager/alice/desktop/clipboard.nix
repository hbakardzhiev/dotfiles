{ pkgs, ... }:
let
  # Omarchy-style universal clipboard:
  #   SUPER+C       -> copy in the focused app (Ctrl+Shift+C in terminals)
  #   SUPER+V       -> fuzzel history, restore the entry, then paste it
  #   SUPER+SHIFT+V -> paste the current clipboard directly
  #
  # The watcher is a single wl-paste process rather than the Home Manager
  # cliphist service, because cliphist's default text watcher only sees
  # Nautilus' text/plain fallback (the filename). This helper inspects the
  # offered MIME types and stores the useful representation instead.
  clipboard = pkgs.writeShellApplication {
    name = "clipboard";

    runtimeInputs = with pkgs; [
      cliphist
      coreutils
      file
      fuzzel
      gnugrep
      hyprland
      jq
      wl-clipboard
    ];

    text = ''
      # A single scratch directory per invocation. It must be global so the
      # EXIT trap still sees it after a helper function has returned.
      workdir=""
      cleanup() {
        if [ -n "$workdir" ]; then
          rm -rf "$workdir"
        fi
      }
      trap cleanup EXIT

      # Hyprland 0.57 parses `hyprctl dispatch` arguments as Lua.
      send_shortcut() {
        local mods="$1"
        local key="$2"
        hyprctl dispatch "hl.dsp.send_shortcut({ mods = \"$mods\", key = \"$key\" })" >/dev/null
      }

      active_class() {
        hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty'
      }

      # Terminals do not use the CUA copy/paste shortcuts: Ctrl+C is SIGINT and
      # Shift+Insert often pastes the primary selection instead of the
      # clipboard. Their clipboard shortcuts are Ctrl+Shift+C / Ctrl+Shift+V.
      is_terminal() {
        case "$1" in
          Alacritty | alacritty | kitty | foot | footclient) return 0 ;;
          org.wezfurlong.wezterm | WezTerm) return 0 ;;
          com.mitchellh.ghostty | ghostty) return 0 ;;
          konsole | gnome-terminal-server | gnome-terminal | org.gnome.Console | kgx) return 0 ;;
          XTerm | xterm | URxvt | urxvt | st | termite | tilix) return 0 ;;
          xfce4-terminal | mate-terminal | lxterminal | qterminal | terminology | sakura) return 0 ;;
        esac
        return 1
      }

      copy() {
        if is_terminal "$(active_class)"; then
          send_shortcut "CTRL SHIFT" "c"
        else
          send_shortcut "CTRL" "c"
        fi
      }

      paste() {
        if is_terminal "$(active_class)"; then
          send_shortcut "CTRL SHIFT" "v"
        else
          send_shortcut "CTRL" "v"
        fi
      }

      store() {
        local types image state
        workdir="$(mktemp -d "''${XDG_RUNTIME_DIR:-/tmp}/clipboard-store.XXXXXX")"

        # Drain the event wl-paste was watching. Otherwise a large image can
        # block the pipe while we re-request the representation we want.
        cat > "$workdir/event"

        state="''${CLIPBOARD_STATE:-}"
        # Never record a password manager's sensitive offer. Clear events are
        # ignored too: the content is already in history.
        if [ "$state" = "sensitive" ] || [ "$state" = "clear" ]; then
          exit 0
        fi

        types="$(wl-paste --list-types 2>/dev/null || true)"
        if [ -z "$types" ]; then
          [ -s "$workdir/event" ] && cliphist store < "$workdir/event"
          exit 0
        fi

        # File managers offer text/plain (just the filename) and
        # text/uri-list (the actual file list). Prefer the URI list, but only
        # when it points at local files; a copied hyperlink is plain text.
        if grep -qx 'text/uri-list' <<<"$types"; then
          wl-paste --type text/uri-list > "$workdir/uri" 2>/dev/null || true
          if grep -q '^file://' "$workdir/uri"; then
            cliphist store < "$workdir/uri"
            return
          fi
        fi

        # A browser image also offers text/html and text/plain. Prefer the
        # image so the entry can be restored as an image later.
        image="$(grep -m1 '^image/' <<<"$types" || true)"
        if [ -n "$image" ]; then
          if wl-paste --type "$image" > "$workdir/data" 2>/dev/null && [ -s "$workdir/data" ]; then
            cliphist store < "$workdir/data"
            return
          fi
        fi

        if grep -q '^text/plain' <<<"$types"; then
          if wl-paste --type text > "$workdir/data" 2>/dev/null && [ -s "$workdir/data" ]; then
            cliphist store < "$workdir/data"
            return
          fi
        fi

        # Fall back to whatever wl-paste handed to the watcher.
        [ -s "$workdir/event" ] && cliphist store < "$workdir/event"
        return 0
      }

      menu() {
        local history id newest preview line mime
        history="$(cliphist list || true)"
        if [ -z "$history" ]; then
          paste
          return
        fi

        id="$(printf '%s\n' "$history" | fuzzel --dmenu \
          --with-nth 2 \
          --accept-nth 1 \
          --no-sort \
          --counter \
          --lines 12 \
          --prompt 'Clipboard: ' \
          --placeholder 'Search clipboard' || true)"

        [ -z "$id" ] && return 0

        newest="''${history%%$'\t'*}"
        if [ "$id" = "$newest" ] && wl-paste --list-types >/dev/null 2>&1; then
          # The clipboard still owns this entry. Paste it unchanged so the
          # original formats (rich text, copy/cut file lists) survive.
          :
        else
          workdir="$(mktemp -d "''${XDG_RUNTIME_DIR:-/tmp}/clipboard-pick.XXXXXX")"
          cliphist decode "$id" > "$workdir/data"

          line="$(printf '%s\n' "$history" | grep -m1 -E "^''${id}"$'\t' || true)"
          preview="''${line#*$'\t'}"

          # wl-clipboard 2.3.0 does not expose CLIPBOARD_TYPE to cliphist, so
          # recover the type from the preview (images) or the content.
          mime=""
          if [[ "$preview" =~ \[\[.*\ (png|jpeg|gif|webp|bmp|tiff)\ [0-9]+x[0-9]+\ \]\] ]]; then
            mime="image/''${BASH_REMATCH[1]}"
          elif grep -q '^file://' "$workdir/data"; then
            mime="text/uri-list"
            grep -E '^(file|https?|ftp)://' "$workdir/data" > "$workdir/uri"
            mv "$workdir/uri" "$workdir/data"
          else
            mime="$(file -b --mime-type "$workdir/data")"
            case "$mime" in
              text/* | application/json | application/xml | application/javascript)
                mime="text/plain"
                ;;
            esac
          fi

          wl-copy --type "$mime" < "$workdir/data"
          sleep 0.05
        fi

        # Let the picker close and focus return before synthesizing the paste.
        sleep 0.15
        paste
      }

      case "''${1:-menu}" in
        store) store ;;
        copy) copy ;;
        paste) paste ;;
        menu) menu ;;
        *)
          echo "usage: clipboard {store|copy|paste|menu}" >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  home.packages = [
    clipboard
    pkgs.cliphist
  ];

  xdg.configFile."cliphist/config".text = ''
    max-items 1000
    max-dedupe-search 20
    max-store-size 10MB
    preview-width 120
  '';

  systemd.user.services.clipboard-history = {
    Unit = {
      Description = "Universal clipboard history";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${clipboard}/bin/clipboard store";
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
