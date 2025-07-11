{ config, lib, pkgs, ... }: {
  users.almass.alma = {
    isNormalUser = true;
    description = "alec";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;
  };
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.almas = import ./home.nix;
  };
}
