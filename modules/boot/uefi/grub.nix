{ ... }: {
  boot = {
  # You need to overwrite initrd.luks.devices.cryptLvm.device because grub
  # doesn't support luks2 and luks1 doesn't support disk labels
  # use the uuid in your host module
    initrd = {
      luks.devices.cryptLvm.keyFile = "/keyfile.bin";
      secrets."keyfile.bin" = "/etc/secrets/initrd/keyfile.bin";
    };

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };

      grub = {
        efiSupport = true;
        device = "nodev";
        enableCryptodisk = true;
      };
    };
  };
}
