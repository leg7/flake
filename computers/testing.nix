{ ... }: {
  imports = [
    ./modules/secureboot.nix
    ./modules/systems/base.nix
    ./modules/mainDisk.nix
    ./modules/systems/hyprland/hyprland.nix
  ];

  networking.hostName = "testing";
  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;

  mainDisk.name = "/dev/sda";
  secureboot.enable = true;
}
