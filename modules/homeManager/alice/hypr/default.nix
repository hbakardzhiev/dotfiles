{
  lib,
  omarchyPkg,
  ...
}:
let
  # The live file falls back to /usr/share/omarchy when OMARCHY_PATH is unset.
  # The tree lives in the store here, so point the fallback at it as well.
  hyprlandLua = lib.replaceStrings
    [ ''"/usr/share/omarchy"'' ]
    [ ''"${omarchyPkg}/share/omarchy"'' ]
    (builtins.readFile ./hyprland.lua);
in
{
  # Personal Hyprland overrides, copied from the running Omarchy install.
  # hyprland.lua loads Omarchy's defaults from $OMARCHY_PATH and then these
  # files, in the same order upstream documents.
  home.file = {
    ".config/hypr/hyprland.lua".text = hyprlandLua;
    ".config/hypr/bindings.lua".source = ./bindings.lua;
    ".config/hypr/input.lua".source = ./input.lua;
    ".config/hypr/monitors.lua".source = ./monitors.lua;
    ".config/hypr/looknfeel.lua".source = ./looknfeel.lua;
    ".config/hypr/autostart.lua".source = ./autostart.lua;
  };
}
