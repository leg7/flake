{
  description = "A flake to manage my systems";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    auto-optimise-store = true;
    use-xdg-base-directories = true;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
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

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, disko, nixos-hardware, lanzaboote, impermanence, emacs-overlay, ... }:
  let
    overlay-unstable = final: prev: {
      unstable = nixpkgs-unstable.legacyPackages.${prev.system};
    };
  in {
    nixosConfigurations = {
      eleum = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          lanzaboote.nixosModules.lanzaboote
          impermanence.nixosModules.impermanence
          disko.nixosModules.disko
          ({pkgs, config, ...}: { nixpkgs.overlays = [ overlay-unstable emacs-overlay.overlay ]; })
          ./computers/t480.nix
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
          ./computers/rpi4.nix
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
