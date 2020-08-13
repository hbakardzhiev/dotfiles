# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = ["acpi_osi=Linux" "acpi_backlight=none" "tp_smapi" "thinkpad_acpi" "acpi_call" "kvm-intel"];

  # Virtualization
   virtualisation.libvirtd.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
   networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s20f0u2.useDHCP = true;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  # networking.nameservers = ["176.103.130.130" "176.103.130.131"];
  environment.etc = {
	"resolv.conf".text = "nameserver 176.103.130.130\n nameserver 176.103.130.131\n nameserver 2a00:5a60::ad1:0ff\n nameserver 2a00:5a60::ad2:0ff\n";
   };
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
     defaultLocale = "en_US.UTF-8";
  #   consoleUseXkbConfig = true;
   };
  # console.useXkbConfig = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";
  
  # GC setup
   nix.gc = {
   	automatic = true;
  	dates = "weekly";
  	options = "--delete-older-than 10d";
   };
  
  # Automatic updates
   system.autoUpgrade.enable = true;
   system.autoUpgrade.allowReboot = true;
   system.autoUpgrade.channel = https://nixos.org/channels/nixos-20.03;
  
  # Allow unfree (discord, chrome...)
   nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     virt-manager
     xorg.xbacklight
     zip
     unzip
     unrar
     wget
     gcc
     python3
     gitkraken
     postman
     nodejs 
     spring-boot
     eclipses.eclipse-java
     dotnet-sdk_3
     dotnetCorePackages.netcore_3_1
     dotnetCorePackages.aspnetcore_3_1
     postgresql_9_6
     # editor 
     vim
     vscode-with-extensions
     gimp
     wpsoffice
     jetbrains.rider
     # terminal
     alacritty
     # browser
     firefox
     google-chrome
     # video/audio player
     vlc
     # file manager
     pcmanfm
     # Screenshot
     scrot
     # communication tools
     discord
     teams
     slack-dark
     ];
  
  # Docker
   virtualisation.docker.enable = true;
 
  # Enable flatpak/flathub
  # services.flatpak.enable = true;
  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  
  # i3 enable WM
    services.xserver = {
         enable = true;

        displayManager = {
             defaultSession = "none+i3";
        #     xterm.enable = false;
        };

        windowManager.i3 = {
             enable = true;
             extraPackages = with pkgs; [
              j4-dmenu-desktop #application launcher most people use
              i3status # gives you the default i3 status bar
              i3lock #default i3 screen locker
              i3blocks #if you are planning on using i3blocks over i3status
              ];
        };
    };
   
  # List services that you want to enable:
  # Sway display manager
  # programs.sway.enable = true;
  # programs.sway.extraPackages = with pkgs; [grim swaylock qt5.qtwayland xwayland mako slurp waybar j4-dmenu-desktop];
  # programs.sway.extraSessionCommands = ''
  #    export SDL_VIDEODRIVER=wayland
  #    export QT_QPA_PLATFORM=wayland
  #    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
  #    export _JAVA_AWT_WM_NONREPARENTING=1
  #    export BEMENU_BACKEND=wayland'';
   hardware.opengl.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
   services.printing.enable = true;

  # Enable sound.
   sound.enable = true;
   hardware.pulseaudio.enable = true;
  # hardware.pulseaudio = {
  #   enable = true;

     # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
  #   #     # Only the full build has Bluetooth support, so it must be selected here.
  #   package = pkgs.pulseaudioFull;
  # };

  # Adb
  # programs.adb.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.autorun = true;
  # services.xserver.xkbOptions = "eurosign:e";
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.windowManager.i3.enable = true;
  # Enable touchpad support.
  # services.xserver.libinput.enable = true;
  # services.xserver.libinput.tapping = false;
   services.xserver.synaptics.enable = true;
   services.xserver.synaptics.vertEdgeScroll = false;
   services.xserver.synaptics.vertTwoFingerScroll = true;
   services.xserver.synaptics.tapButtons = false;
  # services.xserver.synaptics.horizontalScroll = false;
  # services.xserver.synaptics.horizTwoFingerScroll = true;
  # hardware.trackpoint.fakeButtons = true;
  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
   services.xserver.videoDrivers = ["intel"];
  # Service for GUI bluetooth usage
  # services.blueman.enable = true;

  # Bluetooth enable
  #  hardware.bluetooth.enable = true;
  #  hardware.bluetooth.extraConfig = "
  #   [General]
  #   Enable=Source,Sink,Media,Socket
  #  ";


  # TLP management
   services.tlp.enable = true;
   services.tlp.extraConfig = ''
  	DEVICES_TO_DISABLE_ON_STARTUP="bluetooth"
   	START_CHARGE_THRESH_BAT0=85
   	STOP_CHARGE_THRESH_BAT0=90
   	CPU_SCALING_GOVERNOR_ON_BAT=powersave
   	ENERGY_PERF_POLICY_ON_BAT=powersave
   '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.hristo = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker"]; # Enable ‘sudo’ for the user. Allow docker to use the sockets.
   };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

