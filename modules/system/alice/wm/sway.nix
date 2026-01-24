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
        code-cursor-fhs
        grayjay
        dbeaver-bin
        qalculate-qt
        pcmanfm
        slurp
      ])
      ++ (with pkgs-unstable; [
        # wireless utility
        iwgtk
      ])
      # Fonts
      ++ (with pkgs; [
        adwaita-icon-theme
        nerd-fonts._3270
      ]);
  };
}
