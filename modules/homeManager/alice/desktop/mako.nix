{
  ...
}:
{
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 10";
      anchor = "top-right";
      layer = "overlay";
      width = 360;
      height = 160;
      margin = 10;
      padding = 10;
      border-size = 1;
      border-color = "#d8d8d8";
      background-color = "#f6f6f6";
      text-color = "#1f1f1f";
      default-timeout = 8000;
      max-visible = 4;
      icons = true;
    };
    extraConfig = ''
      [urgency=critical]
      border-color=#b3261e
      text-color=#b3261e
      default-timeout=0
    '';
  };
}
