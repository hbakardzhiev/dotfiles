{ pkgs, pkgs-unstable, ... }:
{
  services.displayManager.sddm.enable = true;
  services.displayManager = {
    sddm = {
      wayland.enable = true;
      settings = {
        # General.DisplayServer = "wayland";
        Autologin = {
          Session = "sway";
          User = "alice";
        };
      };
    };
    defaultSession = "sway";
  };

  programs = {
    sway = {
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraOptions = [
        "--unsupported-gpu"
      ];
      xwayland.enable = true;
    };
    waybar = {
      enable = true;
    };
  };

  environment = {
    systemPackages =
      with pkgs.kdePackages;
      [
        okular
        kdenlive
        ktorrent
        keysmith
      ]
      ++ (with pkgs; [
        vlc
        geary
        otpclient
        viber
        code-cursor-fhs
        grayjay
        dbeaver-bin
        qalculate-qt
        nerd-fonts._3270
      ])
      ++ (with pkgs-unstable; [
      ]);
  };
}
