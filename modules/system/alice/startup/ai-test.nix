{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.nodejs_20
  ];  
}
