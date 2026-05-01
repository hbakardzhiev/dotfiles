{ pkgs, pkgs-unstable, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  services.displayManager = {
    sddm = {
      enable = true;
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

  services.power-profiles-daemon.enable = true;

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
        gwenview
      ]
      ++ (with pkgs; [
        vlc
        geary
        otpclient
        viber
        grayjay
        dbeaver-bin
        qalculate-qt
        pcmanfm
        slurp
        gammastep
        file-roller
      ])
      ++ (with pkgs-unstable; [
        # wireless utility
        iwgtk
        code-cursor-fhs
      ])
      # Fonts
      ++ (with pkgs; [
        adwaita-icon-theme
        nerd-fonts._3270
      ]);
  };
}
