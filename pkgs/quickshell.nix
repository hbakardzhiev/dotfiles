{ pkgs, pkgs-unstable }:

# quickshell 0.3.2 asks isLocked() after releasing the session lock, so
# lockStateChanged never fires and the shell believes it is still locked.
# The next lock request is then a silent no-op, which strands the session.
# nixarchy carries the same patch; 0.3.1 and earlier do not need it.
pkgs-unstable.quickshell.overrideAttrs (old: {
  patches =
    (old.patches or [ ])
    ++ pkgs-unstable.lib.optionals (old.version == "0.3.2") [
      ./quickshell-unlock-signal.patch
    ];

  # The Omarchy shell paints the theme background (a .webp) and reads WebP
  # thumbnails; qtbase alone has no WebP image plugin.
  buildInputs = (old.buildInputs or [ ]) ++ [ pkgs-unstable.qt6.qtimageformats ];
})
