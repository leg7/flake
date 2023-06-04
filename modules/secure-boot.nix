{ lib, ... }: {
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    initrd.luks.devices.cryptLvm = {
      device = "/dev/disk/by-label/cryptLvm";
      allowDiscards = true;
    };
  };
}
