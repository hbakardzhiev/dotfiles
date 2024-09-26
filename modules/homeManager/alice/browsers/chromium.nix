{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      # "--ignore-gpu-blocklist"
      # "-incognito"
      "--enable-drdc"
      # "--enable-unsafe-webgpu"
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
    ];
    extensions = [
      # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } #ublock-origin
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # vimium
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsorblock
    ];
    package = pkgs.brave;
  };
}
