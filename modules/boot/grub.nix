{ ... }: {
  boot = {
    initrd = {
      luks.devices.encryptedSystem = {
        keyFile = "/keyfile.bin";
      };

      secrets = {
        "keyfile.bin" = "/etc/secrets/initrd/keyfile.bin";
      };
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
