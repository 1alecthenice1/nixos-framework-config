{ config, lib, pkgs, ... }: {
  # Enable systemd in initrd
  boot.initrd.systemd.enable = true;
  
  # Disable regular systemd-boot (lanzaboote will handle it)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Enable lanzaboote for Secure Boot
  # NOTE: Secure Boot should be enabled AFTER initial installation
  # and BEFORE TPM enrollment for correct PCR 7 values
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
  
  # Install Secure Boot tools
  environment.systemPackages = with pkgs; [
    sbctl
  ];
  
  # Boot optimization
  boot.loader.timeout = 3;
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet" "splash"
  ];
}
