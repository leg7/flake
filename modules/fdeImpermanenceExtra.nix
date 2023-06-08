# An extra encrypted luks volume to keep backups that will be decrypted at boot
{ ... }: {
  boot.initrd.luks.devices.cryptBackup = {
    device = "/dev/disk/by-label/cryptBackup";
    allowDiscards = true;
  };

  fileSystems."/nix/persistent/backup" = {
      device = "/dev/disk/by-label/backup";
      fsType = "f2fs";
      options = [ "compress_algorithm=zstd" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
  };
}
