{ config, lib, pkgs, hyprland, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/security
    ../../modules/users
    ../../modules/tpm
    ../../modules/boot
    ../../modules/desktop
    ../../modules/networking
    ../../modules/hardware
    ../../modules/zram
  ];

  # Basic system configuration
  networking.hostName = "framework";
  time.timeZone = "America/New_York";  # Update this if needed
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Enable flakes and optimizations
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  
  # Enhanced packages for desktop system
  environment.systemPackages = with pkgs; [
    # System essentials
    git curl wget vim htop tree
    
    # LUKS and filesystem tools
    cryptsetup
    btrfs-progs
    
    # Development tools
    python3
    nodejs
    rustc
    cargo
    
    # Archive tools
    zip
    unzip
    
    # System monitoring
    neofetch
    fastfetch
  ];

  # Shell aliases for convenience
  environment.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#framework";
    update = "sudo nixos-rebuild switch --upgrade --flake /etc/nixos#framework";
    clean = "sudo nix-collect-garbage -d";
    hardware-info = "sudo dmidecode -t system && sudo lshw -short";
    battery-info = "cat /sys/class/power_supply/BAT*/capacity";
    temp-check = "sensors";
  };

  system.stateVersion = "24.05";
}
