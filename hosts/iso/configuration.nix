{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    # Include the ISO image module
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    
    # Add our custom modules (excluding TPM for ISO)
    ../../modules/security
    ../../modules/users
    # Skip TPM module for ISO - PCR values will be different
    ../../modules/desktop
    ../../modules/networking
    ../../modules/hardware
    ../../modules/zram
  ];

  # ISO specific configuration
  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
    volumeID = "FRAMEWORK-NIXOS";
    isoName = "framework-nixos-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
    
    # Include our flake in the ISO
    contents = [
      {
        source = ../..;
        target = "/nixos-config";
      }
    ];
  };

  # Basic system configuration
  networking.hostName = "framework-installer";
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Enable flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Allow unfree packages for the ISO
    allowed-unfree = [
      "nvidia-x11"
      "nvidia-settings" 
      "nvidia-persistenced"
    ];
  };
  
  # Allow unfree packages globally for installer
  nixpkgs.config.allowUnfree = true;

  # Essential packages for Framework installation
  environment.systemPackages = with pkgs; [
    # Basic utilities
    git curl wget vim nano htop tree
    tmux screen
    
    # Network tools
    networkmanager iw
    
    # Disk management
    gparted
    cryptsetup
    btrfs-progs
    dosfstools
    
    # Hardware utilities
    lshw usbutils pciutils
    dmidecode
    
    # TPM tools
    tpm2-tools
    tpm2-tss
    
    # Framework specific
    fwupd
    
    # Secure Boot tools
    sbctl
    
    # Installation helpers
    nixos-install-tools
    
    # Text editors
    neovim
    
    # Web browser for documentation
    firefox
    
    # File manager
    pcmanfm
  ];

  # Enable SSH for remote installation
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkForce "yes";
      PasswordAuthentication = lib.mkForce true;
    };
  };

  # Set root password for SSH access
  users.users.root.password = lib.mkForce "nixos";
  
  # Add installer user
  users.users.installer = {
    isNormalUser = true;
    password = "installer";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    shell = pkgs.bash;
  };

  # Enable sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Enable NetworkManager for WiFi setup
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;  # Disable wpa_supplicant

  # Enable audio for desktop environment
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable X11 and desktop environment for easier installation
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };

  # Enable libinput for touchpad support
  services.libinput.enable = true;

  # Auto-login to desktop
  services.displayManager.autoLogin = {
    enable = true;
    user = "installer";
  };

  # Framework hardware optimizations for the ISO
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Include kernel modules for Framework hardware
  boot.initrd.availableKernelModules = [
    "tpm_tis" "tpm_crb"
    "xhci_pci" "thunderbolt" "vmd" "nvme" 
    "usb_storage" "sd_mod" "rtsx_pci_sdmmc"
  ];

  # Framework power optimizations
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "amd_pstate=guided"
  ];

  # Enable firmware updates
  services.fwupd.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Create installation script on desktop
  environment.etc."installer-script.sh" = {
    text = ''
      #!/bin/bash
      # Framework NixOS Installation Script
      
      echo "🚀 Framework NixOS Installation Helper"
      echo "====================================="
      echo ""
      echo "This script will help you install NixOS on your Framework laptop."
      echo ""
      echo "📁 Configuration files are available in: /nixos-config"
      echo ""
      echo "🔧 Installation steps:"
      echo "1. Connect to WiFi using NetworkManager"
      echo "2. Partition your disk with disko:"
      echo "   sudo nix --experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko /nixos-config/disko/framework-luks-btrfs.nix"
      echo ""
      echo "3. Install NixOS:"
      echo "   cd /nixos-config"
      echo "   sudo nixos-install --flake .#framework"
      echo ""
      echo "4. ⚠️  IMPORTANT: Reboot into the installed system FIRST"
      echo "   sudo reboot"
      echo ""
      echo "5. Enable Secure Boot (CRITICAL for proper PCR 7 values):"
      echo "   sudo sbctl create-keys"
      echo "   sudo sbctl enroll-keys --microsoft"
      echo "   sudo nixos-rebuild switch"
      echo "   # Reboot and enable Secure Boot in BIOS"
      echo ""
      echo "6. AFTER Secure Boot is enabled, enroll TPM:"
      echo "   sudo /etc/nixos/scripts/tpm-enroll.sh"
      echo ""
      echo "🔐 TPM Notes:"
      echo "   - TPM enrollment MUST be done from the installed system"
      echo "   - Secure Boot MUST be enabled before TPM enrollment"
      echo "   - PCR 7 values differ between ISO, installed system, and Secure Boot states"
      echo "   - DO NOT enroll TPM from the live ISO or before enabling Secure Boot"
      echo ""
      echo "📖 Full instructions: /nixos-config/deployment-instructions.md"
      echo ""
    '';
    mode = "0755";
  };

  # Add desktop shortcut for installation guide
  environment.etc."skel/Desktop/Install-Framework-NixOS.desktop" = {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Install Framework NixOS
      Comment=Framework NixOS Installation Guide
      Exec=xfce4-terminal -e "cat /etc/installer-script.sh; bash"
      Icon=system-software-install
      Terminal=false
      Categories=System;
    '';
  };

  system.stateVersion = "24.05";
}
