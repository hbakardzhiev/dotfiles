{ ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      echo "Your wish is my command, master!"
    '';
    shellAliases = {
      l = "ls -alh";
      update = "sudo nix flake update /etc/nixos/";
      clean = "sudo nix-collect-garbage --delete-older-than 1d";
      switch = "nix-store --verify && sudo nixos-rebuild switch --flake /etc/nixos/.#$(hostname -s)";
      randomMac = "nmcli connection modify WIFI_CONN wifi.cloned-mac-address random";
      performance = "sudo cpupower frequency-set -g performance";
      powersave = "sudo cpupower frequency-set -g powersave";
      showWindowName = "swaymsg -t get_tree";
      showDefaultApplicationForMimeType = "XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default"; # application/pdf
      showMimeTypeOfFile = "XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query filetype"; # ./Downloads/text.html
      overrideHomeManager = "sudo nix flake lock --update-input home-manager --override-input home-manager /home/alice/Downloads/home-manager";
      gparted = "sudo -E gparted";
    };
  };
}
