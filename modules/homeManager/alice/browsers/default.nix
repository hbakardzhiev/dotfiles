{
  pkgs,
  ...
}:
{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      # "--ignore-gpu-blocklist"
      # "-incognito"
      # "--enable-drdc"
      # "--enable-drdc-vulkan"
      # "--skia-graphite-backend"
      # "--enable-vulkan"
      # "--enable-unsafe-webgpu"
      # "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
      # "--enable-features=UseOzonePlatform"
      # "--ozone-platform=wayland"

      # "--ozone-platform=wayland"
      # # Chromium allocates GBM buffers on the first DRM node, which is the
      # # NVIDIA card (card0) on this hybrid setup. Pin it to i915 so Brave never
      # # exports dma-bufs from the NVIDIA driver (open-gpu-kernel-modules#1037).
      # "--render-node-override=/dev/dri/renderD128"
      # # Fallback if crashes persist:
      # # "--disable-gpu-compositing"
    ];
    extensions = [
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsorblock
      # { id = "blaaajhemilngeeffpbfkdjjoefldkok"; } # leechblock
      # { id = "ifbmcpbgkhlpfcodhjhdbllhiaomkdej"; } # Office - Enable Copy and Paste (for word,excel...)
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      # { id = "kpgefcfmnafjgpblomihpgmejjdanjjp"; } # Nos2x
      { id = "fnaicdffflnofjppbagibeoednhnbjhg"; } # Floccus bookmark sync
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; } # ublock origin lite
      # { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # plasma browser integration
      # { id = "cnjifjpddelmedmihgijeibhnjfabmlf"; } # Obsidian Web Clipper
    ];
    # Brave was dropped from nixpkgs-unstable on 2026-11-03 (no maintainer to
    # handle security updates), so it comes from the 26.05 pin while the rest
    # of the host is unstable.
    package = pkgs.chromium;
  };
}
