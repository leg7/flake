{ ... }: {
  boot.loader.systemd-boot.enable = true;

  fileSystems."boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };
}
