{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;

  # Home Manager's GTK settings (theme, fonts) are stored through dconf.
  programs.dconf.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    # No autologin: the greeter asks for the password.
    defaultSession = "hyprland-uwsm";
  };

  services = {
    power-profiles-daemon.enable = true;
    upower.enable = true;
    udisks2.enable = true;
    gnome.gnome-keyring.enable = true;
    irqbalance.enable = true;
    thermald.enable = true;
  };

  security.polkit.enable = true;

  # hyprlock authenticates through its own PAM service; without it the lock
  # screen cannot be unlocked.
  security.pam.services.hyprlock = { };

  # The lock screen has to be up before logind's five-second default expires,
  # otherwise closing the lid suspends an unlocked session.
  services.logind.settings.Login.InhibitDelayMaxSec = 15;

  zramSwap.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    cantarell-fonts
    dejavu_fonts
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # Tools the keybindings, the bar and the session start call. Waybar, fuzzel,
  # hyprlock, hypridle and mako come from Home Manager.
  environment.systemPackages = with pkgs; [
    brightnessctl
    bluez
    bluez-tools
    curl
    evince
    file-roller
    grim
    hyprpicker
    hyprsunset
    imv
    jq
    keepassxc
    libnotify
    mpv
    nautilus
    networkmanager
    playerctl
    python3
    smartmontools
    slurp
    udiskie
    wireplumber
    wl-clipboard
    xdg-utils
  ]
  ++ [
    pkgs.kdePackages.kdenlive
    pkgs.nextcloud-client
    pkgs.thunderbird
  ];
}
