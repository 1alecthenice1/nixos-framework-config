{ config, lib, pkgs, ... }: {
  # Basic firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # Basic sudo configuration
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };
}
