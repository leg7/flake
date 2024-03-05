{ ... }: {
  imports = [
    ./modules/secureboot.nix
    ./modules/systems/base.nix
    ./modules/mainDisk.nix
  ];

  networking.hostName = "testing";
  system.stateVersion = "23.11";

  mainDisk.name = "/dev/sda";
  secureboot.enable = true;
}
