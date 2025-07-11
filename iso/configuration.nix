{ config, pkgs, lib, ... }: {
  imports = [
    ../modules/security
    ../modules/networking  
  ];

  # ISO-specific settings
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.edition = "framework";

  # Desktop environment for installation
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.enable = true;
  };

  # Root user - use only ONE password method, null out all others
  users.users.root = {
    # Use only password for ISO (simplest for installation)
    password = "root";
    # Explicitly null out all other password options
    hashedPassword = lib.mkForce null;
    hashedPasswordFile = lib.mkForce null;
    initialHashedPassword = lib.mkForce null;
    initialPassword = lib.mkForce null;
  };

  # Installation tools
  environment.systemPackages = with pkgs; [
    git
    nixos-install-tools
    parted
    gptfdisk
    cryptsetup
  ];

  # Include the configuration files
  environment.etc."nixos-config" = {
    source = ../.; 
    target = "nixos-config";
  };

  # Network for installation
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  # Disable SSH for security
  services.openssh.enable = lib.mkForce false;
}
