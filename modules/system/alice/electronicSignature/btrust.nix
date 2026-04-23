{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    google-chrome
    # (optional but recommended for the next steps)
    nss
    nssTools
    opensc
    ccid
    p11-kit
    pcsc-tools
  ];

  # Smart-card daemon (required for any reader)
  services.pcscd.enable = true;
}
