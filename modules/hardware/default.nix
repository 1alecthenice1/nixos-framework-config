{ config, lib, pkgs, ... }: {
  # Framework-specific hardware optimizations
  hardware.framework.amd-7040.preventWakeOnAC = true;
  
  # Graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr.icd
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
  
  # Firmware and microcode
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [ 
    linux-firmware 
    sof-firmware
  ];
  hardware.cpu.amd.updateMicrocode = true;
  
  # Power management
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;  # Conflicts with power-profiles-daemon
  
  # Framework-specific services
  services.fwupd.enable = true;
  
  # Audio system
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Low-latency audio configuration
    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 32;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 32;
      };
    };
  };
  
  # Webcam and media support
  # Camera access is handled by PipeWire and user permissions
  
  # USB and Thunderbolt
  services.udev.packages = with pkgs; [
    android-udev-rules
    platformio-core
  ];
  
  # Hardware monitoring
  environment.systemPackages = with pkgs; [
    # Framework-specific tools
    fw-ectool
    framework-tool
    
    # System monitoring
    htop
    btop
    iotop
    powertop
    s-tui
    
    # Hardware info
    lshw
    pciutils
    usbutils
    dmidecode
    
    # Temperature and fan control
    lm_sensors
    
    # Battery management
    acpi
    powertop
    
    # Storage tools
    smartmontools
    nvme-cli
    
    # Audio tools
    pavucontrol
    playerctl
    
    # Graphics tools
    vulkan-tools
    mesa-demos
    radeontop
    
    # Development tools
    docker
    docker-compose
    git
    gnumake
    gcc
    
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
  
  # Kernel parameters for Framework optimization
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "amd_pstate=guided"
    "amd_iommu=on"
    "iommu=pt"
  ];
  
  # Kernel modules
  boot.kernelModules = [ 
    "kvm-amd"
    "vfio-pci"
  ];
  
  # Hardware acceleration
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
}
