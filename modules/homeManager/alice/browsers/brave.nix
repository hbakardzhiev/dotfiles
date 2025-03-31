{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      # "--ignore-gpu-blocklist"
      # "-incognito"
      "--enable-drdc"
      "--enable-drdc-vulkan"
      "--skia-graphite-backend"
      "--enable-vulkan"
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
      { id = "kbfnbcaeplbcioakkpcpgfkobkghlhen"; } # Grammarly
      { id = "cnjifjpddelmedmihgijeibhnjfabmlf"; } # Obsidian Web Clipper
    ];
    package = pkgs.brave;
  };
}
