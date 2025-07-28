{ config, lib, pkgs, ... }:

{
  imports = [ ];

  fileSystems."/boot" = {
    device = lib.mkForce "/dev/disk/by-uuid/4C1D-B315";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/" = {
    device = lib.mkForce "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=root" "compress=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = lib.mkForce "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=home" "compress=zstd" "noatime" ];
  };

  fileSystems."/nix" = {
    device = lib.mkForce "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" ];
  };

  swapDevices = [ ];

  boot.initrd.luks.devices."cryptroot".device = lib.mkForce "/dev/disk/by-uuid/019467e8-f3a3-4f41-b7ef-f861ab7304ea";

  # If using systemd-boot or lanzaboote with Secure Boot
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Optional: enable TPM-based unlock
  # boot.initrd.luks.devices."cryptroot".tpm2 = true;

  # Set timezone and hostname as appropriate
  time.timeZone = "America/New_York";
  networking.hostName = "framework"; # Adjust if needed
}

