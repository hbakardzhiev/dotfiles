{ ... }:
{
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
  ];
}
