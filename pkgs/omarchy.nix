{
  lib,
  stdenvNoCC,
  src,
  bash,
  coreutils,
  findutils,
  gnused,
  gnugrep,
  gawk,
  python3,
}:

stdenvNoCC.mkDerivation {
  pname = "omarchy";
  version = "4.5.0";

  inherit src;

  nativeBuildInputs = [
    bash
    coreutils
    findutils
    gnused
    gnugrep
    gawk
    python3
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/omarchy" "$out/bin"
    cp -r bin default shell themes config "$out/share/omarchy/"
    cp version icon.png icon.txt logo.svg logo.txt "$out/share/omarchy/"
    chmod -R u+w "$out/share/omarchy"

    # Omarchy is written for /usr/share/omarchy. The tree lives in the store
    # here, so every hard-coded path has to follow it. A few scripts also name
    # their siblings by absolute path in /usr/bin.
    while IFS= read -r -d "" file; do
      sed -i \
        -e "s|/usr/share/omarchy|$out/share/omarchy|g" \
        -e "s|/usr/bin/omarchy|$out/bin/omarchy|g" \
        "$file"
    done < <(grep -rlZI -e "/usr/share/omarchy" -e "/usr/bin/omarchy" "$out/share/omarchy" || true)

    patchShebangs "$out/share/omarchy/bin"

    # This tree is declarative: the NixOS module owns ~/.config, so the
    # first-run provisioner must not rewrite it, and herdr is not installed.
    sed -i \
      -e '/omarchy-provision-first-run/d' \
      -e '/-- Start the herdr server/,/hl.exec_cmd(o.launch("herdr server"))/d' \
      "$out/share/omarchy/default/hypr/autostart.lua"

    # The scripts call each other by name, so expose the whole bin directory.
    # OMARCHY_PATH is set system-wide by the NixOS module.
    for script in "$out/share/omarchy/bin"/*; do
      ln -s "$script" "$out/bin/$(basename "$script")"
    done

    runHook postInstall
  '';

  meta = {
    description = "Omarchy 4.5.0 desktop tree vendored for NixOS";
    homepage = "https://omarchy.org";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
