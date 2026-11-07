# nixpkgs-unstable at the pinned revision carries the pre-fix hash for
# opencode's bun `node_modules` fixed-output derivation. Upstream fixed it in
# c399e1b7 ("opencode: fix hash", 2026-11-03), making the hash platform
# dependent because bun resolves host-specific optionals.
#
# Drop this overlay once the nixpkgs-unstable pin is past that commit.
final: prev: {
  opencode = prev.opencode.overrideAttrs (old: {
    node_modules = old.node_modules.overrideAttrs (_: {
      outputHash =
        if final.stdenv.hostPlatform.isLinux then
          "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA="
        else if final.stdenv.hostPlatform.isDarwin then
          "sha256-dIveiaiPFGSItwLyeMuPDxTE9gpvvnlTCB/+nG24qCc="
        else
          throw "opencode: unsupported platform for the node_modules hash";
    });
  });
}
