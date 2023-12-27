{ ... }: {
  boot.loader.systemd-boot.enable = true;

  boot.initrd.luks.devices.cryptLvm = {
    device = "/dev/disk/by-label/cryptLvm";
    allowDiscards = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };
}
