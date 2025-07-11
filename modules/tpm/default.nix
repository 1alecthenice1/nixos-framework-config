{ config, lib, pkgs, ... }: {
  # Enable TPM support
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  # Enable TPM in initrd
  boot.initrd.systemd.tpm2.enable = true;

  # Install TPM tools
  environment.systemPackages = with pkgs; [
    tpm2-tools
    tpm2-tss
  ];

  # TPM group
  users.groups.tss = {};
  
  # TPM device permissions
  system.activationScripts.tpmSetup = {
    text = ''
      if [ -c /dev/tpm0 ]; then
        chown root:tss /dev/tpm0
        chmod 660 /dev/tpm0
      fi
    '';
    deps = [ ];
  };
}
