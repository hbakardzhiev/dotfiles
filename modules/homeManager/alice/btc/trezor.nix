{ pkgs, ... }:
{
  home.packages = with pkgs; [
    trezor-udev-rules
    trezorctl
    sparrow
  ];
}
