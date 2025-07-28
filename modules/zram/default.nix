{ lib, frameworkLayout, ... }:

{
  disko.devices = frameworkLayout;

  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

    "/boot" = lib.mkForce {
      device = "/dev/disk/by-uuid/4C1D-B315";
      fsType = "vfat";
    };
  };
}

