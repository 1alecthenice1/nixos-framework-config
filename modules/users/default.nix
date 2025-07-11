{ config, lib, pkgs, ... }: {
  users.users.alma = {
    isNormalUser = true;
    description = "alec";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.bash;
  };
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.alma = import ./home.nix;
  };
}
