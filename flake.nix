{
  description = "A flake to manage my systems";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    use-xdg-base-directories = true;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, disko, nixos-hardware, lanzaboote, impermanence, zen-browser, ... }:
  let
    overlay-unstable = final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.system;
        config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "electron-27.3.11" # For logseq
              "freeimage-3.18.0-unstable-2024-04-18" # For emulationstation-de
            ];
        };
      };
    }; in {
    nixosConfigurations = {
      eleum = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [
          lanzaboote.nixosModules.lanzaboote
          impermanence.nixosModules.impermanence
          disko.nixosModules.disko
          ({pkgs, config, ...}: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./hardware/t480.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

      majula = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          lanzaboote.nixosModules.lanzaboote
          impermanence.nixosModules.impermanence
          disko.nixosModules.disko
          ({pkgs, config, ...}: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./hardware/rpi4.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

      heide = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs ; };

        modules = [
          lanzaboote.nixosModules.lanzaboote
          impermanence.nixosModules.impermanence
          disko.nixosModules.disko
          ({pkgs, config, ...}: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./hardware/dan.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

      # x200 = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     impermanence.nixosModules.impermanence
      #     ./computers/x200.nix
      #   ];
      # };
      #
      # x220i = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   modules = [
      #     impermanence.nixosModules.impermanence
      #     ./computers/x220i.nix
      #   ];
      # };
    };
  };
}
