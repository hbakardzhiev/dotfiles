{ pkgs, ... }:
{
  services.trezord = {
    enable = true;
  };
  environment.defaultPackages = with pkgs; [
    sparrow
  ];
}
