{ config, lib, pkgs, hyprland, ... }: {
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  # XDG Portal configuration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Display manager - greetd with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Essential desktop packages
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    waybar dunst rofi-wayland wofi
    wl-clipboard wf-recorder grim slurp
    swaylock-effects swayidle
    
    # Terminal and applications
    alacritty kitty
    firefox chromium
    thunderbird
    
    # File management
    nautilus thunar
    ranger nnn
    
    # Media
    mpv vlc
    pavucontrol
    playerctl
    
    # Productivity
    libreoffice-fresh
    obsidian
    code-cursor
    
    # System utilities
    brightnessctl
    pamixer
    networkmanagerapplet
    blueman
    
    # Development tools
    vscode
    docker-compose
    postman
    
    # Graphics and design
    gimp
    inkscape
    
    # Communication
    discord
    slack
    zoom-us
    telegram-desktop
  ];

  # Fonts for better desktop experience
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    (nerdfonts.override { 
      fonts = [ "FiraCode" "DroidSansMono" "JetBrainsMono" "Iosevka" ];
    })
  ];

  # Session variables
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Polkit for privilege elevation
  security.polkit.enable = true;
  
  # Enable dconf for GTK applications
  programs.dconf.enable = true;
}
