{ ... }:
{
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };
  permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
  ];
}
