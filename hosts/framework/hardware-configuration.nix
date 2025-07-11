{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Framework-optimized kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [
    "tpm_tis" "tpm_crb"  # TPM modules
    "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod"
  ];
  
  boot.initrd.kernelModules = [ "dm-snapshot" "cryptd" ];
  boot.kernelModules = [ "kvm-amd" ];

  # LUKS configuration (will be updated after installation)
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ACTUAL-LUKS-UUID";
    allowDiscards = true;
    # TPM unlock will be configured post-installation
  };

  # Btrfs subvolumes (will be updated after installation)
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ACTUAL-ROOT-UUID";
    fsType = "btrfs";
    options = [ "subvol=root" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ACTUAL-ROOT-UUID";
    fsType = "btrfs";
    options = [ "subvol=home" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ACTUAL-ROOT-UUID";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-WITH-ACTUAL-BOOT-UUID";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  
  # Framework-specific optimizations
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;
  
  # Power management
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "amd_pstate=guided"
  ];
}
