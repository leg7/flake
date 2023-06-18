{ lib, ... }: {
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    bootspec.enable = true;

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    initrd.luks.devices.cryptLvm = {
      device = "/dev/disk/by-label/cryptLvm";
      allowDiscards = true;
    };
  };

  fileSystems."/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
  };

  environment.persistence."/nix/persistent".directories = [ "/etc/secureboot" ];
}
