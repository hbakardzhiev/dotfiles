{
  pkgs,
  omarchy,
  omarchyPkg,
  ...
}:
let
  # Run Omarchy's own template renderer once, at build time. It turns
  # themes/flexoki-light/colors.toml into the shell, terminal, btop and
  # Hyprland files that `omarchy-theme-set` would otherwise write at runtime.
  theme = pkgs.runCommand "omarchy-theme-flexoki-light" {
    nativeBuildInputs = with pkgs; [
      bash
      coreutils
      gawk
      gnugrep
      gnused
    ];
  } ''
    export HOME="$TMPDIR/home"
    export OMARCHY_PATH="${omarchyPkg}/share/omarchy"

    mkdir -p "$HOME/.local/state/omarchy/current/next-theme"
    cp -r "${omarchyPkg}/share/omarchy/themes/flexoki-light/." \
      "$HOME/.local/state/omarchy/current/next-theme/"

    PATH="${omarchyPkg}/bin:$PATH" \
      bash "${omarchyPkg}/share/omarchy/bin/omarchy-theme-set-templates"

    mkdir -p "$out"
    cp -r "$HOME/.local/state/omarchy/current/next-theme/." "$out/"
  '';
in
{
  home.file = {
    # The shell and Hyprland read the active theme from here.
    ".local/state/omarchy/current/theme" = {
      source = theme;
      recursive = true;
    };
    ".local/state/omarchy/current/theme.name".text = "Flexoki Light\n";
    ".local/state/omarchy/current/background".source = "${theme}/backgrounds/1-orb.webp";

    # The user's Omarchy configuration, including the custom disk-health bar
    # widget and the bar layout that uses it.
    ".config/omarchy/shell.json".source = ./shell.json;
    ".config/omarchy/shell.toml".source = ./shell.toml;
    ".config/omarchy/plugins/alice.disk-health" = {
      source = ./plugins/alice.disk-health;
      recursive = true;
    };

    # Omarchy's own terminal, btop and shell defaults. Each one imports or
    # includes the generated file under ~/.local/state, so the palette lives in
    # one place: the theme rendered above.
    ".config/alacritty/alacritty.toml".source = "${omarchy}/config/alacritty/alacritty.toml";
    ".config/foot/foot.ini".source = "${omarchy}/config/foot/foot.ini";
    ".config/ghostty/config".source = "${omarchy}/config/ghostty/config";
    ".config/btop/btop.conf".source = "${omarchy}/config/btop/btop.conf";
    ".config/btop/themes/current.theme".source = "${theme}/btop.theme";

    # Omarchy's scripts launch a terminal through xdg-terminal-exec. Prefer the
    # same terminal Omarchy does, with Alacritty as the fallback.
    ".config/xdg-terminal-exec/xdg-terminals.list".text = ''
      foot.desktop
      alacritty.desktop
    '';

    # ~/.XCompose, with Omarchy's emoji compose file rewritten to the store
    # path the vendored tree lives at.
    ".XCompose".text = ''
      # Run omarchy-restart-xcompose to apply changes

      # Include fast emoji access
      include "${omarchyPkg}/share/omarchy/default/xcompose"

      # Identification
      <Multi_key> <space> <n> : "hbakardzhiev"
      <Multi_key> <space> <e> : ""
    '';
  };

  gtk = {
    enable = true;
    theme.name = "Adwaita";
    iconTheme.name = "Yaru-blue";
    font = {
      name = "Adwaita Sans";
      size = 11;
    };
  };
}
