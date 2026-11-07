{
  pkgs,
  omarchy,
  omarchyPkg,
  omarchySddm,
  quickshell,
  ...
}:
let
  # Everything Omarchy's shell, menu, bar modules and Hyprland bindings expect
  # to find on PATH. Package-management rows are the one thing that cannot
  # work: there is no pacman here.
  omarchyRuntime =
    with pkgs;
    [
      alacritty
      bat
      bluez
      bluez-tools
      btop
      brightnessctl
      curl
      ddcutil
      dbus
      dconf
      evince
      eza
      fastfetch
      fd
      ffmpeg
      ffmpegthumbnailer
      file
      file-roller
      font-awesome
      fontconfig
      foot
      fzf
      ghostty
      glib
      gnome-keyring
      grim
      gpu-screen-recorder
      gum
      gvfs
      hdparm
      helix
      hyprpicker
      hyprsunset
      imagemagick
      imv
      inotify-tools
      inxi
      jq
      lazygit
      less
      libnotify
      libsecret
      localsend
      man-db
      mpv
      nautilus
      neovim
      networkmanager
      ntfs3g
      obsidian
      p7zip
      pamixer
      pciutils
      playerctl
      plocate
      procps
      python3
      qrencode
      satty
      slurp
      smartmontools
      socat
      starship
      system-config-printer
      tailscale
      tesseract
      tldr
      tmux
      udiskie
      unzip
      upower
      usbutils
      util-linux
      vips
      wl-clipboard
      wireplumber
      wtype
      xdg-terminal-exec
      yaru-theme
      yt-dlp
      zbar
      zip
      zoxide
    ]
    ++ (with pkgs.qt6; [
      qt5compat
      qtdeclarative
      qtimageformats
      qtmultimedia
      qtsvg
      qtwayland
    ])
    ++ (with pkgs; [
      # The productivity set kept from the previous NixOS configuration.
      # libreoffice, xournalpp and obs-studio come from Home Manager, which
      # installs obs-studio with its plugins.
      kdePackages.kdenlive
      keepassxc
      nextcloud-client
      thunderbird
    ]);
in
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;

  # Home Manager's dconf settings (GTK theme/font, icon theme) need dconf
  # installed system-wide, or activation logs a D-Bus error and nothing applies.
  programs.dconf.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
      wayland = {
        enable = true;
        # Omarchy's greeter runs Hyprland, not Weston. Same command Omarchy
        # itself puts in /etc/sddm.conf.d on Arch; --path is needed because
        # start-hyprland execs "Hyprland" from PATH, which the greeter does not
        # necessarily have here.
        compositorCommand = "${pkgs.hyprland}/bin/start-hyprland --path ${pkgs.hyprland}/bin/Hyprland -- --config ${omarchySddm}/share/omarchy-sddm/hyprland.lua";
      };
      # SDDM links $out/share/sddm/themes/<name> from systemPackages into
      # /run/current-system/sw/share/sddm/themes and takes the name here.
      theme = "omarchy";
      extraPackages = with pkgs.qt6; [
        qt5compat
        qtdeclarative
        qtsvg
      ];
    };
    # No autologin: the Omarchy greeter is the first screen.
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

  # Puts the merged Qt plugin/QML paths of every Qt package in systemPackages
  # on the session's search path (Quickshell and the Qt apps need this).
  qt.enable = true;

  # Omarchy's lock screen authenticates through a PAM service named
  # omarchy-lock-password and refuses to lock when /etc/pam.d is missing it.
  security.pam.services.omarchy-lock-password = { };

  # Same reason as Omarchy's own install: the shell suspends after the lock
  # screen has been secured, and logind's five-second default is not enough
  # when closing the lid also reconfigures displays.
  services.logind.settings.Login.InhibitDelayMaxSec = 15;

  # uwsm-app starts apps as systemd user units, which do not inherit the
  # session environment, and Omarchy's scripts read OMARCHY_PATH from it.
  systemd.user.extraConfig = ''
    DefaultEnvironment="OMARCHY_PATH=${omarchyPkg}/share/omarchy"
  '';

  zramSwap.enable = true;

  environment = {
    systemPackages = [
      omarchyPkg
      omarchySddm
      quickshell
    ] ++ omarchyRuntime;

    # OMARCHY_PATH has to be visible to the session, to systemd user services
    # and to a plain TTY, so it lives in the system environment as well as the
    # graphical session.
    variables.OMARCHY_PATH = "${omarchyPkg}/share/omarchy";

    sessionVariables = {
      OMARCHY_PATH = "${omarchyPkg}/share/omarchy";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };

  fonts.packages = with pkgs; [
    adwaita-fonts
    dejavu_fonts
    liberation_ttf
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # Omarchy's fontconfig rules: monospace resolves to the Nerd Font (the shell
  # and every terminal draw their icons from it), plus its CJK/Arabic fallbacks.
  fonts.fontconfig.localConf = builtins.readFile "${omarchy}/default/fontconfig/conf.avail/50-omarchy.conf";
}
