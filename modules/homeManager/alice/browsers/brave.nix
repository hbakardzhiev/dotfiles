{
  pkgs-stable,
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
    ];
    extensions = [
      # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } #ublock-origin
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsorblock
      # { id = "blaaajhemilngeeffpbfkdjjoefldkok"; } # leechblock
      { id = "ifbmcpbgkhlpfcodhjhdbllhiaomkdej"; } # Office - Enable Copy and Paste (for word,excel...)
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "kpgefcfmnafjgpblomihpgmejjdanjjp"; } # Nos2x
      { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # plasma browser integration
      # { id = "cnjifjpddelmedmihgijeibhnjfabmlf"; } # Obsidian Web Clipper
    ];
    # Brave was dropped from nixpkgs-unstable on 2026-11-03 (no maintainer to
    # handle security updates), so it comes from the 26.05 pin while the rest
    # of the host is unstable.
    package = pkgs-stable.brave;
  };
}
