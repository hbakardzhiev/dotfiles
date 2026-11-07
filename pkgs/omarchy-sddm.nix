{
  lib,
  stdenvNoCC,
  src,
  omarchy,
}:

stdenvNoCC.mkDerivation {
  pname = "omarchy-sddm-theme";
  version = "4.5.0";

  inherit src;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/sddm/themes" "$out/share/omarchy-sddm"
    cp -r default/sddm/omarchy "$out/share/sddm/themes/omarchy"
    cp default/sddm/hyprland.lua "$out/share/omarchy-sddm/hyprland.lua"

    chmod -R u+w "$out"
    sed -i "s|/usr/share/omarchy|${omarchy}/share/omarchy|g" \
      "$out/share/omarchy-sddm/hyprland.lua"

    runHook postInstall
  '';

  meta = {
    description = "Omarchy's SDDM greeter theme";
    homepage = "https://omarchy.org";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
