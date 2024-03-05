{ ... }: {
  imports = [ ./modules/boot/secureboot.nix ./modules/systems/base.nix ./modules/disk.nix ];

  networking.hostName = "testing";
  system.stateVersion = "23.11";

  mainDisk.name = "/dev/sda";
}
