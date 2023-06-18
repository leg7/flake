{ lib, ... }: {
  boot = {
    initrd = {
      secrets."keyfile.bin" = "/etc/secrets/initrd/keyfile.bin";

      luks.devices.cryptLvm = {
        # You need to overwrite boot.initrd.luks.devices.cryptLvm.device because grub
        # doesn't support luks2 and luks1 doesn't support disk labels
        # overwrite the uuid in your host module
        device = lib.mkDefault "/dev/disk/by-uuid/TODO";
        allowDiscards = true;
        keyFile = "/keyfile.bin";
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

  fileSystems."/boot/efi" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
  };

  environment.persistence."/nix/persistent".directories = [ "/etc/secrets/initrd" ];
}
