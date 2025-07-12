{ config, lib, pkgs, ... }: {
  imports = [
    ./android.nix
  ];

  # Development packages
  environment.systemPackages = with pkgs; [
    # Version control
    git
    
    # Build tools
    gnumake
    gcc
    
    # Containerization
    docker
    docker-compose
    
    # Virtualization
    virt-manager
    qemu
    
    # Archive tools
    unzip
    p7zip
    unrar
  ];
  
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
  
  # Enable libvirtd for VMs
  virtualisation.libvirtd.enable = true;
}