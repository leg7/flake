{
  description = "A flake to manage my systems";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    auto-optimise-store = true;
    use-xdg-base-directories = true;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = inputs@{ nixpkgs, lanzaboote, impermanence, emacs-overlay, ... }: {
    nixosConfigurations = {
      eleum = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          lanzaboote.nixosModules.lanzaboote
          impermanence.nixosModules.impermanence
          ({pkgs, ...}: { nixpkgs.overlays = [ emacs-overlay.overlay ]; })
          ./computers/t480.nix
        ];
      };

      # majula = nixpkgs.lib.nixosSystem {
      #   system = "aarch64-linux";
      #   modules = [
      #     impermanence.nixosModules.impermanence
      #     ./rpi4.nix
      #   ];
      # };

      x200 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          impermanence.nixosModules.impermanence
          ./computers/x200.nix
        ];
      };

      x220i = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          impermanence.nixosModules.impermanence
          ./computers/x220i.nix
        ];
      };
    };
  };
}
