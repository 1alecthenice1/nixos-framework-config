{ lib, bootUUID ? "4C1D-B315", ... }:

{
  disko.devices = import ./framework-layout.nix;

  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

    "/boot" = lib.mkForce {
      device = "/dev/disk/by-uuid/${bootUUID}";
      fsType = "vfat";
    };
  };
}

