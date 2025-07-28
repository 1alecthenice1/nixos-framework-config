{
  description = "NixOS config for Framework Laptop 13 AMD 7040";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, lanzaboote, disko, hyprland, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.framework = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit hyprland;
        };

        modules = [
          # Hardware-specific
          nixos-hardware.nixosModules.framework-13-7040-amd

          # Your own configs
          ./hosts/framework/configuration.nix
          ./hosts/framework/hardware-configuration.nix

          # Modular imports
          ./modules/security
          ./modules/users
          ./modules/tpm
          ./modules/boot
          ./modules/desktop
          ./modules/networking
          ./modules/hardware
          ./modules/zram

          # Disko & Boot
          lanzaboote.nixosModules.lanzaboote
          disko.nixosModules.disko

          # Desktop
          hyprland.nixosModules.default

          # Home Manager
          home-manager.nixosModules.home-manager

          # Disk layout
          ({ lib, ... }: {
            disko.devices = import ./disko/framework-luks-btrfs.nix;
          })
        ];
      };
    };
}

