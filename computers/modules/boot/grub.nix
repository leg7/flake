{ lib, ... }: {
  boot = {
    initrd.luks.devices.cryptLvm = {
      # You need to overwrite boot.initrd.luks.devices.cryptLvm.device because grub
      # doesn't support luks2 and luks1 doesn't support disk labels
      # overwrite the uuid in your host module
      device = lib.mkDefault "/dev/disk/by-uuid/TODO";
      allowDiscards = true;
      preLVM = true;
    };

    loader.grub = {
		# You also need to overwrite this to the disk you're installing grub to
		# for example /dev/sda
        device = lib.mkDefault "/dev/disk/by-uuid/TODO";
        enableCryptodisk = true;
    };
  };

  fileSystems."/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
  };
}
